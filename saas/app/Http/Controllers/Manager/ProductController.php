<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\ProductOption;
use App\Models\Product;
use App\Models\Tax;
use App\Services\ProductImportService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $products = Product::where('manager_id', $managerId)
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('manager.products.index', compact('products'));
    }

    public function importForm()
    {
        return view('manager.products.import');
    }

    public function import(Request $request, ProductImportService $importService)
    {
        $managerId = $request->user()->manager_id;
        $request->validate([
            'file' => ['required', 'file', 'mimes:csv,txt'],
        ]);

        $result = $importService->import($request->file('file'), $managerId);

        return redirect()->route('manager.products.index')
            ->with('success', sprintf(
                'Import finished. Created: %d, Updated: %d, Skipped: %d.',
                $result['created'],
                $result['updated'],
                $result['skipped']
            ))
            ->with('import_errors', $result['errors']);
    }

    public function create(Request $request)
    {
        $managerId = $request->user()->manager_id;
        $categories = Category::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })->orderBy('name')->get();
        $taxes = Tax::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })->orderBy('name')->get();
        $options = ProductOption::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })->orderBy('name')->get();

        return view('manager.products.create', compact('categories', 'taxes', 'options'));
    }

    public function store(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'category_id' => [
                'nullable',
                Rule::exists('categories', 'id')->where(function ($query) use ($managerId) {
                    $query->whereNull('manager_id')
                        ->orWhere('manager_id', $managerId);
                }),
            ],
            'tax_id' => [
                'nullable',
                Rule::exists('taxes', 'id')->where(function ($query) use ($managerId) {
                    $query->whereNull('manager_id')
                        ->orWhere('manager_id', $managerId);
                }),
            ],
            'sku' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('products', 'sku')->where('manager_id', $managerId),
            ],
            'barcode' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('products', 'barcode')->where('manager_id', $managerId),
            ],
            'description' => ['nullable', 'string'],
            'options' => ['nullable', 'array'],
            'options.*' => ['nullable', 'numeric', 'min:0'],
            'image' => ['nullable', 'image', 'max:4096'],
            'price' => ['nullable', 'numeric', 'min:0'],
            'cost' => ['nullable', 'numeric', 'min:0'],
            'track_stock' => ['nullable', 'boolean'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $optionsInput = $request->input('options', []);
        $data['manager_id'] = $managerId;
        $data['uuid'] = (string) Str::uuid();
        $data['price'] = $data['price'] ?? 0;
        $data['cost'] = $data['cost'] ?? 0;
        $data['track_stock'] = $data['track_stock'] ?? true;
        $data['is_active'] = $data['is_active'] ?? true;
        unset($data['options']);

        if ($request->hasFile('image')) {
            $data['image_path'] = $request->file('image')->store('products', 'public');
        }

        $product = Product::create($data);
        $this->syncOptions($product, $optionsInput, $managerId);

        return redirect()->route('manager.products.index')
            ->with('success', 'Product created.');
    }

    public function edit(Request $request, Product $product)
    {
        $managerId = $request->user()->manager_id;

        if ($product->manager_id !== $managerId) {
            abort(403);
        }

        $categories = Category::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })->orderBy('name')->get();
        $taxes = Tax::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })->orderBy('name')->get();
        $options = ProductOption::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })->orderBy('name')->get();

        $variants = $product->variants()->orderBy('id')->get();

        $product->load('optionLinks');

        return view('manager.products.edit', compact('product', 'categories', 'taxes', 'variants', 'options'));
    }

    public function update(Request $request, Product $product)
    {
        $managerId = $request->user()->manager_id;

        if ($product->manager_id !== $managerId) {
            abort(403);
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'category_id' => [
                'nullable',
                Rule::exists('categories', 'id')->where(function ($query) use ($managerId) {
                    $query->whereNull('manager_id')
                        ->orWhere('manager_id', $managerId);
                }),
            ],
            'tax_id' => [
                'nullable',
                Rule::exists('taxes', 'id')->where(function ($query) use ($managerId) {
                    $query->whereNull('manager_id')
                        ->orWhere('manager_id', $managerId);
                }),
            ],
            'sku' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('products', 'sku')->where('manager_id', $managerId)->ignore($product->id),
            ],
            'barcode' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('products', 'barcode')->where('manager_id', $managerId)->ignore($product->id),
            ],
            'description' => ['nullable', 'string'],
            'options' => ['nullable', 'array'],
            'options.*' => ['nullable', 'numeric', 'min:0'],
            'image' => ['nullable', 'image', 'max:4096'],
            'price' => ['nullable', 'numeric', 'min:0'],
            'cost' => ['nullable', 'numeric', 'min:0'],
            'track_stock' => ['nullable', 'boolean'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $optionsInput = $request->input('options', []);
        if ($request->hasFile('image')) {
            if ($product->image_path) {
                Storage::disk('public')->delete($product->image_path);
            }
            $data['image_path'] = $request->file('image')->store('products', 'public');
            $data['image_url'] = null;
        }

        unset($data['options']);
        $product->update($data);
        $this->syncOptions($product, $optionsInput, $managerId);

        return redirect()->route('manager.products.index')
            ->with('success', 'Product updated.');
    }

    public function destroy(Request $request, Product $product)
    {
        $managerId = $request->user()->manager_id;

        if ($product->manager_id !== $managerId) {
            abort(403);
        }

        if ($product->image_path) {
            Storage::disk('public')->delete($product->image_path);
        }
        $product->delete();

        return redirect()->route('manager.products.index')
            ->with('success', 'Product deleted.');
    }

    public function duplicate(Request $request, Product $product)
    {
        $managerId = $request->user()->manager_id;
        if ($product->manager_id !== $managerId) {
            abort(403);
        }

        $product->load(['optionLinks', 'variants']);
        $copy = $product->replicate();
        $copy->manager_id = $managerId;
        $copy->uuid = (string) Str::uuid();
        $copy->name = $this->copyName($product->name);
        $copy->sku = null;
        $copy->barcode = null;
        $copy->save();

        if ($product->optionLinks->isNotEmpty()) {
            $sync = $product->optionLinks
                ->mapWithKeys(fn ($option) => [
                    $option->id => ['quantity' => $option->pivot->quantity],
                ])
                ->all();
            $copy->optionLinks()->sync($sync);
        }

        foreach ($product->variants as $variant) {
            $variantCopy = $variant->replicate();
            $variantCopy->manager_id = $managerId;
            $variantCopy->product_id = $copy->id;
            $variantCopy->uuid = (string) Str::uuid();
            $variantCopy->sku = null;
            $variantCopy->barcode = null;
            $variantCopy->save();
        }

        return redirect()->route('manager.products.edit', $copy)
            ->with('success', 'Product duplicated.');
    }

    private function syncOptions(Product $product, array $input, int $managerId): void
    {
        $ids = array_filter(array_keys($input), fn ($id) => is_numeric($id));
        if (empty($ids)) {
            $product->optionLinks()->sync([]);
            return;
        }

        $validIds = ProductOption::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })
            ->whereIn('id', $ids)
            ->pluck('id')
            ->map(fn ($id) => (string) $id)
            ->all();
        $validSet = array_flip($validIds);
        $invalid = array_diff(array_map('strval', $ids), $validIds);
        if (!empty($invalid)) {
            throw ValidationException::withMessages([
                'options' => ['Invalid option selection.'],
            ]);
        }

        $sync = [];
        foreach ($input as $id => $qty) {
            $id = (string) $id;
            if (!isset($validSet[$id])) {
                continue;
            }
            $quantity = is_numeric($qty) ? (float) $qty : 0;
            if ($quantity > 0) {
                $sync[(int) $id] = ['quantity' => $quantity];
            }
        }

        $product->optionLinks()->sync($sync);
    }

    private function copyName(string $base): string
    {
        return trim($base) . ' (Copy)';
    }
}
