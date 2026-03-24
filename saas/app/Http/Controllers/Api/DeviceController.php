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
        $manager = $this->managerOrFail($request);

        $devices = Device::where('manager_id', $manager->id)
            ->orderBy('id', 'desc')
            ->get();

        return response()->json($devices);
    }

    public function store(Request $request)
    {
        $manager = $this->managerOrFail($request);

        if ($manager->max_devices !== null) {
            $count = Device::where('manager_id', $manager->id)->count();
            if ($count >= $manager->max_devices) {
                return response()->json([
                    'message' => 'Device limit reached for this manager.',
                ], 422);
            }
        }

        $data = $request->validate([
            'store_id' => [
                'required',
                Rule::exists('stores', 'id')->where('manager_id', $manager->id),
            ],
            'name' => ['required', 'string', 'max:255'],
            'type' => ['nullable', Rule::in(['pos', 'kiosk'])],
            'platform' => ['nullable', 'string', 'max:255'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = $manager->id;
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
        $manager = $this->managerOrFail($request);

        if ($manager->max_devices !== null) {
            $count = Device::where('manager_id', $manager->id)->count();
            if ($count >= $manager->max_devices) {
                return response()->json([
                    'message' => 'Device limit reached for this manager.',
                ], 422);
            }
        }

        $data = $request->validate([
            'store_id' => [
                'required',
                Rule::exists('stores', 'id')->where('manager_id', $manager->id),
            ],
            'name' => ['required', 'string', 'max:255'],
            'type' => ['nullable', Rule::in(['pos', 'kiosk'])],
            'platform' => ['nullable', 'string', 'max:255'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = $manager->id;
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
            'manager_id' => $device->manager_id,
            'store_id' => $device->store_id,
        ]);
    }
}
