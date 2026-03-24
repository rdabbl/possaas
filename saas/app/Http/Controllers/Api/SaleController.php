<?php

namespace App\Http\Controllers\Api;

use App\Models\Payment;
use App\Models\PaymentMethod;
use App\Models\Product;
use App\Models\ProductVariant;
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
                Rule::exists('devices', 'id')->where('manager_id', $manager->id),
            ],
            'user_id' => ['nullable', 'integer'],
            'customer_id' => [
                'nullable',
                Rule::exists('customers', 'id')->where('manager_id', $manager->id),
            ],
            'currency' => ['nullable', 'string', 'size:3'],
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
            'items.*.ingredients' => ['nullable', 'array'],
            'items.*.ingredients.*.id' => ['nullable', 'integer'],
            'items.*.ingredients.*.name' => ['nullable', 'string', 'max:255'],
            'items.*.ingredients.*.quantity' => ['nullable', 'numeric', 'min:0'],
            'payments' => ['nullable', 'array'],
            'payments.*.payment_method_id' => ['required_with:payments', 'integer'],
            'payments.*.amount' => ['required_with:payments', 'numeric', 'min:0'],
            'payments.*.reference' => ['nullable', 'string', 'max:255'],
            'payments.*.paid_at' => ['nullable', 'date'],
        ]);

        $store = Store::with('currency')
            ->where('manager_id', $manager->id)
            ->findOrFail($data['store_id']);

        return DB::transaction(function () use ($manager, $data, $store) {
            $saleItems = [];
            $subtotal = 0.0;
            $discountTotal = 0.0;
            $taxTotal = 0.0;

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
                $ingredients = $item['ingredients'] ?? null;
                if (is_array($ingredients)) {
                    $ingredients = array_values(array_filter($ingredients, function ($ingredient) {
                        if (!is_array($ingredient)) {
                            return false;
                        }
                        $qty = $ingredient['quantity'] ?? 0;
                        return is_numeric($qty) && (float) $qty > 0;
                    }));
                } else {
                    $ingredients = null;
                }

                $lineSubtotal = $unitPrice * $quantity;
                $lineTotal = $lineSubtotal - $discountAmount + $taxAmount;

                $subtotal += $lineSubtotal;
                $discountTotal += $discountAmount;
                $taxTotal += $taxAmount;

                $saleItems[] = [
                    'product_id' => $product?->id,
                    'product_variant_id' => $variant?->id,
                    'name' => $name,
                    'sku' => $sku,
                    'quantity' => $quantity,
                    'unit_price' => $unitPrice,
                    'discount_amount' => $discountAmount,
                    'tax_amount' => $taxAmount,
                    'ingredients' => $ingredients,
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
                'status' => 'unpaid',
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

            if ($paidTotal >= $grandTotal && $grandTotal > 0) {
                $sale->status = 'paid';
            } elseif ($paidTotal > 0) {
                $sale->status = 'partial';
            } else {
                $sale->status = 'unpaid';
            }

            $sale->save();

            return response()->json($sale->load(['items', 'payments']), 201);
        });
    }
}
