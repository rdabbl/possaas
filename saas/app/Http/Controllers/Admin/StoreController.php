<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Currency;
use App\Models\Store;
use App\Models\Tenant;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class StoreController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->query('tenant_id');

        $query = Store::query()->with('tenant')->orderBy('id', 'desc');
        if ($tenantId) {
            $query->where('tenant_id', $tenantId);
        }

        $stores = $query->paginate(20)->withQueryString();
        $tenants = Tenant::orderBy('name')->get();

        return view('admin.stores.index', compact('stores', 'tenants', 'tenantId'));
    }

    public function create()
    {
        $tenants = Tenant::orderBy('name')->get();
        $currencies = Currency::where('is_active', true)->orderBy('name')->get();

        return view('admin.stores.create', compact('tenants', 'currencies'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'tenant_id' => ['required', 'exists:tenants,id'],
            'currency_id' => [
                'required',
                Rule::exists('currencies', 'id')->where('is_active', true),
            ],
            'name' => ['required', 'string', 'max:255'],
            'code' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('stores', 'code')->where('tenant_id', $request->input('tenant_id')),
            ],
            'phone' => ['nullable', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'logo' => ['nullable', 'image', 'max:4096'],
            'stock_enabled' => ['nullable', 'boolean'],
            'is_currency_right' => ['nullable', 'boolean'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $tenant = Tenant::findOrFail($data['tenant_id']);
        if ($tenant->max_stores !== null) {
            $count = Store::where('tenant_id', $tenant->id)->count();
            if ($count >= $tenant->max_stores) {
                return back()->withErrors(['tenant_id' => 'Store limit reached for this tenant.'])->withInput();
            }
        }

        $data['stock_enabled'] = $data['stock_enabled'] ?? true;
        $data['is_currency_right'] = $data['is_currency_right'] ?? true;
        $data['is_active'] = $data['is_active'] ?? true;
        if ($request->hasFile('logo')) {
            $data['logo_path'] = $request->file('logo')->store('stores', 'public');
        }

        Store::create($data);

        return redirect()->route('admin.stores.index')
            ->with('success', 'Store created.');
    }
}
