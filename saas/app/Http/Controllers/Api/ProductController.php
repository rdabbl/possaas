<?php

namespace App\Http\Controllers\Api;

use App\Models\Product;
use App\Models\Store;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class ProductController extends BaseApiController
{
    public function index(Request $request)
    {
        $manager = $this->managerOrFail($request);
        $perPage = (int) $request->query('per_page', 20);
        $storeId = $request->query('store_id');
        $categoryId = $request->query('category_id');
        $search = $request->query('search');
        $store = null;
        if ($storeId) {
            $store = Store::where('manager_id', $manager->id)->find($storeId);
            if (!$store) {
                return response()->json(['message' => 'Store not found.'], 404);
            }
        }

        $query = Product::where('manager_id', $manager->id)
            ->with(['optionLinks' => function ($q) {
                $q->where('product_options.is_active', true)->orderBy('name');
            }])
            ->orderBy('id', 'desc');

        if ($categoryId) {
            $query->where('category_id', $categoryId);
        }

        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', '%' . $search . '%')
                    ->orWhere('sku', 'like', '%' . $search . '%')
                    ->orWhere('barcode', 'like', '%' . $search . '%');
            });
        }

        if ($storeId && $store && $store->stock_enabled) {
            $query->withSum(['stockMovements as stock_quantity' => function ($q) use ($storeId) {
                $q->where('store_id', $storeId);
            }], 'quantity');
        } elseif (!$storeId) {
            $query->withSum('stockMovements as stock_quantity', 'quantity');
        }

        $products = $query->paginate($perPage);

        $products->getCollection()->transform(function ($product) use ($store) {
            if ($product->track_stock && (!$store || $store->stock_enabled)) {
                $product->stock = [
                    'quantity' => (float) ($product->stock_quantity ?? 0),
                ];
            }
            return $product;
        });

        return response()->json($products);
    }

    public function show(Request $request, int $id)
    {
        $manager = $this->managerOrFail($request);
        $storeId = $request->query('store_id');
        $store = null;
        if ($storeId) {
            $store = Store::where('manager_id', $manager->id)->find($storeId);
            if (!$store) {
                return response()->json(['message' => 'Store not found.'], 404);
            }
        }

        $query = Product::where('manager_id', $manager->id)
            ->with(['optionLinks' => function ($q) {
                $q->where('product_options.is_active', true)->orderBy('name');
            }]);
        if ($storeId && $store && $store->stock_enabled) {
            $query->withSum(['stockMovements as stock_quantity' => function ($q) use ($storeId) {
                $q->where('store_id', $storeId);
            }], 'quantity');
        } elseif (!$storeId) {
            $query->withSum('stockMovements as stock_quantity', 'quantity');
        }

        $product = $query->findOrFail($id);
        if ($product->track_stock && (!$store || $store->stock_enabled)) {
            $product->stock = [
                'quantity' => (float) ($product->stock_quantity ?? 0),
            ];
        }

        return response()->json($product);
    }

    public function store(Request $request)
    {
        $manager = $this->managerOrFail($request);

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'category_id' => [
                'nullable',
                Rule::exists('categories', 'id')->where('manager_id', $manager->id),
            ],
            'tax_id' => [
                'nullable',
                Rule::exists('taxes', 'id')->where('manager_id', $manager->id),
            ],
            'sku' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('products', 'sku')->where('manager_id', $manager->id),
            ],
            'barcode' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('products', 'barcode')->where('manager_id', $manager->id),
            ],
            'description' => ['nullable', 'string'],
            'price' => ['nullable', 'numeric', 'min:0'],
            'cost' => ['nullable', 'numeric', 'min:0'],
            'track_stock' => ['nullable', 'boolean'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = $manager->id;
        $data['uuid'] = (string) Str::uuid();
        $data['price'] = $data['price'] ?? 0;
        $data['cost'] = $data['cost'] ?? 0;
        $data['track_stock'] = $data['track_stock'] ?? true;
        $data['is_active'] = $data['is_active'] ?? true;

        $product = Product::create($data);

        return response()->json($product, 201);
    }

    public function update(Request $request, int $id)
    {
        $manager = $this->managerOrFail($request);

        $product = Product::where('manager_id', $manager->id)->findOrFail($id);

        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'category_id' => [
                'nullable',
                Rule::exists('categories', 'id')->where('manager_id', $manager->id),
            ],
            'tax_id' => [
                'nullable',
                Rule::exists('taxes', 'id')->where('manager_id', $manager->id),
            ],
            'sku' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('products', 'sku')->where('manager_id', $manager->id)->ignore($product->id),
            ],
            'barcode' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('products', 'barcode')->where('manager_id', $manager->id)->ignore($product->id),
            ],
            'description' => ['nullable', 'string'],
            'price' => ['nullable', 'numeric', 'min:0'],
            'cost' => ['nullable', 'numeric', 'min:0'],
            'track_stock' => ['nullable', 'boolean'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $product->update($data);

        return response()->json($product);
    }

    public function destroy(Request $request, int $id)
    {
        $manager = $this->managerOrFail($request);

        $product = Product::where('manager_id', $manager->id)->findOrFail($id);
        $product->delete();

        return response()->json(['message' => 'Deleted']);
    }
}
