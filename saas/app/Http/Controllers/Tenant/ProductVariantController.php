<?php

namespace App\Http\Controllers\Tenant;

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
        $tenantId = $request->user()->tenant_id;

        if ($product->tenant_id !== $tenantId) {
            abort(403);
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'sku' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('product_variants', 'sku')->where('tenant_id', $tenantId),
            ],
            'barcode' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('product_variants', 'barcode')->where('tenant_id', $tenantId),
            ],
            'price' => ['nullable', 'numeric', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['tenant_id'] = $tenantId;
        $data['product_id'] = $product->id;
        $data['uuid'] = (string) Str::uuid();
        $data['is_active'] = $data['is_active'] ?? true;

        ProductVariant::create($data);

        return redirect()->route('tenant.products.edit', $product)
            ->with('success', 'Variant created.');
    }

    public function update(Request $request, Product $product, ProductVariant $variant)
    {
        $tenantId = $request->user()->tenant_id;

        if ($product->tenant_id !== $tenantId || $variant->tenant_id !== $tenantId || $variant->product_id !== $product->id) {
            abort(403);
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'sku' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('product_variants', 'sku')->where('tenant_id', $tenantId)->ignore($variant->id),
            ],
            'barcode' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('product_variants', 'barcode')->where('tenant_id', $tenantId)->ignore($variant->id),
            ],
            'price' => ['nullable', 'numeric', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $variant->update($data);

        return redirect()->route('tenant.products.edit', $product)
            ->with('success', 'Variant updated.');
    }

    public function destroy(Request $request, Product $product, ProductVariant $variant)
    {
        $tenantId = $request->user()->tenant_id;

        if ($product->tenant_id !== $tenantId || $variant->tenant_id !== $tenantId || $variant->product_id !== $product->id) {
            abort(403);
        }

        $variant->delete();

        return redirect()->route('tenant.products.edit', $product)
            ->with('success', 'Variant deleted.');
    }
}
