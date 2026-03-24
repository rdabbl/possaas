<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Currency;
use App\Models\Plan;
use App\Models\Manager;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class ManagerController extends Controller
{
    public function index()
    {
        $managers = Manager::orderBy('id', 'desc')->paginate(20);

        return view('admin.managers.index', compact('managers'));
    }

    public function create()
    {
        $currencies = Currency::where('is_active', true)->orderBy('name')->get();
        $plans = Plan::where('is_active', true)->orderBy('name')->get();
        $timezones = \DateTimeZone::listIdentifiers();

        return view('admin.managers.create', compact('currencies', 'plans', 'timezones'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'slug' => ['nullable', 'string', 'max:255', 'unique:managers,slug'],
            'is_active' => ['nullable', 'boolean'],
            'max_stores' => ['nullable', 'integer', 'min:0'],
            'max_devices' => ['nullable', 'integer', 'min:0'],
            'currency' => ['nullable', 'string', 'size:3'],
            'timezone' => ['nullable', 'string', 'max:255'],
            'plan_id' => ['nullable', 'exists:plans,id'],
            'admin_name' => ['nullable', 'string', 'max:255'],
            'admin_email' => ['nullable', 'email', 'max:255', 'unique:users,email'],
            'admin_password' => ['nullable', 'string', 'min:6'],
        ]);

        $data['slug'] = $data['slug'] ?? Str::slug($data['name']);
        $data['is_active'] = $data['is_active'] ?? true;
        $data['currency'] = $data['currency'] ?? 'USD';
        $data['timezone'] = $data['timezone'] ?? 'UTC';

        if (!empty($data['plan_id'])) {
            $plan = Plan::find($data['plan_id']);
            if ($plan) {
                $data['plan_name'] = $plan->name;
                $data['max_stores'] = $plan->max_stores;
                $data['max_devices'] = $plan->max_devices;
            }
        }

        $manager = Manager::create($data);

        if (!empty($data['admin_email'])) {
            $adminName = $data['admin_name'] ?? $manager->name . ' Admin';
            $adminPassword = $data['admin_password'] ?? 'password123';

            User::create([
                'manager_id' => $manager->id,
                'name' => $adminName,
                'email' => $data['admin_email'],
                'password' => Hash::make($adminPassword),
                'is_active' => true,
                'is_super_admin' => false,
            ]);
        }

        return redirect()->route('admin.managers.index')
            ->with('success', 'Manager created.');
    }

    public function edit(Manager $manager)
    {
        $currencies = Currency::where('is_active', true)->orderBy('name')->get();
        $plans = Plan::where('is_active', true)->orderBy('name')->get();
        $timezones = \DateTimeZone::listIdentifiers();

        return view('admin.managers.edit', compact('manager', 'currencies', 'plans', 'timezones'));
    }

    public function update(Request $request, Manager $manager)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'slug' => ['required', 'string', 'max:255', 'unique:managers,slug,' . $manager->id],
            'is_active' => ['nullable', 'boolean'],
            'max_stores' => ['nullable', 'integer', 'min:0'],
            'max_devices' => ['nullable', 'integer', 'min:0'],
            'currency' => ['nullable', 'string', 'size:3'],
            'timezone' => ['nullable', 'string', 'max:255'],
            'plan_id' => ['nullable', 'exists:plans,id'],
        ]);

        $data['is_active'] = $data['is_active'] ?? false;
        $data['currency'] = $data['currency'] ?? $manager->currency;
        $data['timezone'] = $data['timezone'] ?? $manager->timezone;

        if (!empty($data['plan_id'])) {
            $plan = Plan::find($data['plan_id']);
            if ($plan) {
                $data['plan_name'] = $plan->name;
                $data['max_stores'] = $plan->max_stores;
                $data['max_devices'] = $plan->max_devices;
            }
        } else {
            $data['plan_name'] = null;
            $data['max_stores'] = null;
            $data['max_devices'] = null;
        }

        $manager->update($data);

        return redirect()->route('admin.managers.index')
            ->with('success', 'Manager updated.');
    }
}
