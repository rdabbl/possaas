<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Device;
use App\Models\Store;
use App\Models\Manager;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class DeviceController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->query('manager_id');

        $query = Device::query()->with(['manager', 'store'])->orderBy('id', 'desc');
        if ($managerId) {
            $query->where('manager_id', $managerId);
        }

        $devices = $query->paginate(20)->withQueryString();
        $managers = Manager::orderBy('name')->get();

        return view('admin.devices.index', compact('devices', 'managers', 'managerId'));
    }

    public function create()
    {
        $managers = Manager::orderBy('name')->get();
        $stores = Store::orderBy('name')->get();

        return view('admin.devices.create', compact('managers', 'stores'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'manager_id' => ['required', 'exists:managers,id'],
            'store_id' => [
                'required',
                Rule::exists('stores', 'id')->where('manager_id', $request->input('manager_id')),
            ],
            'name' => ['required', 'string', 'max:255'],
            'type' => ['nullable', Rule::in(['pos', 'kiosk'])],
            'platform' => ['nullable', 'string', 'max:255'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $manager = Manager::findOrFail($data['manager_id']);
        if ($manager->max_devices !== null) {
            $count = Device::where('manager_id', $manager->id)->count();
            if ($count >= $manager->max_devices) {
                return back()->withErrors(['manager_id' => 'Device limit reached for this manager.'])->withInput();
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
