<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class CategoryController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $categories = Category::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })
            ->with('parent')
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('manager.categories.index', compact('categories'));
    }

    public function create(Request $request)
    {
        $managerId = $request->user()->manager_id;
        $categories = Category::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })->orderBy('name')->get();

        return view('manager.categories.create', compact('categories'));
    }

    public function store(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $data = $request->validate([
            'parent_id' => [
                'nullable',
                Rule::exists('categories', 'id')->where(function ($query) use ($managerId) {
                    $query->whereNull('manager_id')
                        ->orWhere('manager_id', $managerId);
                }),
            ],
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('categories', 'name')->where('manager_id', $managerId),
            ],
            'image' => ['nullable', 'image', 'max:4096'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = $managerId;
        $data['is_active'] = $data['is_active'] ?? true;
        if ($request->hasFile('image')) {
            $data['image_path'] = $request->file('image')->store('categories', 'public');
        }

        Category::create($data);

        return redirect()->route('manager.categories.index')
            ->with('success', 'Category created.');
    }

    public function edit(Request $request, Category $category)
    {
        $managerId = $request->user()->manager_id;

        if ($category->manager_id !== $managerId) {
            abort(403);
        }

        $categories = Category::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })
            ->where('id', '!=', $category->id)
            ->orderBy('name')
            ->get();

        return view('manager.categories.edit', compact('category', 'categories'));
    }

    public function update(Request $request, Category $category)
    {
        $managerId = $request->user()->manager_id;

        if ($category->manager_id !== $managerId) {
            abort(403);
        }

        $data = $request->validate([
            'parent_id' => [
                'nullable',
                Rule::exists('categories', 'id')->where(function ($query) use ($managerId) {
                    $query->whereNull('manager_id')
                        ->orWhere('manager_id', $managerId);
                }),
            ],
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('categories', 'name')->where('manager_id', $managerId)->ignore($category->id),
            ],
            'image' => ['nullable', 'image', 'max:4096'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        if ($request->hasFile('image')) {
            if ($category->image_path) {
                Storage::disk('public')->delete($category->image_path);
            }
            $data['image_path'] = $request->file('image')->store('categories', 'public');
        }

        $category->update($data);

        return redirect()->route('manager.categories.index')
            ->with('success', 'Category updated.');
    }

    public function destroy(Request $request, Category $category)
    {
        $managerId = $request->user()->manager_id;
        if ($category->manager_id !== $managerId) {
            abort(403);
        }

        if ($category->image_path) {
            Storage::disk('public')->delete($category->image_path);
        }
        $category->delete();

        return redirect()->route('manager.categories.index')
            ->with('success', 'Category deleted.');
    }

    public function duplicate(Request $request, Category $category)
    {
        $managerId = $request->user()->manager_id;
        if ($category->manager_id !== null && $category->manager_id !== $managerId) {
            abort(403);
        }

        $copy = $category->replicate();
        $copy->manager_id = $managerId;
        $copy->name = $this->uniqueName($managerId, $category->name);
        $copy->save();

        return redirect()->route('manager.categories.index')
            ->with('success', 'Category duplicated.');
    }

    private function uniqueName(int $managerId, string $base): string
    {
        $suffix = ' (Copy)';
        $candidate = $base . $suffix;
        $counter = 2;
        while (Category::where('manager_id', $managerId)->where('name', $candidate)->exists()) {
            $candidate = $base . $suffix . ' ' . $counter;
            $counter++;
        }
        return $candidate;
    }
}
