<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\IngredientCategory;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class IngredientCategoryController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $categories = IngredientCategory::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('manager.ingredient_categories.index', compact('categories'));
    }

    public function create()
    {
        return view('manager.ingredient_categories.create');
    }

    public function store(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('ingredient_categories', 'name')->where('manager_id', $managerId),
            ],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = $managerId;
        $data['is_active'] = $data['is_active'] ?? true;

        IngredientCategory::create($data);

        return redirect()->route('manager.ingredient_categories.index')
            ->with('success', 'Ingredient category created.');
    }

    public function edit(Request $request, IngredientCategory $ingredientCategory)
    {
        if ($ingredientCategory->manager_id !== $request->user()->manager_id) {
            abort(403);
        }

        return view('manager.ingredient_categories.edit', compact('ingredientCategory'));
    }

    public function update(Request $request, IngredientCategory $ingredientCategory)
    {
        $managerId = $request->user()->manager_id;
        if ($ingredientCategory->manager_id !== $managerId) {
            abort(403);
        }

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('ingredient_categories', 'name')->where('manager_id', $managerId)->ignore($ingredientCategory->id),
            ],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $ingredientCategory->update($data);

        return redirect()->route('manager.ingredient_categories.index')
            ->with('success', 'Ingredient category updated.');
    }

    public function destroy(Request $request, IngredientCategory $ingredientCategory)
    {
        if ($ingredientCategory->manager_id !== $request->user()->manager_id) {
            abort(403);
        }

        $ingredientCategory->delete();

        return redirect()->route('manager.ingredient_categories.index')
            ->with('success', 'Ingredient category deleted.');
    }
}
