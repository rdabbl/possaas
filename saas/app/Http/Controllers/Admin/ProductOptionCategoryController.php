<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ProductOptionCategory;
use App\Models\Manager;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ProductOptionCategoryController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->query('manager_id');

        $query = ProductOptionCategory::query()->with('manager')->orderBy('id', 'desc');
        if ($managerId) {
            $query->where('manager_id', $managerId);
        }

        $categories = $query->paginate(20)->withQueryString();
        $managers = Manager::orderBy('name')->get();

        return view('admin.product_option_categories.index', compact('categories', 'managers', 'managerId'));
    }

    public function create()
    {
        return view('admin.product_option_categories.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('product_option_categories', 'name')->whereNull('manager_id'),
            ],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = null;
        $data['is_active'] = $data['is_active'] ?? true;

        ProductOptionCategory::create($data);

        return redirect()->route('admin.product_option_categories.index')
            ->with('success', 'Product option category created.');
    }

    public function edit(ProductOptionCategory $productOptionCategory)
    {
        return view('admin.product_option_categories.edit', compact('productOptionCategory'));
    }

    public function update(Request $request, ProductOptionCategory $productOptionCategory)
    {
        $managerId = $productOptionCategory->manager_id;
        $nameScope = function ($query) use ($managerId) {
            if ($managerId) {
                $query->where('manager_id', $managerId);
                return;
            }
            $query->whereNull('manager_id');
        };

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('product_option_categories', 'name')->where($nameScope)->ignore($productOptionCategory->id),
            ],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $productOptionCategory->update($data);

        return redirect()->route('admin.product_option_categories.index')
            ->with('success', 'Product option category updated.');
    }

    public function destroy(ProductOptionCategory $productOptionCategory)
    {
        $productOptionCategory->delete();

        return redirect()->route('admin.product_option_categories.index')
            ->with('success', 'Product option category deleted.');
    }
}
