<?php

namespace App\Http\Controllers\Tenant;

use App\Http\Controllers\Controller;
use App\Models\IngredientCategory;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class IngredientCategoryController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->user()->tenant_id;

        $categories = IngredientCategory::where('tenant_id', $tenantId)
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('tenant.ingredient_categories.index', compact('categories'));
    }

    public function create()
    {
        return view('tenant.ingredient_categories.create');
    }

    public function store(Request $request)
    {
        $tenantId = $request->user()->tenant_id;

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('ingredient_categories', 'name')->where('tenant_id', $tenantId),
            ],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['tenant_id'] = $tenantId;
        $data['is_active'] = $data['is_active'] ?? true;

        IngredientCategory::create($data);

        return redirect()->route('tenant.ingredient_categories.index')
            ->with('success', 'Ingredient category created.');
    }

    public function edit(Request $request, IngredientCategory $ingredientCategory)
    {
        if ($ingredientCategory->tenant_id !== $request->user()->tenant_id) {
            abort(403);
        }

        return view('tenant.ingredient_categories.edit', compact('ingredientCategory'));
    }

    public function update(Request $request, IngredientCategory $ingredientCategory)
    {
        $tenantId = $request->user()->tenant_id;
        if ($ingredientCategory->tenant_id !== $tenantId) {
            abort(403);
        }

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('ingredient_categories', 'name')->where('tenant_id', $tenantId)->ignore($ingredientCategory->id),
            ],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $ingredientCategory->update($data);

        return redirect()->route('tenant.ingredient_categories.index')
            ->with('success', 'Ingredient category updated.');
    }

    public function destroy(Request $request, IngredientCategory $ingredientCategory)
    {
        if ($ingredientCategory->tenant_id !== $request->user()->tenant_id) {
            abort(403);
        }

        $ingredientCategory->delete();

        return redirect()->route('tenant.ingredient_categories.index')
            ->with('success', 'Ingredient category deleted.');
    }
}
