<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Discount;
use App\Models\Tenant;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class DiscountController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->query('tenant_id');

        $query = Discount::query()->with('tenant')->orderBy('id', 'desc');
        if ($tenantId) {
            $query->where('tenant_id', $tenantId);
        }

        $discounts = $query->paginate(20)->withQueryString();
        $tenants = Tenant::orderBy('name')->get();

        return view('admin.discounts.index', compact('discounts', 'tenants', 'tenantId'));
    }

    public function create()
    {
        $tenants = Tenant::orderBy('name')->get();

        return view('admin.discounts.create', compact('tenants'));
    }

    public function store(Request $request)
    {
        $tenantId = $request->input('tenant_id');

        $data = $request->validate([
            'tenant_id' => ['required', 'exists:tenants,id'],
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('discounts', 'name')->where('tenant_id', $tenantId),
            ],
            'type' => ['required', Rule::in(['percent', 'fixed'])],
            'value' => ['required', 'numeric', 'min:0'],
            'scope' => ['required', Rule::in(['order', 'item'])],
            'is_active' => ['nullable', 'boolean'],
        ]);

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
        $tenantId = $discount->tenant_id;

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('discounts', 'name')->where('tenant_id', $tenantId)->ignore($discount->id),
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
