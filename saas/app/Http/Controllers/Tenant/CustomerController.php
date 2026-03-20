<?php

namespace App\Http\Controllers\Tenant;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use Illuminate\Http\Request;

class CustomerController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->user()->tenant_id;

        $customers = Customer::where('tenant_id', $tenantId)
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('tenant.customers.index', compact('customers'));
    }

    public function create()
    {
        return view('tenant.customers.create');
    }

    public function store(Request $request)
    {
        $tenantId = $request->user()->tenant_id;

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'phone' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'note' => ['nullable', 'string'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['tenant_id'] = $tenantId;
        $data['is_active'] = $data['is_active'] ?? true;

        Customer::create($data);

        return redirect()->route('tenant.customers.index')
            ->with('success', 'Customer created.');
    }

    public function edit(Request $request, Customer $customer)
    {
        $tenantId = $request->user()->tenant_id;

        if ($customer->tenant_id !== $tenantId) {
            abort(403);
        }

        return view('tenant.customers.edit', compact('customer'));
    }

    public function update(Request $request, Customer $customer)
    {
        $tenantId = $request->user()->tenant_id;

        if ($customer->tenant_id !== $tenantId) {
            abort(403);
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'phone' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'note' => ['nullable', 'string'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $customer->update($data);

        return redirect()->route('tenant.customers.index')
            ->with('success', 'Customer updated.');
    }

    public function destroy(Request $request, Customer $customer)
    {
        $tenantId = $request->user()->tenant_id;
        if ($customer->tenant_id !== $tenantId) {
            abort(403);
        }

        $customer->delete();

        return redirect()->route('tenant.customers.index')
            ->with('success', 'Customer deleted.');
    }
}
