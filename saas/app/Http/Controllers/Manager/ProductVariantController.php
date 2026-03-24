<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\ProductVariant;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class ProductVariantController extends Controller
{
    public function store(Request $request, Product $product)
    {
        $managerId = $request->user()->manager_id;

        if ($product->manager_id !== $managerId) {
            abort(403);
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'sku' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('product_variants', 'sku')->where('manager_id', $managerId),
            ],
            'barcode' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('product_variants', 'barcode')->where('manager_id', $managerId),
            ],
            'price' => ['nullable', 'numeric', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = $managerId;
        $data['product_id'] = $product->id;
        $data['uuid'] = (string) Str::uuid();
        $data['is_active'] = $data['is_active'] ?? true;

        ProductVariant::create($data);

        return redirect()->route('manager.products.edit', $product)
            ->with('success', 'Variant created.');
    }

    public function update(Request $request, Product $product, ProductVariant $variant)
    {
        $managerId = $request->user()->manager_id;

        if ($product->manager_id !== $managerId || $variant->manager_id !== $managerId || $variant->product_id !== $product->id) {
            abort(403);
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'sku' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('product_variants', 'sku')->where('manager_id', $managerId)->ignore($variant->id),
            ],
            'barcode' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('product_variants', 'barcode')->where('manager_id', $managerId)->ignore($variant->id),
            ],
            'price' => ['nullable', 'numeric', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $variant->update($data);

        return redirect()->route('manager.products.edit', $product)
            ->with('success', 'Variant updated.');
    }

    public function destroy(Request $request, Product $product, ProductVariant $variant)
    {
        $managerId = $request->user()->manager_id;

        if ($product->manager_id !== $managerId || $variant->manager_id !== $managerId || $variant->product_id !== $product->id) {
            abort(403);
        }

        $variant->delete();

        return redirect()->route('manager.products.edit', $product)
            ->with('success', 'Variant deleted.');
    }
}
