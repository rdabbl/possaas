<?php

namespace App\Http\Controllers\Tenant;

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
        $tenantId = $request->user()->tenant_id;

        $stores = Store::where('tenant_id', $tenantId)
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('tenant.stores.index', compact('stores'));
    }

    public function create()
    {
        $currencies = Currency::where('is_active', true)->orderBy('name')->get();

        return view('tenant.stores.create', compact('currencies'));
    }

    public function store(Request $request)
    {
        $tenant = Tenant::findOrFail($request->user()->tenant_id);

        if ($tenant->max_stores !== null) {
            $count = Store::where('tenant_id', $tenant->id)->count();
            if ($count >= $tenant->max_stores) {
                return back()->withErrors(['name' => 'Store limit reached for this tenant.'])->withInput();
            }
        }

        $data = $request->validate([
            'currency_id' => [
                'required',
                Rule::exists('currencies', 'id')->where('is_active', true),
            ],
            'name' => ['required', 'string', 'max:255'],
            'code' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('stores', 'code')->where('tenant_id', $tenant->id),
            ],
            'phone' => ['nullable', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'logo' => ['nullable', 'image', 'max:4096'],
            'stock_enabled' => ['nullable', 'boolean'],
            'is_currency_right' => ['nullable', 'boolean'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['tenant_id'] = $tenant->id;
        $data['stock_enabled'] = $data['stock_enabled'] ?? true;
        $data['is_currency_right'] = $data['is_currency_right'] ?? true;
        $data['is_active'] = $data['is_active'] ?? true;
        if ($request->hasFile('logo')) {
            $data['logo_path'] = $request->file('logo')->store('stores', 'public');
        }

        Store::create($data);

        return redirect()->route('tenant.stores.index')
            ->with('success', 'Store created.');
    }

    public function edit(Request $request, Store $store)
    {
        if ($store->tenant_id !== $request->user()->tenant_id) {
            abort(403);
        }

        $currencies = Currency::where('is_active', true)->orderBy('name')->get();

        return view('tenant.stores.edit', compact('store', 'currencies'));
    }

    public function update(Request $request, Store $store)
    {
        $tenantId = $request->user()->tenant_id;

        if ($store->tenant_id !== $tenantId) {
            abort(403);
        }

        $data = $request->validate([
            'currency_id' => [
                'required',
                Rule::exists('currencies', 'id')->where('is_active', true),
            ],
            'name' => ['required', 'string', 'max:255'],
            'code' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('stores', 'code')->where('tenant_id', $tenantId)->ignore($store->id),
            ],
            'phone' => ['nullable', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'logo' => ['nullable', 'image', 'max:4096'],
            'stock_enabled' => ['nullable', 'boolean'],
            'is_currency_right' => ['nullable', 'boolean'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        if ($request->hasFile('logo')) {
            if ($store->logo_path) {
                Storage::disk('public')->delete($store->logo_path);
            }
            $data['logo_path'] = $request->file('logo')->store('stores', 'public');
        }

        $store->update($data);

        return redirect()->route('tenant.stores.index')
            ->with('success', 'Store updated.');
    }
}
