<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\StockMovement;
use App\Models\Store;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class StockController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $stores = Store::where('manager_id', $managerId)->orderBy('name')->get();
        $selectedStoreId = (int) $request->query('store_id', $stores->first()?->id ?? 0);
        if ($selectedStoreId > 0 && !$stores->firstWhere('id', $selectedStoreId)) {
            $selectedStoreId = (int) ($stores->first()?->id ?? 0);
        }

        $productsQuery = Product::where('manager_id', $managerId)->orderBy('name');
        if ($selectedStoreId > 0) {
            $productsQuery->withSum(['stockMovements as stock_quantity' => function ($q) use ($selectedStoreId) {
                $q->where('store_id', $selectedStoreId);
            }], 'quantity');
        } else {
            $productsQuery->withSum('stockMovements as stock_quantity', 'quantity');
        }
        $products = $productsQuery->get();

        return view('manager.stock.index', compact('stores', 'products', 'selectedStoreId'));
    }

    public function updateStore(Request $request, Store $store)
    {
        $managerId = $request->user()->manager_id;

        if ($store->manager_id !== $managerId) {
            abort(403);
        }

        $data = $request->validate([
            'stock_enabled' => ['required', 'boolean'],
        ]);

        $store->update($data);

        return redirect()->route('manager.stock.index')
            ->with('success', 'Store stock setting updated.');
    }

    public function updateProduct(Request $request, Product $product)
    {
        $managerId = $request->user()->manager_id;

        if ($product->manager_id !== $managerId) {
            abort(403);
        }

        $data = $request->validate([
            'track_stock' => ['required', 'boolean'],
            'store_id' => [
                'nullable',
                Rule::exists('stores', 'id')->where('manager_id', $managerId),
            ],
            'stock_quantity' => ['nullable', 'numeric', 'min:0'],
        ]);

        $product->update([
            'track_stock' => (bool) $data['track_stock'],
        ]);

        if (array_key_exists('stock_quantity', $data) && $data['stock_quantity'] !== null) {
            $storeId = !empty($data['store_id']) ? (int) $data['store_id'] : null;
            $currentQuantity = (float) $product->stockMovements()
                ->when($storeId, fn ($q) => $q->where('store_id', $storeId))
                ->sum('quantity');
            $targetQuantity = (float) $data['stock_quantity'];
            $delta = round($targetQuantity - $currentQuantity, 3);

            if (abs($delta) > 0.0001) {
                StockMovement::create([
                    'manager_id' => $managerId,
                    'product_id' => $product->id,
                    'store_id' => $storeId,
                    'user_id' => $request->user()->id,
                    'quantity' => $delta,
                    'type' => 'adjust',
                    'reason' => 'Manual stock set from manager panel',
                    'occurred_at' => now(),
                ]);
            }
        }

        $redirectParams = [];
        if (!empty($data['store_id'])) {
            $redirectParams['store_id'] = (int) $data['store_id'];
        }

        return redirect()->route('manager.stock.index', $redirectParams)
            ->with('success', 'Product stock updated.');
    }
}
