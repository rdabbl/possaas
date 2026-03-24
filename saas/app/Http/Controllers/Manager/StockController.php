<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\Store;
use Illuminate\Http\Request;

class StockController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $stores = Store::where('manager_id', $managerId)->orderBy('name')->get();
        $products = Product::where('manager_id', $managerId)->orderBy('name')->get();

        return view('manager.stock.index', compact('stores', 'products'));
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
        ]);

        $product->update($data);

        return redirect()->route('manager.stock.index')
            ->with('success', 'Product stock setting updated.');
    }
}
