<?php

namespace App\Http\Controllers\Tenant;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\Store;
use Illuminate\Http\Request;

class StockController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->user()->tenant_id;

        $stores = Store::where('tenant_id', $tenantId)->orderBy('name')->get();
        $products = Product::where('tenant_id', $tenantId)->orderBy('name')->get();

        return view('tenant.stock.index', compact('stores', 'products'));
    }

    public function updateStore(Request $request, Store $store)
    {
        $tenantId = $request->user()->tenant_id;

        if ($store->tenant_id !== $tenantId) {
            abort(403);
        }

        $data = $request->validate([
            'stock_enabled' => ['required', 'boolean'],
        ]);

        $store->update($data);

        return redirect()->route('tenant.stock.index')
            ->with('success', 'Store stock setting updated.');
    }

    public function updateProduct(Request $request, Product $product)
    {
        $tenantId = $request->user()->tenant_id;

        if ($product->tenant_id !== $tenantId) {
            abort(403);
        }

        $data = $request->validate([
            'track_stock' => ['required', 'boolean'],
        ]);

        $product->update($data);

        return redirect()->route('tenant.stock.index')
            ->with('success', 'Product stock setting updated.');
    }
}
