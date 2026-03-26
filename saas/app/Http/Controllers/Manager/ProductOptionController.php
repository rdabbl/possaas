<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\ProductOption;
use App\Models\ProductOptionCategory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class ProductOptionController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $options = ProductOption::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('manager.product_options.index', compact('options'));
    }

    public function create(Request $request)
    {
        $managerId = $request->user()->manager_id;
        $categories = ProductOptionCategory::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })->orderBy('name')->get();

        return view('manager.product_options.create', compact('categories'));
    }

    public function store(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('product_options', 'name')->where('manager_id', $managerId),
            ],
            'product_option_category_id' => [
                'nullable',
                Rule::exists('product_option_categories', 'id')->where(function ($query) use ($managerId) {
                    $query->whereNull('manager_id')
                        ->orWhere('manager_id', $managerId);
                }),
            ],
            'option_type' => ['required', Rule::in(['boolean', 'quantity'])],
            'step_action' => [Rule::requiredIf($request->input('option_type') === 'quantity'), Rule::in(['add', 'reduce'])],
            'step_value' => [Rule::requiredIf($request->input('option_type') === 'quantity'), 'integer', 'min:1'],
            'image' => ['nullable', 'image', 'max:4096'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = $managerId;
        $data['is_active'] = $data['is_active'] ?? true;
        if ($data['option_type'] === 'boolean') {
            $data['step_action'] = null;
            $data['step_value'] = null;
        } else {
            $data['step_action'] = $data['step_action'] ?? 'add';
            $data['step_value'] = $data['step_value'] ?? 1;
        }
        if ($request->hasFile('image')) {
            $data['image_path'] = $request->file('image')->store('product-options', 'public');
        }

        ProductOption::create($data);

        return redirect()->route('manager.product_options.index')
            ->with('success', 'Product option created.');
    }

    public function edit(Request $request, ProductOption $productOption)
    {
        $managerId = $request->user()->manager_id;
        if ($productOption->manager_id !== $managerId) {
            abort(403);
        }

        $categories = ProductOptionCategory::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })->orderBy('name')->get();

        return view('manager.product_options.edit', compact('productOption', 'categories'));
    }

    public function update(Request $request, ProductOption $productOption)
    {
        $managerId = $request->user()->manager_id;
        if ($productOption->manager_id !== $managerId) {
            abort(403);
        }

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('product_options', 'name')->where('manager_id', $managerId)->ignore($productOption->id),
            ],
            'product_option_category_id' => [
                'nullable',
                Rule::exists('product_option_categories', 'id')->where(function ($query) use ($managerId) {
                    $query->whereNull('manager_id')
                        ->orWhere('manager_id', $managerId);
                }),
            ],
            'option_type' => ['required', Rule::in(['boolean', 'quantity'])],
            'step_action' => [Rule::requiredIf($request->input('option_type') === 'quantity'), Rule::in(['add', 'reduce'])],
            'step_value' => [Rule::requiredIf($request->input('option_type') === 'quantity'), 'integer', 'min:1'],
            'image' => ['nullable', 'image', 'max:4096'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        if ($data['option_type'] === 'boolean') {
            $data['step_action'] = null;
            $data['step_value'] = null;
        } else {
            $data['step_action'] = $data['step_action'] ?? 'add';
            $data['step_value'] = $data['step_value'] ?? 1;
        }

        if ($request->hasFile('image')) {
            if ($productOption->image_path) {
                Storage::disk('public')->delete($productOption->image_path);
            }
            $data['image_path'] = $request->file('image')->store('product-options', 'public');
        }

        $productOption->update($data);

        return redirect()->route('manager.product_options.index')
            ->with('success', 'Product option updated.');
    }

    public function destroy(Request $request, ProductOption $productOption)
    {
        $managerId = $request->user()->manager_id;
        if ($productOption->manager_id !== $managerId) {
            abort(403);
        }

        if ($productOption->image_path) {
            Storage::disk('public')->delete($productOption->image_path);
        }
        $productOption->delete();

        return redirect()->route('manager.product_options.index')
            ->with('success', 'Product option deleted.');
    }

    public function duplicate(Request $request, ProductOption $productOption)
    {
        $managerId = $request->user()->manager_id;
        if ($productOption->manager_id !== null && $productOption->manager_id !== $managerId) {
            abort(403);
        }

        $copy = $productOption->replicate();
        $copy->manager_id = $managerId;
        $copy->name = $this->uniqueName($managerId, $productOption->name);
        $copy->save();

        return redirect()->route('manager.product_options.index')
            ->with('success', 'Product option duplicated.');
    }

    private function uniqueName(int $managerId, string $base): string
    {
        $suffix = ' (Copy)';
        $candidate = $base . $suffix;
        $counter = 2;
        while (ProductOption::where('manager_id', $managerId)->where('name', $candidate)->exists()) {
            $candidate = $base . $suffix . ' ' . $counter;
            $counter++;
        }
        return $candidate;
    }
}
