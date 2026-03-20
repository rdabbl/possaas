<?php

namespace App\Http\Controllers\Tenant;

use App\Http\Controllers\Controller;
use App\Models\Tax;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class TaxController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->user()->tenant_id;

        $taxes = Tax::where('tenant_id', $tenantId)
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('tenant.taxes.index', compact('taxes'));
    }

    public function create()
    {
        return view('tenant.taxes.create');
    }

    public function store(Request $request)
    {
        $tenantId = $request->user()->tenant_id;

        $data = $request->validate([
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

        $data['tenant_id'] = $tenantId;
        $data['is_active'] = $data['is_active'] ?? true;

        Tax::create($data);

        return redirect()->route('tenant.taxes.index')
            ->with('success', 'Tax created.');
    }

    public function edit(Request $request, Tax $tax)
    {
        $tenantId = $request->user()->tenant_id;
        if ($tax->tenant_id !== $tenantId) {
            abort(403);
        }

        return view('tenant.taxes.edit', compact('tax'));
    }

    public function update(Request $request, Tax $tax)
    {
        $tenantId = $request->user()->tenant_id;
        if ($tax->tenant_id !== $tenantId) {
            abort(403);
        }

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

        return redirect()->route('tenant.taxes.index')
            ->with('success', 'Tax updated.');
    }

    public function destroy(Request $request, Tax $tax)
    {
        $tenantId = $request->user()->tenant_id;
        if ($tax->tenant_id !== $tenantId) {
            abort(403);
        }

        $tax->delete();

        return redirect()->route('tenant.taxes.index')
            ->with('success', 'Tax deleted.');
    }
}
