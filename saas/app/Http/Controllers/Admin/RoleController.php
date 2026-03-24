<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Permission;
use App\Models\Role;
use App\Models\Manager;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class RoleController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->query('manager_id');

        $query = Role::query()->with('manager')->orderBy('id', 'desc');
        if ($managerId) {
            $query->where('manager_id', $managerId);
        }

        $roles = $query->paginate(20)->withQueryString();
        $managers = Manager::orderBy('name')->get();

        return view('admin.roles.index', compact('roles', 'managers', 'managerId'));
    }

    public function create()
    {
        $managers = Manager::orderBy('name')->get();
        $permissions = Permission::orderBy('name')->get();

        return view('admin.roles.create', compact('managers', 'permissions'));
    }

    public function store(Request $request)
    {
        $managerId = $request->input('manager_id');

        $data = $request->validate([
            'manager_id' => ['nullable', 'exists:managers,id'],
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('roles', 'name')->where('manager_id', $managerId),
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
        $managerId = $role->manager_id;

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('roles', 'name')->where('manager_id', $managerId)->ignore($role->id),
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
