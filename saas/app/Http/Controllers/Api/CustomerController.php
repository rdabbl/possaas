<?php

namespace App\Http\Controllers\Api;

use App\Models\Customer;
use Illuminate\Http\Request;

class CustomerController extends BaseApiController
{
    public function index(Request $request)
    {
        $manager = $this->managerOrFail($request);
        $perPage = (int) $request->query('per_page', 20);

        $customers = Customer::where('manager_id', $manager->id)
            ->orderBy('id', 'desc')
            ->paginate($perPage);

        return response()->json($customers);
    }

    public function show(Request $request, int $id)
    {
        $manager = $this->managerOrFail($request);

        $customer = Customer::where('manager_id', $manager->id)->findOrFail($id);

        return response()->json($customer);
    }

    public function store(Request $request)
    {
        $manager = $this->managerOrFail($request);

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'phone' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'note' => ['nullable', 'string'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = $manager->id;
        $data['is_active'] = $data['is_active'] ?? true;

        $customer = Customer::create($data);

        return response()->json($customer, 201);
    }

    public function update(Request $request, int $id)
    {
        $manager = $this->managerOrFail($request);

        $customer = Customer::where('manager_id', $manager->id)->findOrFail($id);

        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'phone' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'note' => ['nullable', 'string'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $customer->update($data);

        return response()->json($customer);
    }

    public function destroy(Request $request, int $id)
    {
        $manager = $this->managerOrFail($request);

        $customer = Customer::where('manager_id', $manager->id)->findOrFail($id);
        $customer->delete();

        return response()->json(['message' => 'Deleted']);
    }
}
