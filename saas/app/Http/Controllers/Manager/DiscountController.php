<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\Discount;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class DiscountController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $discounts = Discount::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('manager.discounts.index', compact('discounts'));
    }

    public function create()
    {
        return view('manager.discounts.create');
    }

    public function store(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('discounts', 'name')->where('manager_id', $managerId),
            ],
            'value' => ['required', 'numeric', 'min:0'],
            'type' => ['required', Rule::in(['percent', 'fixed'])],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = $managerId;
        $data['is_active'] = $data['is_active'] ?? true;

        Discount::create($data);

        return redirect()->route('manager.discounts.index')
            ->with('success', 'Discount created.');
    }

    public function edit(Request $request, Discount $discount)
    {
        $managerId = $request->user()->manager_id;
        if ($discount->manager_id !== $managerId) {
            abort(403);
        }

        return view('manager.discounts.edit', compact('discount'));
    }

    public function update(Request $request, Discount $discount)
    {
        $managerId = $request->user()->manager_id;
        if ($discount->manager_id !== $managerId) {
            abort(403);
        }

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('discounts', 'name')->where('manager_id', $managerId)->ignore($discount->id),
            ],
            'value' => ['required', 'numeric', 'min:0'],
            'type' => ['required', Rule::in(['percent', 'fixed'])],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $discount->update($data);

        return redirect()->route('manager.discounts.index')
            ->with('success', 'Discount updated.');
    }

    public function destroy(Request $request, Discount $discount)
    {
        $managerId = $request->user()->manager_id;
        if ($discount->manager_id !== $managerId) {
            abort(403);
        }

        $discount->delete();

        return redirect()->route('manager.discounts.index')
            ->with('success', 'Discount deleted.');
    }
}
