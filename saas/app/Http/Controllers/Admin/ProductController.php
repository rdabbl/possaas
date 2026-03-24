<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Ingredient;
use App\Models\Product;
use App\Models\Tax;
use App\Models\Manager;
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
        $managerId = $request->query('manager_id');

        $query = Product::query()->with(['manager', 'category', 'tax'])->orderBy('id', 'desc');
        if ($managerId) {
            $query->where('manager_id', $managerId);
        }

        $products = $query->paginate(20)->withQueryString();
        $managers = Manager::orderBy('name')->get();

        return view('admin.products.index', compact('products', 'managers', 'managerId'));
    }

    public function importForm()
    {
        $managers = Manager::orderBy('name')->get();

        return view('admin.products.import', compact('managers'));
    }

    public function import(Request $request, ProductImportService $importService)
    {
        $data = $request->validate([
            'manager_id' => ['required', 'exists:managers,id'],
            'file' => ['required', 'file', 'mimes:csv,txt'],
        ]);

        $result = $importService->import($request->file('file'), (int) $data['manager_id']);

        return redirect()->route('admin.products.index')
            ->with('success', sprintf(
                'Import finished. Created: %d, Updated: %d, Skipped: %d.',
                $result['created'],
                $result['updated'],
                $result['skipped']
            ))
            ->with('import_errors', $result['errors']);
    }

    public function create()
    {
        $managers = Manager::orderBy('name')->get();
        $categories = Category::with('manager')->orderBy('name')->get();
        $taxes = Tax::with('manager')->orderBy('name')->get();
        $ingredients = Ingredient::with('manager')->orderBy('name')->get();

        return view('admin.products.create', compact('managers', 'categories', 'taxes', 'ingredients'));
    }

    public function store(Request $request)
    {
        $managerId = $request->input('manager_id');

        $data = $request->validate([
            'manager_id' => ['required', 'exists:managers,id'],
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
            'ingredients' => ['nullable', 'array'],
            'ingredients.*' => ['nullable', 'numeric', 'min:0'],
            'image' => ['nullable', 'image', 'max:4096'],
            'price' => ['nullable', 'numeric', 'min:0'],
            'cost' => ['nullable', 'numeric', 'min:0'],
            'track_stock' => ['nullable', 'boolean'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $ingredientsInput = $request->input('ingredients', []);
        $data['uuid'] = (string) Str::uuid();
        $data['price'] = $data['price'] ?? 0;
        $data['cost'] = $data['cost'] ?? 0;
        $data['track_stock'] = $data['track_stock'] ?? true;
        $data['is_active'] = $data['is_active'] ?? true;
        unset($data['ingredients']);

        if ($request->hasFile('image')) {
            $data['image_path'] = $request->file('image')->store('products', 'public');
        }

        $product = Product::create($data);
        $this->syncIngredients($product, $ingredientsInput, $managerId);

        return redirect()->route('admin.products.index')
            ->with('success', 'Product created.');
    }

    public function edit(Product $product)
    {
        $categories = Category::where(function ($query) use ($product) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $product->manager_id);
        })->orderBy('name')->get();
        $taxes = Tax::where(function ($query) use ($product) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $product->manager_id);
        })->orderBy('name')->get();
        $ingredients = Ingredient::where(function ($query) use ($product) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $product->manager_id);
        })->orderBy('name')->get();

        $product->load('ingredientLinks');

        return view('admin.products.edit', compact('product', 'categories', 'taxes', 'ingredients'));
    }

    public function update(Request $request, Product $product)
    {
        $managerId = $product->manager_id;

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
            'ingredients' => ['nullable', 'array'],
            'ingredients.*' => ['nullable', 'numeric', 'min:0'],
            'image' => ['nullable', 'image', 'max:4096'],
            'price' => ['nullable', 'numeric', 'min:0'],
            'cost' => ['nullable', 'numeric', 'min:0'],
            'track_stock' => ['nullable', 'boolean'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $ingredientsInput = $request->input('ingredients', []);
        if ($request->hasFile('image')) {
            if ($product->image_path) {
                Storage::disk('public')->delete($product->image_path);
            }
            $data['image_path'] = $request->file('image')->store('products', 'public');
            $data['image_url'] = null;
        }

        unset($data['ingredients']);
        $product->update($data);
        $this->syncIngredients($product, $ingredientsInput, $managerId);

        return redirect()->route('admin.products.index')
            ->with('success', 'Product updated.');
    }

    public function destroy(Product $product)
    {
        if ($product->image_path) {
            Storage::disk('public')->delete($product->image_path);
        }
        $product->delete();

        return redirect()->route('admin.products.index')
            ->with('success', 'Product deleted.');
    }

    private function syncIngredients(Product $product, array $input, int $managerId): void
    {
        $ids = array_filter(array_keys($input), fn ($id) => is_numeric($id));
        if (empty($ids)) {
            $product->ingredientLinks()->sync([]);
            return;
        }

        $validIds = Ingredient::where(function ($query) use ($managerId) {
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
                'ingredients' => ['Invalid ingredient selection.'],
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

        $product->ingredientLinks()->sync($sync);
    }
}
