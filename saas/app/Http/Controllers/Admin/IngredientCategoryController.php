<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\IngredientCategory;
use App\Models\Manager;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class IngredientCategoryController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->query('manager_id');

        $query = IngredientCategory::query()->with('manager')->orderBy('id', 'desc');
        if ($managerId) {
            $query->where('manager_id', $managerId);
        }

        $categories = $query->paginate(20)->withQueryString();
        $managers = Manager::orderBy('name')->get();

        return view('admin.ingredient_categories.index', compact('categories', 'managers', 'managerId'));
    }

    public function create()
    {
        return view('admin.ingredient_categories.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('ingredient_categories', 'name')->whereNull('manager_id'),
            ],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = null;
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
        $managerId = $ingredientCategory->manager_id;
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
                Rule::unique('ingredient_categories', 'name')->where($nameScope)->ignore($ingredientCategory->id),
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
