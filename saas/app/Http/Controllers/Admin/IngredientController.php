<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Ingredient;
use App\Models\IngredientCategory;
use App\Models\Manager;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class IngredientController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->query('manager_id');

        $query = Ingredient::query()->with('manager')->orderBy('id', 'desc');
        if ($managerId) {
            $query->where('manager_id', $managerId);
        }

        $ingredients = $query->paginate(20)->withQueryString();
        $managers = Manager::orderBy('name')->get();

        return view('admin.ingredients.index', compact('ingredients', 'managers', 'managerId'));
    }

    public function create()
    {
        $categories = IngredientCategory::whereNull('manager_id')->orderBy('name')->get();

        return view('admin.ingredients.create', compact('categories'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'ingredient_category_id' => [
                'nullable',
                Rule::exists('ingredient_categories', 'id')->whereNull('manager_id'),
            ],
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('ingredients', 'name')->whereNull('manager_id'),
            ],
            'image' => ['nullable', 'image', 'max:4096'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = null;
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
        $categories = IngredientCategory::where(function ($query) use ($ingredient) {
            if ($ingredient->manager_id) {
                $query->whereNull('manager_id')
                    ->orWhere('manager_id', $ingredient->manager_id);
                return;
            }
            $query->whereNull('manager_id');
        })
            ->orderBy('name')
            ->get();

        return view('admin.ingredients.edit', compact('ingredient', 'categories'));
    }

    public function update(Request $request, Ingredient $ingredient)
    {
        $managerId = $ingredient->manager_id;
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
            'ingredient_category_id' => [
                'nullable',
                Rule::exists('ingredient_categories', 'id')->where($categoryScope),
            ],
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('ingredients', 'name')->where($nameScope)->ignore($ingredient->id),
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
