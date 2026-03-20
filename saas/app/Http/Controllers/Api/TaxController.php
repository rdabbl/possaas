<?php

namespace App\Http\Controllers\Api;

use App\Models\Tax;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class TaxController extends BaseApiController
{
    public function index(Request $request)
    {
        $tenant = $this->tenantOrFail($request);
        $perPage = (int) $request->query('per_page', 50);

        $taxes = Tax::where('tenant_id', $tenant->id)
            ->orderBy('id', 'desc')
            ->paginate($perPage);

        return response()->json($taxes);
    }

    public function show(Request $request, int $id)
    {
        $tenant = $this->tenantOrFail($request);

        $tax = Tax::where('tenant_id', $tenant->id)->findOrFail($id);

        return response()->json($tax);
    }

    public function store(Request $request)
    {
        $tenant = $this->tenantOrFail($request);

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('taxes', 'name')->where('tenant_id', $tenant->id),
            ],
            'rate' => ['required', 'numeric', 'min:0'],
            'type' => ['required', Rule::in(['percent', 'fixed'])],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['tenant_id'] = $tenant->id;
        $data['is_active'] = $data['is_active'] ?? true;

        $tax = Tax::create($data);

        return response()->json($tax, 201);
    }

    public function update(Request $request, int $id)
    {
        $tenant = $this->tenantOrFail($request);

        $tax = Tax::where('tenant_id', $tenant->id)->findOrFail($id);

        $data = $request->validate([
            'name' => [
                'sometimes',
                'string',
                'max:255',
                Rule::unique('taxes', 'name')->where('tenant_id', $tenant->id)->ignore($tax->id),
            ],
            'rate' => ['sometimes', 'numeric', 'min:0'],
            'type' => ['sometimes', Rule::in(['percent', 'fixed'])],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $tax->update($data);

        return response()->json($tax);
    }

    public function destroy(Request $request, int $id)
    {
        $tenant = $this->tenantOrFail($request);

        $tax = Tax::where('tenant_id', $tenant->id)->findOrFail($id);
        $tax->delete();

        return response()->json(['message' => 'Deleted']);
    }
}
