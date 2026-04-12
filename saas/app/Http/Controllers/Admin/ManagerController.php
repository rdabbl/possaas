<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Currency;
use App\Models\Customer;
use App\Models\Plan;
use App\Models\Manager;
use App\Models\Store;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class ManagerController extends Controller
{
    public function index()
    {
        $managers = Manager::with(['plan', 'latestSubscription'])->orderBy('id', 'desc')->paginate(20);

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
            'username' => ['required', 'string', 'max:255', 'unique:managers,username'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:6'],
            'is_active' => ['nullable', 'boolean'],
            'max_stores' => ['nullable', 'integer', 'min:0'],
            'max_devices' => ['nullable', 'integer', 'min:0'],
            'currency' => ['nullable', 'string', 'size:3'],
            'timezone' => ['nullable', 'string', 'max:255'],
            'plan_id' => ['nullable', 'exists:plans,id'],
        ]);

        $data['slug'] = $this->generateUniqueSlug($data['name']);
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

        $store = null;
        $storeCount = Store::where('manager_id', $manager->id)->count();
        if ($storeCount === 0) {
            $currency = null;
            if (!empty($manager->currency)) {
                $currency = Currency::where('code', strtoupper($manager->currency))->first();
            }
            $currency ??= Currency::where('is_active', true)->orderBy('id')->first();

            $storeName = $manager->name;
            $store = Store::create([
                'manager_id' => $manager->id,
                'currency_id' => $currency?->id,
                'name' => $storeName,
                'code' => null,
                'stock_enabled' => true,
                'is_currency_right' => true,
                'is_active' => true,
            ]);

            Customer::create([
                'manager_id' => $manager->id,
                'name' => $storeName . ' - CLIENT',
                'is_active' => true,
            ]);
        }

        User::create([
            'manager_id' => $manager->id,
            'store_id' => $store?->id,
            'name' => $manager->name,
            'username' => $manager->username,
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'is_active' => true,
            'is_super_admin' => false,
        ]);

        return redirect()->route('admin.managers.index')
            ->with('success', 'Manager created.');
    }

    public function edit(Manager $manager)
    {
        $currencies = Currency::where('is_active', true)->orderBy('name')->get();
        $plans = Plan::where('is_active', true)->orderBy('name')->get();
        $timezones = \DateTimeZone::listIdentifiers();
        $managerUser = User::where('manager_id', $manager->id)
            ->where('is_super_admin', false)
            ->orderBy('id')
            ->first();

        return view('admin.managers.edit', compact('manager', 'managerUser', 'currencies', 'plans', 'timezones'));
    }

    public function update(Request $request, Manager $manager)
    {
        $managerUser = User::where('manager_id', $manager->id)
            ->where('is_super_admin', false)
            ->orderBy('id')
            ->first();

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'username' => ['required', 'string', 'max:255', 'unique:managers,username,' . $manager->id],
            'email' => ['required', 'email', 'max:255', 'unique:users,email,' . ($managerUser?->id ?? 'NULL')],
            'password' => ['nullable', 'string', 'min:6'],
            'is_active' => ['nullable', 'boolean'],
            'max_stores' => ['nullable', 'integer', 'min:0'],
            'max_devices' => ['nullable', 'integer', 'min:0'],
            'currency' => ['nullable', 'string', 'size:3'],
            'timezone' => ['nullable', 'string', 'max:255'],
            'plan_id' => ['nullable', 'exists:plans,id'],
        ]);

        $data['slug'] = $this->generateUniqueSlug($data['name'], $manager->id);
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

        $store = Store::where('manager_id', $manager->id)->orderBy('id')->first();
        $managerUser ??= new User([
            'manager_id' => $manager->id,
            'is_super_admin' => false,
        ]);
        $managerUser->manager_id = $manager->id;
        $managerUser->store_id = $managerUser->store_id ?? $store?->id;
        $managerUser->name = $manager->name;
        $managerUser->username = $manager->username;
        $managerUser->email = $data['email'];
        $managerUser->is_active = $manager->is_active;
        if (!empty($data['password'])) {
            $managerUser->password = Hash::make($data['password']);
        }
        $managerUser->save();

        return redirect()->route('admin.managers.index')
            ->with('success', 'Manager updated.');
    }

    public function destroy(Manager $manager)
    {
        try {
            $manager->delete();
            return redirect()->route('admin.managers.index')
                ->with('success', 'Manager deleted.');
        } catch (QueryException $e) {
            return redirect()->route('admin.managers.index')
                ->with('error', 'Unable to delete manager. Remove dependent records first.');
        }
    }

    private function generateUniqueSlug(string $name, ?int $ignoreId = null): string
    {
        $base = Str::slug($name);
        if ($base === '') {
            $base = 'manager';
        }
        $slug = $base;
        $counter = 1;

        while (Manager::where('slug', $slug)->when($ignoreId, function ($query) use ($ignoreId) {
            $query->where('id', '!=', $ignoreId);
        })->exists()) {
            $counter++;
            $slug = $base . '-' . $counter;
        }

        return $slug;
    }
}
