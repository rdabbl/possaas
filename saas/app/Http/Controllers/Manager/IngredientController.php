<?php

namespace App\Http\Controllers\Manager;

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
        $managerId = $request->user()->manager_id;

        $ingredients = Ingredient::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('manager.ingredients.index', compact('ingredients'));
    }

    public function create(Request $request)
    {
        $managerId = $request->user()->manager_id;
        $categories = IngredientCategory::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })->orderBy('name')->get();

        return view('manager.ingredients.create', compact('categories'));
    }

    public function store(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('ingredients', 'name')->where('manager_id', $managerId),
            ],
            'ingredient_category_id' => [
                'nullable',
                Rule::exists('ingredient_categories', 'id')->where(function ($query) use ($managerId) {
                    $query->whereNull('manager_id')
                        ->orWhere('manager_id', $managerId);
                }),
            ],
            'image' => ['nullable', 'image', 'max:4096'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = $managerId;
        $data['is_active'] = $data['is_active'] ?? true;
        if ($request->hasFile('image')) {
            $data['image_path'] = $request->file('image')->store('ingredients', 'public');
        }

        Ingredient::create($data);

        return redirect()->route('manager.ingredients.index')
            ->with('success', 'Ingredient created.');
    }

    public function edit(Request $request, Ingredient $ingredient)
    {
        $managerId = $request->user()->manager_id;
        if ($ingredient->manager_id !== $managerId) {
            abort(403);
        }

        $categories = IngredientCategory::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })->orderBy('name')->get();

        return view('manager.ingredients.edit', compact('ingredient', 'categories'));
    }

    public function update(Request $request, Ingredient $ingredient)
    {
        $managerId = $request->user()->manager_id;
        if ($ingredient->manager_id !== $managerId) {
            abort(403);
        }

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('ingredients', 'name')->where('manager_id', $managerId)->ignore($ingredient->id),
            ],
            'ingredient_category_id' => [
                'nullable',
                Rule::exists('ingredient_categories', 'id')->where(function ($query) use ($managerId) {
                    $query->whereNull('manager_id')
                        ->orWhere('manager_id', $managerId);
                }),
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

        return redirect()->route('manager.ingredients.index')
            ->with('success', 'Ingredient updated.');
    }

    public function destroy(Request $request, Ingredient $ingredient)
    {
        $managerId = $request->user()->manager_id;
        if ($ingredient->manager_id !== $managerId) {
            abort(403);
        }

        if ($ingredient->image_path) {
            Storage::disk('public')->delete($ingredient->image_path);
        }
        $ingredient->delete();

        return redirect()->route('manager.ingredients.index')
            ->with('success', 'Ingredient deleted.');
    }
}
