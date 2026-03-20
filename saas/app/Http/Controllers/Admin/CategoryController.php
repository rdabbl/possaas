<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Tenant;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class CategoryController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->query('tenant_id');

        $query = Category::query()->with(['tenant', 'parent'])->orderBy('id', 'desc');
        if ($tenantId) {
            $query->where('tenant_id', $tenantId);
        }

        $categories = $query->paginate(20)->withQueryString();
        $tenants = Tenant::orderBy('name')->get();

        return view('admin.categories.index', compact('categories', 'tenants', 'tenantId'));
    }

    public function create()
    {
        $tenants = Tenant::orderBy('name')->get();
        $categories = Category::with('tenant')->orderBy('name')->get();

        return view('admin.categories.create', compact('tenants', 'categories'));
    }

    public function store(Request $request)
    {
        $tenantId = $request->input('tenant_id');

        $data = $request->validate([
            'tenant_id' => ['required', 'exists:tenants,id'],
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

        $data['is_active'] = $data['is_active'] ?? true;
        if ($request->hasFile('image')) {
            $data['image_path'] = $request->file('image')->store('categories', 'public');
        }

        Category::create($data);

        return redirect()->route('admin.categories.index')
            ->with('success', 'Category created.');
    }

    public function edit(Category $category)
    {
        $categories = Category::where('tenant_id', $category->tenant_id)
            ->where('id', '!=', $category->id)
            ->orderBy('name')
            ->get();

        return view('admin.categories.edit', compact('category', 'categories'));
    }

    public function update(Request $request, Category $category)
    {
        $tenantId = $category->tenant_id;

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

        return redirect()->route('admin.categories.index')
            ->with('success', 'Category updated.');
    }

    public function destroy(Category $category)
    {
        if ($category->image_path) {
            Storage::disk('public')->delete($category->image_path);
        }
        $category->delete();

        return redirect()->route('admin.categories.index')
            ->with('success', 'Category deleted.');
    }
}
