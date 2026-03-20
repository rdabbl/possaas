<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Permission;
use App\Models\Role;
use App\Models\Tenant;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class RoleController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->query('tenant_id');

        $query = Role::query()->with('tenant')->orderBy('id', 'desc');
        if ($tenantId) {
            $query->where('tenant_id', $tenantId);
        }

        $roles = $query->paginate(20)->withQueryString();
        $tenants = Tenant::orderBy('name')->get();

        return view('admin.roles.index', compact('roles', 'tenants', 'tenantId'));
    }

    public function create()
    {
        $tenants = Tenant::orderBy('name')->get();
        $permissions = Permission::orderBy('name')->get();

        return view('admin.roles.create', compact('tenants', 'permissions'));
    }

    public function store(Request $request)
    {
        $tenantId = $request->input('tenant_id');

        $data = $request->validate([
            'tenant_id' => ['nullable', 'exists:tenants,id'],
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('roles', 'name')->where('tenant_id', $tenantId),
            ],
            'description' => ['nullable', 'string', 'max:255'],
            'is_system' => ['nullable', 'boolean'],
            'permissions' => ['nullable', 'array'],
            'permissions.*' => ['integer', 'exists:permissions,id'],
        ]);

        $data['is_system'] = $data['is_system'] ?? false;

        $role = Role::create($data);

        $permissions = $request->input('permissions', []);
        if (!empty($permissions)) {
            $role->permissions()->sync($permissions);
        }

        return redirect()->route('admin.roles.index')
            ->with('success', 'Role created.');
    }

    public function edit(Role $role)
    {
        $permissions = Permission::orderBy('name')->get();
        $selectedPermissions = $role->permissions()->pluck('permissions.id')->toArray();

        return view('admin.roles.edit', compact('role', 'permissions', 'selectedPermissions'));
    }

    public function update(Request $request, Role $role)
    {
        $tenantId = $role->tenant_id;

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('roles', 'name')->where('tenant_id', $tenantId)->ignore($role->id),
            ],
            'description' => ['nullable', 'string', 'max:255'],
            'is_system' => ['nullable', 'boolean'],
            'permissions' => ['nullable', 'array'],
            'permissions.*' => ['integer', 'exists:permissions,id'],
        ]);

        $data['is_system'] = $data['is_system'] ?? $role->is_system;

        $role->update($data);

        $permissions = $request->input('permissions', []);
        $role->permissions()->sync($permissions);

        return redirect()->route('admin.roles.index')
            ->with('success', 'Role updated.');
    }
}
