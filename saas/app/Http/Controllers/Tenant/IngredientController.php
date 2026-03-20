<?php

namespace App\Http\Controllers\Tenant;

use App\Http\Controllers\Controller;
use App\Models\Ingredient;
use App\Models\IngredientCategory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class IngredientController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->user()->tenant_id;

        $ingredients = Ingredient::where('tenant_id', $tenantId)
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('tenant.ingredients.index', compact('ingredients'));
    }

    public function create(Request $request)
    {
        $tenantId = $request->user()->tenant_id;
        $categories = IngredientCategory::where('tenant_id', $tenantId)->orderBy('name')->get();

        return view('tenant.ingredients.create', compact('categories'));
    }

    public function store(Request $request)
    {
        $tenantId = $request->user()->tenant_id;

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('ingredients', 'name')->where('tenant_id', $tenantId),
            ],
            'ingredient_category_id' => [
                'nullable',
                Rule::exists('ingredient_categories', 'id')->where('tenant_id', $tenantId),
            ],
            'image' => ['nullable', 'image', 'max:4096'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['tenant_id'] = $tenantId;
        $data['is_active'] = $data['is_active'] ?? true;
        if ($request->hasFile('image')) {
            $data['image_path'] = $request->file('image')->store('ingredients', 'public');
        }

        Ingredient::create($data);

        return redirect()->route('tenant.ingredients.index')
            ->with('success', 'Ingredient created.');
    }

    public function edit(Request $request, Ingredient $ingredient)
    {
        $tenantId = $request->user()->tenant_id;
        if ($ingredient->tenant_id !== $tenantId) {
            abort(403);
        }

        $categories = IngredientCategory::where('tenant_id', $tenantId)->orderBy('name')->get();

        return view('tenant.ingredients.edit', compact('ingredient', 'categories'));
    }

    public function update(Request $request, Ingredient $ingredient)
    {
        $tenantId = $request->user()->tenant_id;
        if ($ingredient->tenant_id !== $tenantId) {
            abort(403);
        }

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('ingredients', 'name')->where('tenant_id', $tenantId)->ignore($ingredient->id),
            ],
            'ingredient_category_id' => [
                'nullable',
                Rule::exists('ingredient_categories', 'id')->where('tenant_id', $tenantId),
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

        return redirect()->route('tenant.ingredients.index')
            ->with('success', 'Ingredient updated.');
    }

    public function destroy(Request $request, Ingredient $ingredient)
    {
        $tenantId = $request->user()->tenant_id;
        if ($ingredient->tenant_id !== $tenantId) {
            abort(403);
        }

        if ($ingredient->image_path) {
            Storage::disk('public')->delete($ingredient->image_path);
        }
        $ingredient->delete();

        return redirect()->route('tenant.ingredients.index')
            ->with('success', 'Ingredient deleted.');
    }
}
