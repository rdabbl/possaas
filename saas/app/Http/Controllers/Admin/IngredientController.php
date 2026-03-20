<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Ingredient;
use App\Models\IngredientCategory;
use App\Models\Tenant;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class IngredientController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->query('tenant_id');

        $query = Ingredient::query()->with('tenant')->orderBy('id', 'desc');
        if ($tenantId) {
            $query->where('tenant_id', $tenantId);
        }

        $ingredients = $query->paginate(20)->withQueryString();
        $tenants = Tenant::orderBy('name')->get();

        return view('admin.ingredients.index', compact('ingredients', 'tenants', 'tenantId'));
    }

    public function create()
    {
        $tenants = Tenant::orderBy('name')->get();
        $categories = IngredientCategory::with('tenant')->orderBy('name')->get();

        return view('admin.ingredients.create', compact('tenants', 'categories'));
    }

    public function store(Request $request)
    {
        $tenantId = $request->input('tenant_id');

        $data = $request->validate([
            'tenant_id' => ['required', 'exists:tenants,id'],
            'ingredient_category_id' => [
                'nullable',
                Rule::exists('ingredient_categories', 'id')->where('tenant_id', $tenantId),
            ],
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('ingredients', 'name')->where('tenant_id', $tenantId),
            ],
            'image' => ['nullable', 'image', 'max:4096'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['is_active'] = $data['is_active'] ?? true;
        if ($request->hasFile('image')) {
            $data['image_path'] = $request->file('image')->store('ingredients', 'public');
        }

        Ingredient::create($data);

        return redirect()->route('admin.ingredients.index')
            ->with('success', 'Ingredient created.');
    }

    public function edit(Ingredient $ingredient)
    {
        $categories = IngredientCategory::where('tenant_id', $ingredient->tenant_id)
            ->orderBy('name')
            ->get();

        return view('admin.ingredients.edit', compact('ingredient', 'categories'));
    }

    public function update(Request $request, Ingredient $ingredient)
    {
        $tenantId = $ingredient->tenant_id;

        $data = $request->validate([
            'ingredient_category_id' => [
                'nullable',
                Rule::exists('ingredient_categories', 'id')->where('tenant_id', $tenantId),
            ],
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('ingredients', 'name')->where('tenant_id', $tenantId)->ignore($ingredient->id),
            ],
            'image' => ['nullable', 'image', 'max:4096'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        if ($request->hasFile('image')) {
            if ($ingredient->image_path) {
                Storage::disk('public')->delete($ingredient->image_path);
            }
            $data['image_path'] = $request->file('image')->store('ingredients', 'public');
        }

        $ingredient->update($data);

        return redirect()->route('admin.ingredients.index')
            ->with('success', 'Ingredient updated.');
    }

    public function destroy(Ingredient $ingredient)
    {
        if ($ingredient->image_path) {
            Storage::disk('public')->delete($ingredient->image_path);
        }
        $ingredient->delete();

        return redirect()->route('admin.ingredients.index')
            ->with('success', 'Ingredient deleted.');
    }
}
