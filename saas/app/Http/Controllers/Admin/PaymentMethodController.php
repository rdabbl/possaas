<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\PaymentMethod;
use App\Models\Tenant;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PaymentMethodController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->query('tenant_id');

        $query = PaymentMethod::query()->with('tenant')->orderBy('id', 'desc');
        if ($tenantId) {
            $query->where('tenant_id', $tenantId);
        }

        $methods = $query->paginate(20)->withQueryString();
        $tenants = Tenant::orderBy('name')->get();

        return view('admin.payment_methods.index', compact('methods', 'tenants', 'tenantId'));
    }

    public function create()
    {
        $tenants = Tenant::orderBy('name')->get();

        return view('admin.payment_methods.create', compact('tenants'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'tenant_id' => ['required', 'exists:tenants,id'],
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('payment_methods', 'name')->where('tenant_id', $request->input('tenant_id')),
            ],
            'type' => ['nullable', Rule::in(['cash', 'card', 'bank', 'other'])],
            'is_active' => ['nullable', 'boolean'],
            'is_default' => ['nullable', 'boolean'],
        ]);

        $data['type'] = $data['type'] ?? 'cash';
        $data['is_active'] = $data['is_active'] ?? true;
        $data['is_default'] = $data['is_default'] ?? false;

        PaymentMethod::create($data);

        return redirect()->route('admin.payment_methods.index')
            ->with('success', 'Payment method created.');
    }
}
