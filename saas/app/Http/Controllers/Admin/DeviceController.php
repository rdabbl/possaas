<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Device;
use App\Models\Store;
use App\Models\Tenant;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class DeviceController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->query('tenant_id');

        $query = Device::query()->with(['tenant', 'store'])->orderBy('id', 'desc');
        if ($tenantId) {
            $query->where('tenant_id', $tenantId);
        }

        $devices = $query->paginate(20)->withQueryString();
        $tenants = Tenant::orderBy('name')->get();

        return view('admin.devices.index', compact('devices', 'tenants', 'tenantId'));
    }

    public function create()
    {
        $tenants = Tenant::orderBy('name')->get();
        $stores = Store::orderBy('name')->get();

        return view('admin.devices.create', compact('tenants', 'stores'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'tenant_id' => ['required', 'exists:tenants,id'],
            'store_id' => [
                'required',
                Rule::exists('stores', 'id')->where('tenant_id', $request->input('tenant_id')),
            ],
            'name' => ['required', 'string', 'max:255'],
            'type' => ['nullable', Rule::in(['pos', 'kiosk'])],
            'platform' => ['nullable', 'string', 'max:255'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $tenant = Tenant::findOrFail($data['tenant_id']);
        if ($tenant->max_devices !== null) {
            $count = Device::where('tenant_id', $tenant->id)->count();
            if ($count >= $tenant->max_devices) {
                return back()->withErrors(['tenant_id' => 'Device limit reached for this tenant.'])->withInput();
            }
        }

        $data['uuid'] = (string) Str::uuid();
        $data['secret'] = Str::random(64);
        $data['type'] = $data['type'] ?? 'pos';
        $data['platform'] = $data['platform'] ?? 'android';
        $data['is_active'] = $data['is_active'] ?? true;

        Device::create($data);

        return redirect()->route('admin.devices.index')
            ->with('success', 'Device created.');
    }
}
