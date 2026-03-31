<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use Illuminate\Http\Request;

class CustomerController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $customers = Customer::where('manager_id', $managerId)
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('manager.customers.index', compact('customers'));
    }

    public function create()
    {
        return view('manager.customers.create');
    }

    public function store(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'phone' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'note' => ['nullable', 'string'],
            'loyalty_points_balance' => ['nullable', 'integer', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = $managerId;
        $data['is_active'] = $data['is_active'] ?? true;
        $data['loyalty_points_balance'] = $data['loyalty_points_balance'] ?? 0;

        Customer::create($data);

        return redirect()->route('manager.customers.index')
            ->with('success', 'Customer created.');
    }

    public function edit(Request $request, Customer $customer)
    {
        $managerId = $request->user()->manager_id;

        if ($customer->manager_id !== $managerId) {
            abort(403);
        }

        return view('manager.customers.edit', compact('customer'));
    }

    public function update(Request $request, Customer $customer)
    {
        $managerId = $request->user()->manager_id;

        if ($customer->manager_id !== $managerId) {
            abort(403);
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'phone' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'note' => ['nullable', 'string'],
            'loyalty_points_balance' => ['nullable', 'integer', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $customer->update($data);

        return redirect()->route('manager.customers.index')
            ->with('success', 'Customer updated.');
    }

    public function destroy(Request $request, Customer $customer)
    {
        $managerId = $request->user()->manager_id;
        if ($customer->manager_id !== $managerId) {
            abort(403);
        }

        $customer->delete();

        return redirect()->route('manager.customers.index')
            ->with('success', 'Customer deleted.');
    }

    public function duplicate(Request $request, Customer $customer)
    {
        $managerId = $request->user()->manager_id;
        if ($customer->manager_id !== $managerId) {
            abort(403);
        }

        $copy = $customer->replicate();
        $copy->manager_id = $managerId;
        $copy->name = $this->copyName($customer->name);
        $copy->save();

        return redirect()->route('manager.customers.index')
            ->with('success', 'Customer duplicated.');
    }

    private function copyName(string $base): string
    {
        return trim($base) . ' (Copy)';
    }
}
