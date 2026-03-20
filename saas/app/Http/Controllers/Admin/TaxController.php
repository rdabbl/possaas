<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Tax;
use App\Models\Tenant;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class TaxController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->query('tenant_id');

        $query = Tax::query()->with('tenant')->orderBy('id', 'desc');
        if ($tenantId) {
            $query->where('tenant_id', $tenantId);
        }

        $taxes = $query->paginate(20)->withQueryString();
        $tenants = Tenant::orderBy('name')->get();

        return view('admin.taxes.index', compact('taxes', 'tenants', 'tenantId'));
    }

    public function create()
    {
        $tenants = Tenant::orderBy('name')->get();

        return view('admin.taxes.create', compact('tenants'));
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
                Rule::unique('taxes', 'name')->where('tenant_id', $tenantId),
            ],
            'rate' => ['required', 'numeric', 'min:0'],
            'type' => ['required', Rule::in(['percent', 'fixed'])],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['is_active'] = $data['is_active'] ?? true;

        Tax::create($data);

        return redirect()->route('admin.taxes.index')
            ->with('success', 'Tax created.');
    }

    public function edit(Tax $tax)
    {
        return view('admin.taxes.edit', compact('tax'));
    }

    public function update(Request $request, Tax $tax)
    {
        $tenantId = $tax->tenant_id;

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('taxes', 'name')->where('tenant_id', $tenantId)->ignore($tax->id),
            ],
            'rate' => ['required', 'numeric', 'min:0'],
            'type' => ['required', Rule::in(['percent', 'fixed'])],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $tax->update($data);

        return redirect()->route('admin.taxes.index')
            ->with('success', 'Tax updated.');
    }

    public function destroy(Tax $tax)
    {
        $tax->delete();

        return redirect()->route('admin.taxes.index')
            ->with('success', 'Tax deleted.');
    }
}
