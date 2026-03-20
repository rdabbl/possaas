<?php

namespace App\Http\Controllers\Api;

use App\Models\PaymentMethod;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PaymentMethodController extends BaseApiController
{
    public function index(Request $request)
    {
        $tenant = $this->tenantOrFail($request);
        $perPage = (int) $request->query('per_page', 50);

        $methods = PaymentMethod::where('tenant_id', $tenant->id)
            ->orderBy('id', 'desc')
            ->paginate($perPage);

        return response()->json($methods);
    }

    public function show(Request $request, int $id)
    {
        $tenant = $this->tenantOrFail($request);

        $method = PaymentMethod::where('tenant_id', $tenant->id)->findOrFail($id);

        return response()->json($method);
    }

    public function store(Request $request)
    {
        $tenant = $this->tenantOrFail($request);

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('payment_methods', 'name')->where('tenant_id', $tenant->id),
            ],
            'type' => ['nullable', Rule::in(['cash', 'card', 'bank', 'other'])],
            'is_active' => ['nullable', 'boolean'],
            'is_default' => ['nullable', 'boolean'],
        ]);

        $data['tenant_id'] = $tenant->id;
        $data['type'] = $data['type'] ?? 'cash';
        $data['is_active'] = $data['is_active'] ?? true;
        $data['is_default'] = $data['is_default'] ?? false;

        $method = PaymentMethod::create($data);

        return response()->json($method, 201);
    }

    public function update(Request $request, int $id)
    {
        $tenant = $this->tenantOrFail($request);

        $method = PaymentMethod::where('tenant_id', $tenant->id)->findOrFail($id);

        $data = $request->validate([
            'name' => [
                'sometimes',
                'string',
                'max:255',
                Rule::unique('payment_methods', 'name')->where('tenant_id', $tenant->id)->ignore($method->id),
            ],
            'type' => ['sometimes', Rule::in(['cash', 'card', 'bank', 'other'])],
            'is_active' => ['nullable', 'boolean'],
            'is_default' => ['nullable', 'boolean'],
        ]);

        $method->update($data);

        return response()->json($method);
    }

    public function destroy(Request $request, int $id)
    {
        $tenant = $this->tenantOrFail($request);

        $method = PaymentMethod::where('tenant_id', $tenant->id)->findOrFail($id);
        $method->delete();

        return response()->json(['message' => 'Deleted']);
    }
}
