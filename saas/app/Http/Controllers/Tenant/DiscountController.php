<?php

namespace App\Http\Controllers\Tenant;

use App\Http\Controllers\Controller;
use App\Models\Discount;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class DiscountController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->user()->tenant_id;

        $discounts = Discount::where('tenant_id', $tenantId)
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('tenant.discounts.index', compact('discounts'));
    }

    public function create()
    {
        return view('tenant.discounts.create');
    }

    public function store(Request $request)
    {
        $tenantId = $request->user()->tenant_id;

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('discounts', 'name')->where('tenant_id', $tenantId),
            ],
            'value' => ['required', 'numeric', 'min:0'],
            'type' => ['required', Rule::in(['percent', 'fixed'])],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['tenant_id'] = $tenantId;
        $data['is_active'] = $data['is_active'] ?? true;

        Discount::create($data);

        return redirect()->route('tenant.discounts.index')
            ->with('success', 'Discount created.');
    }

    public function edit(Request $request, Discount $discount)
    {
        $tenantId = $request->user()->tenant_id;
        if ($discount->tenant_id !== $tenantId) {
            abort(403);
        }

        return view('tenant.discounts.edit', compact('discount'));
    }

    public function update(Request $request, Discount $discount)
    {
        $tenantId = $request->user()->tenant_id;
        if ($discount->tenant_id !== $tenantId) {
            abort(403);
        }

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('discounts', 'name')->where('tenant_id', $tenantId)->ignore($discount->id),
            ],
            'value' => ['required', 'numeric', 'min:0'],
            'type' => ['required', Rule::in(['percent', 'fixed'])],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $discount->update($data);

        return redirect()->route('tenant.discounts.index')
            ->with('success', 'Discount updated.');
    }

    public function destroy(Request $request, Discount $discount)
    {
        $tenantId = $request->user()->tenant_id;
        if ($discount->tenant_id !== $tenantId) {
            abort(403);
        }

        $discount->delete();

        return redirect()->route('tenant.discounts.index')
            ->with('success', 'Discount deleted.');
    }
}
