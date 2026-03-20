<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\Tenant;
use Illuminate\Http\Request;

class CustomerController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->query('tenant_id');

        $query = Customer::query()->with('tenant')->orderBy('id', 'desc');
        if ($tenantId) {
            $query->where('tenant_id', $tenantId);
        }

        $customers = $query->paginate(20)->withQueryString();
        $tenants = Tenant::orderBy('name')->get();

        return view('admin.customers.index', compact('customers', 'tenants', 'tenantId'));
    }

    public function create()
    {
        $tenants = Tenant::orderBy('name')->get();

        return view('admin.customers.create', compact('tenants'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'tenant_id' => ['required', 'exists:tenants,id'],
            'name' => ['required', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'phone' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'note' => ['nullable', 'string'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['is_active'] = $data['is_active'] ?? true;

        Customer::create($data);

        return redirect()->route('admin.customers.index')
            ->with('success', 'Customer created.');
    }

    public function edit(Customer $customer)
    {
        return view('admin.customers.edit', compact('customer'));
    }

    public function update(Request $request, Customer $customer)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'phone' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'note' => ['nullable', 'string'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $customer->update($data);

        return redirect()->route('admin.customers.index')
            ->with('success', 'Customer updated.');
    }

    public function destroy(Customer $customer)
    {
        $customer->delete();

        return redirect()->route('admin.customers.index')
            ->with('success', 'Customer deleted.');
    }
}
