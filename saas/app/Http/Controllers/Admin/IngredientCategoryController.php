<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\IngredientCategory;
use App\Models\Tenant;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class IngredientCategoryController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->query('tenant_id');

        $query = IngredientCategory::query()->with('tenant')->orderBy('id', 'desc');
        if ($tenantId) {
            $query->where('tenant_id', $tenantId);
        }

        $categories = $query->paginate(20)->withQueryString();
        $tenants = Tenant::orderBy('name')->get();

        return view('admin.ingredient_categories.index', compact('categories', 'tenants', 'tenantId'));
    }

    public function create()
    {
        $tenants = Tenant::orderBy('name')->get();

        return view('admin.ingredient_categories.create', compact('tenants'));
    }

    public function store(Request $request)
    {
        $tenantId = $request->input('tenant_id');

        $data = $request->validate([
            'tenant_id' => ['required', 'exists:tenants,id'],
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('ingredient_categories', 'name')->where('tenant_id', $tenantId),
            ],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['is_active'] = $data['is_active'] ?? true;

        IngredientCategory::create($data);

        return redirect()->route('admin.ingredient_categories.index')
            ->with('success', 'Ingredient category created.');
    }

    public function edit(IngredientCategory $ingredientCategory)
    {
        return view('admin.ingredient_categories.edit', compact('ingredientCategory'));
    }

    public function update(Request $request, IngredientCategory $ingredientCategory)
    {
        $tenantId = $ingredientCategory->tenant_id;

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

        return redirect()->route('admin.ingredient_categories.index')
            ->with('success', 'Ingredient category updated.');
    }

    public function destroy(IngredientCategory $ingredientCategory)
    {
        $ingredientCategory->delete();

        return redirect()->route('admin.ingredient_categories.index')
            ->with('success', 'Ingredient category deleted.');
    }
}
