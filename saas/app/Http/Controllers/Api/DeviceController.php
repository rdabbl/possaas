<?php

namespace App\Http\Controllers\Api;

use App\Models\Device;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class DeviceController extends BaseApiController
{
    public function index(Request $request)
    {
        $tenant = $this->tenantOrFail($request);

        $devices = Device::where('tenant_id', $tenant->id)
            ->orderBy('id', 'desc')
            ->get();

        return response()->json($devices);
    }

    public function store(Request $request)
    {
        $tenant = $this->tenantOrFail($request);

        if ($tenant->max_devices !== null) {
            $count = Device::where('tenant_id', $tenant->id)->count();
            if ($count >= $tenant->max_devices) {
                return response()->json([
                    'message' => 'Device limit reached for this tenant.',
                ], 422);
            }
        }

        $data = $request->validate([
            'store_id' => [
                'required',
                Rule::exists('stores', 'id')->where('tenant_id', $tenant->id),
            ],
            'name' => ['required', 'string', 'max:255'],
            'type' => ['nullable', Rule::in(['pos', 'kiosk'])],
            'platform' => ['nullable', 'string', 'max:255'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['tenant_id'] = $tenant->id;
        $data['uuid'] = (string) Str::uuid();
        $data['secret'] = Str::random(64);
        $data['type'] = $data['type'] ?? 'pos';
        $data['platform'] = $data['platform'] ?? 'android';
        $data['is_active'] = $data['is_active'] ?? true;

        $device = Device::create($data);

        return response()->json($device, 201);
    }

    public function register(Request $request)
    {
        $tenant = $this->tenantOrFail($request);

        if ($tenant->max_devices !== null) {
            $count = Device::where('tenant_id', $tenant->id)->count();
            if ($count >= $tenant->max_devices) {
                return response()->json([
                    'message' => 'Device limit reached for this tenant.',
                ], 422);
            }
        }

        $data = $request->validate([
            'store_id' => [
                'required',
                Rule::exists('stores', 'id')->where('tenant_id', $tenant->id),
            ],
            'name' => ['required', 'string', 'max:255'],
            'type' => ['nullable', Rule::in(['pos', 'kiosk'])],
            'platform' => ['nullable', 'string', 'max:255'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['tenant_id'] = $tenant->id;
        $data['uuid'] = (string) Str::uuid();
        $data['secret'] = Str::random(64);
        $data['type'] = $data['type'] ?? 'pos';
        $data['platform'] = $data['platform'] ?? 'android';
        $data['is_active'] = $data['is_active'] ?? true;

        $device = Device::create($data);

        return response()->json($device, 201);
    }

    public function authenticateDevice(Request $request)
    {
        $data = $request->validate([
            'uuid' => ['required', 'string'],
            'secret' => ['required', 'string'],
        ]);

        $device = Device::where('uuid', $data['uuid'])
            ->where('secret', $data['secret'])
            ->where('is_active', true)
            ->first();

        if (!$device) {
            return response()->json(['message' => 'Invalid device credentials.'], 401);
        }

        $device->last_seen_at = now();
        $device->save();

        return response()->json([
            'device' => $device,
            'tenant_id' => $device->tenant_id,
            'store_id' => $device->store_id,
        ]);
    }
}
