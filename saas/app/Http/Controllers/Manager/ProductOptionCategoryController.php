<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\ProductOptionCategory;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ProductOptionCategoryController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $categories = ProductOptionCategory::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('manager.product_option_categories.index', compact('categories'));
    }

    public function create()
    {
        return view('manager.product_option_categories.create');
    }

    public function store(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('product_option_categories', 'name')->where('manager_id', $managerId),
            ],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = $managerId;
        $data['is_active'] = $data['is_active'] ?? true;

        ProductOptionCategory::create($data);

        return redirect()->route('manager.product_option_categories.index')
            ->with('success', 'Product option category created.');
    }

    public function edit(Request $request, ProductOptionCategory $productOptionCategory)
    {
        if ($productOptionCategory->manager_id !== $request->user()->manager_id) {
            abort(403);
        }

        return view('manager.product_option_categories.edit', compact('productOptionCategory'));
    }

    public function update(Request $request, ProductOptionCategory $productOptionCategory)
    {
        $managerId = $request->user()->manager_id;
        if ($productOptionCategory->manager_id !== $managerId) {
            abort(403);
        }

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('product_option_categories', 'name')->where('manager_id', $managerId)->ignore($productOptionCategory->id),
            ],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $productOptionCategory->update($data);

        return redirect()->route('manager.product_option_categories.index')
            ->with('success', 'Product option category updated.');
    }

    public function destroy(Request $request, ProductOptionCategory $productOptionCategory)
    {
        if ($productOptionCategory->manager_id !== $request->user()->manager_id) {
            abort(403);
        }

        $productOptionCategory->delete();

        return redirect()->route('manager.product_option_categories.index')
            ->with('success', 'Product option category deleted.');
    }

    public function duplicate(Request $request, ProductOptionCategory $productOptionCategory)
    {
        $managerId = $request->user()->manager_id;
        if ($productOptionCategory->manager_id !== null && $productOptionCategory->manager_id !== $managerId) {
            abort(403);
        }

        $copy = $productOptionCategory->replicate();
        $copy->manager_id = $managerId;
        $copy->name = $this->uniqueName($managerId, $productOptionCategory->name);
        $copy->save();

        return redirect()->route('manager.product_option_categories.index')
            ->with('success', 'Product option category duplicated.');
    }

    private function uniqueName(int $managerId, string $base): string
    {
        $suffix = ' (Copy)';
        $candidate = $base . $suffix;
        $counter = 2;
        while (ProductOptionCategory::where('manager_id', $managerId)->where('name', $candidate)->exists()) {
            $candidate = $base . $suffix . ' ' . $counter;
            $counter++;
        }
        return $candidate;
    }
}
