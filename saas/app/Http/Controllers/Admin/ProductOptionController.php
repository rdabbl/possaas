<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ProductOption;
use App\Models\ProductOptionCategory;
use App\Models\Manager;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class ProductOptionController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->query('manager_id');

        $query = ProductOption::query()->with('manager')->orderBy('id', 'desc');
        if ($managerId) {
            $query->where('manager_id', $managerId);
        }

        $options = $query->paginate(20)->withQueryString();
        $managers = Manager::orderBy('name')->get();

        return view('admin.product_options.index', compact('options', 'managers', 'managerId'));
    }

    public function create()
    {
        $categories = ProductOptionCategory::whereNull('manager_id')->orderBy('name')->get();

        return view('admin.product_options.create', compact('categories'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'product_option_category_id' => [
                'nullable',
                Rule::exists('product_option_categories', 'id')->whereNull('manager_id'),
            ],
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('product_options', 'name')->whereNull('manager_id'),
            ],
            'image' => ['nullable', 'image', 'max:4096'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = null;
        $data['is_active'] = $data['is_active'] ?? true;
        if ($request->hasFile('image')) {
            $data['image_path'] = $request->file('image')->store('product-options', 'public');
        }

        ProductOption::create($data);

        return redirect()->route('admin.product_options.index')
            ->with('success', 'Product option created.');
    }

    public function edit(ProductOption $productOption)
    {
        $categories = ProductOptionCategory::where(function ($query) use ($productOption) {
            if ($productOption->manager_id) {
                $query->whereNull('manager_id')
                    ->orWhere('manager_id', $productOption->manager_id);
                return;
            }
            $query->whereNull('manager_id');
        })
            ->orderBy('name')
            ->get();

        return view('admin.product_options.edit', compact('productOption', 'categories'));
    }

    public function update(Request $request, ProductOption $productOption)
    {
        $managerId = $productOption->manager_id;
        $categoryScope = function ($query) use ($managerId) {
            if ($managerId) {
                $query->whereNull('manager_id')
                    ->orWhere('manager_id', $managerId);
                return;
            }
            $query->whereNull('manager_id');
        };
        $nameScope = function ($query) use ($managerId) {
            if ($managerId) {
                $query->where('manager_id', $managerId);
                return;
            }
            $query->whereNull('manager_id');
        };

        $data = $request->validate([
            'product_option_category_id' => [
                'nullable',
                Rule::exists('product_option_categories', 'id')->where($categoryScope),
            ],
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('product_options', 'name')->where($nameScope)->ignore($productOption->id),
            ],
            'image' => ['nullable', 'image', 'max:4096'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        if ($request->hasFile('image')) {
            if ($productOption->image_path) {
                Storage::disk('public')->delete($productOption->image_path);
            }
            $data['image_path'] = $request->file('image')->store('product-options', 'public');
        }

        $productOption->update($data);

        return redirect()->route('admin.product_options.index')
            ->with('success', 'Product option updated.');
    }

    public function destroy(ProductOption $productOption)
    {
        if ($productOption->image_path) {
            Storage::disk('public')->delete($productOption->image_path);
        }
        $productOption->delete();

        return redirect()->route('admin.product_options.index')
            ->with('success', 'Product option deleted.');
    }
}
