<?php

namespace App\Http\Controllers\Api;

use App\Models\Payment;
use App\Models\PaymentMethod;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Models\Customer;
use App\Models\Sale;
use App\Models\SaleItem;
use App\Models\StockMovement;
use App\Models\Store;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class SaleController extends BaseApiController
{
    public function index(Request $request)
    {
        $manager = $this->managerOrFail($request);
        $perPage = (int) $request->query('per_page', 20);

        $sales = Sale::where('manager_id', $manager->id)
            ->with('payments')
            ->orderBy('id', 'desc')
            ->paginate($perPage);

        return response()->json($sales);
    }

    public function show(Request $request, int $id)
    {
        $manager = $this->managerOrFail($request);

        $sale = Sale::where('manager_id', $manager->id)
            ->with(['items', 'payments'])
            ->findOrFail($id);

        return response()->json($sale);
    }

    public function pay(Request $request, int $id)
    {
        $manager = $this->managerOrFail($request);

        $data = $request->validate([
            'payment_method_id' => ['required', 'integer'],
            'received_amount' => ['nullable', 'numeric', 'min:0'],
        ]);

        return DB::transaction(function () use ($manager, $id, $data) {
            $sale = Sale::where('manager_id', $manager->id)
                ->with(['payments', 'items'])
                ->lockForUpdate()
                ->findOrFail($id);

            $method = PaymentMethod::where(function ($query) use ($manager) {
                $query->whereNull('manager_id')
                    ->orWhere('manager_id', $manager->id);
            })->findOrFail($data['payment_method_id']);

            $alreadyPaid = (float) $sale->payments->sum('amount');
            $grandTotal = (float) $sale->grand_total;
            $remaining = max($grandTotal - $alreadyPaid, 0);
            if ($remaining <= 0) {
                return response()->json($sale);
            }

            $receivedAmount = (float) ($data['received_amount'] ?? $remaining);
            $amount = $receivedAmount > 0 ? min($receivedAmount, $remaining) : $remaining;

            Payment::create([
                'sale_id' => $sale->id,
                'payment_method_id' => $method->id,
                'amount' => $amount,
                'paid_at' => now(),
            ]);

            $newPaidTotal = $alreadyPaid + $amount;
            if ($newPaidTotal >= $grandTotal && $grandTotal > 0) {
                $sale->status = 'paid';
            } elseif ($newPaidTotal > 0) {
                $sale->status = 'partial';
            } else {
                $sale->status = 'unpaid';
            }
            $sale->save();
            $sale->load(['items', 'payments']);

            return response()->json($sale);
        });
    }

    public function store(Request $request)
    {
        $manager = $this->managerOrFail($request);

        $data = $request->validate([
            'store_id' => [
                'required',
                Rule::exists('stores', 'id')->where('manager_id', $manager->id),
            ],
            'device_id' => [
                'nullable',
                'integer',
            ],
            'user_id' => ['nullable', 'integer'],
            'customer_id' => [
                'nullable',
                Rule::exists('customers', 'id')->where('manager_id', $manager->id),
            ],
            'currency' => ['nullable', 'string', 'size:3'],
            'status' => ['nullable', 'string', 'max:255'],
            'note' => ['nullable', 'string'],
            'ordered_at' => ['nullable', 'date'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['nullable', 'integer'],
            'items.*.product_variant_id' => ['nullable', 'integer'],
            'items.*.name' => ['nullable', 'string', 'max:255'],
            'items.*.sku' => ['nullable', 'string', 'max:255'],
            'items.*.quantity' => ['required', 'numeric', 'min:0.001'],
            'items.*.unit_price' => ['required', 'numeric', 'min:0'],
            'items.*.discount_amount' => ['nullable', 'numeric', 'min:0'],
            'items.*.tax_amount' => ['nullable', 'numeric', 'min:0'],
            'items.*.options' => ['nullable', 'array'],
            'items.*.options.*.id' => ['nullable', 'integer'],
            'items.*.options.*.name' => ['nullable', 'string', 'max:255'],
            'items.*.options.*.quantity' => ['nullable', 'numeric', 'min:0'],
            'payments' => ['nullable', 'array'],
            'payments.*.payment_method_id' => ['required_with:payments', 'integer'],
            'payments.*.amount' => ['required_with:payments', 'numeric', 'min:0'],
            'payments.*.reference' => ['nullable', 'string', 'max:255'],
            'payments.*.paid_at' => ['nullable', 'date'],
            'loyalty_redeem_points' => ['nullable', 'integer', 'min:0'],
            'loyalty_redeem_amount' => ['nullable', 'numeric', 'min:0'],
        ]);

        $store = Store::with('currency')
            ->where('manager_id', $manager->id)
            ->findOrFail($data['store_id']);

        $user = $request->user();
        $allowLoyaltyRedeem = $user?->allow_loyalty_redeem
            ?? $store->allow_loyalty_redeem
            ?? true;

        return DB::transaction(function () use ($manager, $data, $store, $allowLoyaltyRedeem) {
            $saleItems = [];
            $subtotal = 0.0;
            $discountTotal = 0.0;
            $taxTotal = 0.0;
            $totalQuantity = 0.0;
            $customer = null;
            if (!empty($data['customer_id'])) {
                $customer = Customer::where('manager_id', $manager->id)
                    ->lockForUpdate()
                    ->find($data['customer_id']);
            }

            foreach ($data['items'] as $item) {
                $product = null;
                $variant = null;

                if (!empty($item['product_id'])) {
                    $product = Product::where('manager_id', $manager->id)->findOrFail($item['product_id']);
                }

                if (!empty($item['product_variant_id'])) {
                    $variant = ProductVariant::where('manager_id', $manager->id)->findOrFail($item['product_variant_id']);
                    if ($product && $variant->product_id !== $product->id) {
                        throw new HttpResponseException(
                            response()->json(['message' => 'Product variant does not belong to product.'], 422)
                        );
                    }
                }

                $name = $item['name'] ?? ($product?->name ?? 'Item');
                $sku = $item['sku'] ?? ($variant?->sku ?? $product?->sku);
                $quantity = (float) $item['quantity'];
                $unitPrice = (float) $item['unit_price'];
                $discountAmount = (float) ($item['discount_amount'] ?? 0);
                $taxAmount = (float) ($item['tax_amount'] ?? 0);
                $options = $item['options'] ?? null;
                if (is_array($options)) {
                    $options = array_values(array_filter($options, function ($option) {
                        if (!is_array($option)) {
                            return false;
                        }
                        $qty = $option['quantity'] ?? 0;
                        return is_numeric($qty) && (float) $qty > 0;
                    }));
                } else {
                    $options = null;
                }

                $lineSubtotal = $unitPrice * $quantity;
                $lineTotal = $lineSubtotal - $discountAmount + $taxAmount;

                $subtotal += $lineSubtotal;
                $discountTotal += $discountAmount;
                $taxTotal += $taxAmount;
                $totalQuantity += $quantity;

                $saleItems[] = [
                    'product_id' => $product?->id,
                    'product_variant_id' => $variant?->id,
                    'name' => $name,
                    'sku' => $sku,
                    'quantity' => $quantity,
                    'unit_price' => $unitPrice,
                    'discount_amount' => $discountAmount,
                    'tax_amount' => $taxAmount,
                    'options' => $options,
                    'total' => $lineTotal,
                ];
            }

            $grandTotal = $subtotal - $discountTotal + $taxTotal;

            $currencyCode = $store->currency?->code ?? $manager->currency ?? 'USD';

            $sale = Sale::create([
                'manager_id' => $manager->id,
                'store_id' => $store->id,
                'device_id' => $data['device_id'] ?? null,
                'user_id' => $data['user_id'] ?? null,
                'customer_id' => $data['customer_id'] ?? null,
                'number' => $data['number'] ?? ('S' . date('YmdHis') . Str::upper(Str::random(4))),
                'status' => $data['status'] ?? 'unpaid',
                'subtotal' => $subtotal,
                'discount_total' => $discountTotal,
                'tax_total' => $taxTotal,
                'grand_total' => $grandTotal,
                'currency' => $data['currency'] ?? $currencyCode,
                'note' => $data['note'] ?? null,
                'ordered_at' => $data['ordered_at'] ?? now(),
            ]);

            foreach ($saleItems as $saleItem) {
                $saleItem['sale_id'] = $sale->id;
                SaleItem::create($saleItem);

                if ($store->stock_enabled && !empty($saleItem['product_id'])) {
                    $product = Product::where('manager_id', $manager->id)->find($saleItem['product_id']);
                    if ($product && $product->track_stock) {
                        StockMovement::create([
                            'manager_id' => $manager->id,
                            'product_id' => $product->id,
                            'store_id' => $store->id,
                            'user_id' => $data['user_id'] ?? null,
                            'quantity' => -1 * $saleItem['quantity'],
                            'type' => 'sale',
                            'reason' => 'sale',
                            'ref_type' => 'sale',
                            'ref_id' => $sale->id,
                            'occurred_at' => $sale->ordered_at,
                        ]);
                    }
                }
            }

            $paidTotal = 0.0;
            if (!empty($data['payments'])) {
                foreach ($data['payments'] as $paymentData) {
                    $method = PaymentMethod::where(function ($query) use ($manager) {
                        $query->whereNull('manager_id')
                            ->orWhere('manager_id', $manager->id);
                    })->findOrFail($paymentData['payment_method_id']);
                    $paidTotal += (float) $paymentData['amount'];

                    Payment::create([
                        'sale_id' => $sale->id,
                        'payment_method_id' => $method->id,
                        'amount' => $paymentData['amount'],
                        'reference' => $paymentData['reference'] ?? null,
                        'paid_at' => $paymentData['paid_at'] ?? now(),
                    ]);
                }
            }

            $requestedStatus = strtolower((string) ($data['status'] ?? ''));
            if ($requestedStatus === 'onhold') {
                $sale->status = 'onhold';
            } elseif ($requestedStatus === 'pos' && $paidTotal <= 0) {
                $sale->status = 'pos';
            } elseif ($paidTotal >= $grandTotal && $grandTotal > 0) {
                $sale->status = 'paid';
            } elseif ($paidTotal > 0) {
                $sale->status = 'partial';
            } else {
                $sale->status = 'unpaid';
            }

            $loyaltyPointsEarned = 0;
            $loyaltyPointsRedeemed = 0;
            $loyaltyAmountRedeemed = 0.0;
            $loyaltyEnabled = (bool) ($manager->loyalty_enabled ?? false);
            $pointsPerOrder = (int) ($manager->loyalty_points_per_order ?? 0);
            $pointsPerItem = (int) ($manager->loyalty_points_per_item ?? 0);
            $amountPerPoint = (float) ($manager->loyalty_amount_per_point ?? 0);
            $pointValue = (float) ($manager->loyalty_point_value ?? 0);

            if ($loyaltyEnabled && $customer && $allowLoyaltyRedeem) {
                if ($sale->status !== 'unpaid') {
                    $requestedRedeemAmount = (float) ($data['loyalty_redeem_amount'] ?? 0);
                    $requestedRedeemPoints = (int) ($data['loyalty_redeem_points'] ?? 0);
                    if ($pointValue > 0) {
                        $maxByBalance = $customer->loyalty_points_balance * $pointValue;
                        $requestedAmount = $requestedRedeemAmount > 0
                            ? $requestedRedeemAmount
                            : ($requestedRedeemPoints * $pointValue);
                        $allowedAmount = min($requestedAmount, $maxByBalance, $discountTotal, $grandTotal);
                        if ($allowedAmount > 0) {
                            $loyaltyPointsRedeemed = (int) floor($allowedAmount / $pointValue);
                            $loyaltyAmountRedeemed = $loyaltyPointsRedeemed * $pointValue;
                        }
                    }
                }

                if ($sale->status === 'paid') {
                    if ($pointsPerOrder > 0) {
                        $loyaltyPointsEarned += $pointsPerOrder;
                    }
                    if ($pointsPerItem > 0 && $totalQuantity > 0) {
                        $loyaltyPointsEarned += (int) floor($totalQuantity * $pointsPerItem);
                    }
                    if ($amountPerPoint > 0) {
                        $loyaltyPointsEarned += (int) floor($grandTotal / $amountPerPoint);
                    }
                }
            }

            $sale->loyalty_points_earned = $loyaltyPointsEarned;
            $sale->loyalty_points_redeemed = $loyaltyPointsRedeemed;
            $sale->loyalty_amount_redeemed = $loyaltyAmountRedeemed;
            $sale->save();

            if ($customer && ($loyaltyPointsEarned > 0 || $loyaltyPointsRedeemed > 0)) {
                $balance = (int) ($customer->loyalty_points_balance ?? 0);
                $earnedTotal = (int) ($customer->loyalty_points_earned_total ?? 0);
                $redeemedTotal = (int) ($customer->loyalty_points_redeemed_total ?? 0);

                if ($loyaltyPointsEarned > 0) {
                    $balance += $loyaltyPointsEarned;
                    $earnedTotal += $loyaltyPointsEarned;
                }
                if ($loyaltyPointsRedeemed > 0) {
                    $balance -= $loyaltyPointsRedeemed;
                    $redeemedTotal += $loyaltyPointsRedeemed;
                }
                if ($balance < 0) {
                    $balance = 0;
                }
                $customer->loyalty_points_balance = $balance;
                $customer->loyalty_points_earned_total = $earnedTotal;
                $customer->loyalty_points_redeemed_total = $redeemedTotal;
                $customer->save();
            }

            $sale->load(['items', 'payments']);

            return response()->json($sale, 201);
        });
    }
}
