<?php

namespace App\Http\Controllers\Tenant;

use App\Http\Controllers\Controller;
use App\Models\Role;
use App\Models\Store;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->user()->tenant_id;

        $users = User::where('tenant_id', $tenantId)
            ->where('is_super_admin', false)
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('tenant.users.index', compact('users'));
    }

    public function create(Request $request)
    {
        $tenantId = $request->user()->tenant_id;
        $stores = Store::where('tenant_id', $tenantId)->orderBy('name')->get();
        $roles = Role::where(function ($q) use ($tenantId) {
                $q->whereNull('tenant_id')->orWhere('tenant_id', $tenantId);
            })
            ->orderBy('name')
            ->get();

        return view('tenant.users.create', compact('stores', 'roles'));
    }

    public function store(Request $request)
    {
        $tenantId = $request->user()->tenant_id;

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:6'],
            'store_id' => [
                'nullable',
                Rule::exists('stores', 'id')->where('tenant_id', $tenantId),
            ],
            'is_active' => ['nullable', 'boolean'],
            'roles' => ['nullable', 'array'],
            'roles.*' => ['integer', 'exists:roles,id'],
        ]);

        $user = User::create([
            'tenant_id' => $tenantId,
            'store_id' => $data['store_id'] ?? null,
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'is_active' => $data['is_active'] ?? true,
            'is_super_admin' => false,
        ]);

        $roles = $request->input('roles', []);
        if (!empty($roles)) {
            $user->roles()->sync($roles);
        }

        return redirect()->route('tenant.users.index')
            ->with('success', 'User created.');
    }

    public function edit(Request $request, User $user)
    {
        $tenantId = $request->user()->tenant_id;

        if ($user->tenant_id !== $tenantId || $user->is_super_admin) {
            abort(403);
        }

        $stores = Store::where('tenant_id', $tenantId)->orderBy('name')->get();
        $roles = Role::where(function ($q) use ($tenantId) {
                $q->whereNull('tenant_id')->orWhere('tenant_id', $tenantId);
            })
            ->orderBy('name')
            ->get();
        $selectedRoles = $user->roles()->pluck('roles.id')->toArray();

        return view('tenant.users.edit', compact('user', 'stores', 'roles', 'selectedRoles'));
    }

    public function update(Request $request, User $user)
    {
        $tenantId = $request->user()->tenant_id;

        if ($user->tenant_id !== $tenantId || $user->is_super_admin) {
            abort(403);
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email,' . $user->id],
            'password' => ['nullable', 'string', 'min:6'],
            'store_id' => [
                'nullable',
                Rule::exists('stores', 'id')->where('tenant_id', $tenantId),
            ],
            'is_active' => ['nullable', 'boolean'],
            'roles' => ['nullable', 'array'],
            'roles.*' => ['integer', 'exists:roles,id'],
        ]);

        $user->name = $data['name'];
        $user->email = $data['email'];
        $user->store_id = $data['store_id'] ?? null;
        $user->is_active = $data['is_active'] ?? $user->is_active;
        if (!empty($data['password'])) {
            $user->password = Hash::make($data['password']);
        }
        $user->save();

        $roles = $request->input('roles', []);
        $user->roles()->sync($roles);

        return redirect()->route('tenant.users.index')
            ->with('success', 'User updated.');
    }
}
