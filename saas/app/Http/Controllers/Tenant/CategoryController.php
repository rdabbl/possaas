<?php

namespace App\Http\Controllers\Tenant;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class CategoryController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->user()->tenant_id;

        $categories = Category::where('tenant_id', $tenantId)
            ->with('parent')
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('tenant.categories.index', compact('categories'));
    }

    public function create(Request $request)
    {
        $tenantId = $request->user()->tenant_id;
        $categories = Category::where('tenant_id', $tenantId)->orderBy('name')->get();

        return view('tenant.categories.create', compact('categories'));
    }

    public function store(Request $request)
    {
        $tenantId = $request->user()->tenant_id;

        $data = $request->validate([
            'parent_id' => [
                'nullable',
                Rule::exists('categories', 'id')->where('tenant_id', $tenantId),
            ],
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('categories', 'name')->where('tenant_id', $tenantId),
            ],
            'image' => ['nullable', 'image', 'max:4096'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['tenant_id'] = $tenantId;
        $data['is_active'] = $data['is_active'] ?? true;
        if ($request->hasFile('image')) {
            $data['image_path'] = $request->file('image')->store('categories', 'public');
        }

        Category::create($data);

        return redirect()->route('tenant.categories.index')
            ->with('success', 'Category created.');
    }

    public function edit(Request $request, Category $category)
    {
        $tenantId = $request->user()->tenant_id;

        if ($category->tenant_id !== $tenantId) {
            abort(403);
        }

        $categories = Category::where('tenant_id', $tenantId)
            ->where('id', '!=', $category->id)
            ->orderBy('name')
            ->get();

        return view('tenant.categories.edit', compact('category', 'categories'));
    }

    public function update(Request $request, Category $category)
    {
        $tenantId = $request->user()->tenant_id;

        if ($category->tenant_id !== $tenantId) {
            abort(403);
        }

        $data = $request->validate([
            'parent_id' => [
                'nullable',
                Rule::exists('categories', 'id')->where('tenant_id', $tenantId),
            ],
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('categories', 'name')->where('tenant_id', $tenantId)->ignore($category->id),
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

        return redirect()->route('tenant.categories.index')
            ->with('success', 'Category updated.');
    }

    public function destroy(Request $request, Category $category)
    {
        $tenantId = $request->user()->tenant_id;
        if ($category->tenant_id !== $tenantId) {
            abort(403);
        }

        if ($category->image_path) {
            Storage::disk('public')->delete($category->image_path);
        }
        $category->delete();

        return redirect()->route('tenant.categories.index')
            ->with('success', 'Category deleted.');
    }
}
