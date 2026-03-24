<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Discount;
use App\Models\Manager;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class DiscountController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->query('manager_id');

        $query = Discount::query()->with('manager')->orderBy('id', 'desc');
        if ($managerId) {
            $query->where('manager_id', $managerId);
        }

        $discounts = $query->paginate(20)->withQueryString();
        $managers = Manager::orderBy('name')->get();

        return view('admin.discounts.index', compact('discounts', 'managers', 'managerId'));
    }

    public function create()
    {
        return view('admin.discounts.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('discounts', 'name')->whereNull('manager_id'),
            ],
            'type' => ['required', Rule::in(['percent', 'fixed'])],
            'value' => ['required', 'numeric', 'min:0'],
            'scope' => ['required', Rule::in(['order', 'item'])],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = null;
        $data['is_active'] = $data['is_active'] ?? true;

        Discount::create($data);

        return redirect()->route('admin.discounts.index')
            ->with('success', 'Discount created.');
    }

    public function edit(Discount $discount)
    {
        return view('admin.discounts.edit', compact('discount'));
    }

    public function update(Request $request, Discount $discount)
    {
        $managerId = $discount->manager_id;
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
                Rule::unique('discounts', 'name')->where($nameScope)->ignore($discount->id),
            ],
            'type' => ['required', Rule::in(['percent', 'fixed'])],
            'value' => ['required', 'numeric', 'min:0'],
            'scope' => ['required', Rule::in(['order', 'item'])],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $discount->update($data);

        return redirect()->route('admin.discounts.index')
            ->with('success', 'Discount updated.');
    }

    public function destroy(Discount $discount)
    {
        $discount->delete();

        return redirect()->route('admin.discounts.index')
            ->with('success', 'Discount deleted.');
    }
}
