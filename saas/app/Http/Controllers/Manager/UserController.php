<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\Role;
use App\Models\Store;
use App\Models\User;
use App\Models\UserAudit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    private function requireStoreId(Request $request): int
    {
        $storeId = $request->user()->store_id;
        if (!$storeId) {
            abort(403);
        }
        return (int) $storeId;
    }

    private function snapshotUser(User $user): array
    {
        return [
            'name' => $user->name,
            'email' => $user->email,
            'store_id' => $user->store_id,
            'is_active' => $user->is_active,
            'roles' => $user->roles()->pluck('roles.id')->sort()->values()->toArray(),
        ];
    }

    private function diffSnapshots(?array $before, ?array $after): array
    {
        $diff = [];
        $keys = array_unique(array_merge(array_keys($before ?? []), array_keys($after ?? [])));
        foreach ($keys as $key) {
            $from = $before[$key] ?? null;
            $to = $after[$key] ?? null;
            if ($from !== $to) {
                $diff[$key] = ['from' => $from, 'to' => $to];
            }
        }
        return $diff;
    }

    private function logAudit(Request $request, ?User $target, string $action, ?array $before, ?array $after): void
    {
        $actor = $request->user();
        UserAudit::create([
            'actor_user_id' => $actor?->id,
            'target_user_id' => $target?->id,
            'manager_id' => $actor?->manager_id,
            'store_id' => $actor?->store_id,
            'action' => $action,
            'changes' => [
                'before' => $before,
                'after' => $after,
                'diff' => $this->diffSnapshots($before, $after),
            ],
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ]);
    }

    public function index(Request $request)
    {
        $managerId = $request->user()->manager_id;
        $storeId = $this->requireStoreId($request);

        $users = User::where('manager_id', $managerId)
            ->where('store_id', $storeId)
            ->where('is_super_admin', false)
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('manager.users.index', compact('users'));
    }

    public function create(Request $request)
    {
        $managerId = $request->user()->manager_id;
        $storeId = $this->requireStoreId($request);
        $stores = Store::where('manager_id', $managerId)
            ->where('id', $storeId)
            ->orderBy('name')
            ->get();
        $roles = Role::where(function ($q) use ($managerId) {
                $q->whereNull('manager_id')->orWhere('manager_id', $managerId);
            })
            ->orderBy('name')
            ->get();

        return view('manager.users.create', compact('stores', 'roles'));
    }

    public function store(Request $request)
    {
        $managerId = $request->user()->manager_id;
        $storeId = $this->requireStoreId($request);

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:6'],
            'is_active' => ['nullable', 'boolean'],
            'roles' => ['nullable', 'array'],
            'roles.*' => ['integer', 'exists:roles,id'],
        ]);

        $user = User::create([
            'manager_id' => $managerId,
            'store_id' => $storeId,
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'is_active' => $data['is_active'] ?? true,
            'is_super_admin' => false,
        ]);

        $roles = $request->input('roles', []);
        $allowedRoleIds = Role::where(function ($q) use ($managerId) {
                $q->whereNull('manager_id')->orWhere('manager_id', $managerId);
            })
            ->pluck('id')
            ->toArray();
        $roles = array_values(array_intersect($roles, $allowedRoleIds));
        if (!empty($roles)) {
            $user->roles()->sync($roles);
        }
        $this->logAudit($request, $user, 'create', null, $this->snapshotUser($user));

        return redirect()->route('manager.users.index')
            ->with('success', 'User created.');
    }

    public function edit(Request $request, User $user)
    {
        $managerId = $request->user()->manager_id;
        $storeId = $this->requireStoreId($request);

        if ($user->manager_id !== $managerId || $user->store_id !== $storeId || $user->is_super_admin) {
            abort(403);
        }

        $stores = Store::where('manager_id', $managerId)
            ->where('id', $storeId)
            ->orderBy('name')
            ->get();
        $roles = Role::where(function ($q) use ($managerId) {
                $q->whereNull('manager_id')->orWhere('manager_id', $managerId);
            })
            ->orderBy('name')
            ->get();
        $selectedRoles = $user->roles()->pluck('roles.id')->toArray();

        return view('manager.users.edit', compact('user', 'stores', 'roles', 'selectedRoles'));
    }

    public function update(Request $request, User $user)
    {
        $managerId = $request->user()->manager_id;
        $storeId = $this->requireStoreId($request);

        if ($user->manager_id !== $managerId || $user->store_id !== $storeId || $user->is_super_admin) {
            abort(403);
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email,' . $user->id],
            'password' => ['nullable', 'string', 'min:6'],
            'is_active' => ['nullable', 'boolean'],
            'roles' => ['nullable', 'array'],
            'roles.*' => ['integer', 'exists:roles,id'],
        ]);

        $before = $this->snapshotUser($user);
        $user->name = $data['name'];
        $user->email = $data['email'];
        $user->store_id = $storeId;
        $user->is_active = $data['is_active'] ?? $user->is_active;
        if (!empty($data['password'])) {
            $user->password = Hash::make($data['password']);
        }
        $user->save();

        $roles = $request->input('roles', []);
        $allowedRoleIds = Role::where(function ($q) use ($managerId) {
                $q->whereNull('manager_id')->orWhere('manager_id', $managerId);
            })
            ->pluck('id')
            ->toArray();
        $roles = array_values(array_intersect($roles, $allowedRoleIds));
        $user->roles()->sync($roles);
        $this->logAudit($request, $user, 'update', $before, $this->snapshotUser($user));

        return redirect()->route('manager.users.index')
            ->with('success', 'User updated.');
    }

    public function destroy(Request $request, User $user)
    {
        $managerId = $request->user()->manager_id;
        $storeId = $this->requireStoreId($request);

        if ($user->manager_id !== $managerId || $user->store_id !== $storeId || $user->is_super_admin) {
            abort(403);
        }

        if ($user->id === $request->user()->id) {
            return redirect()->route('manager.users.index')
                ->with('error', 'You cannot delete your own account.');
        }

        $before = $this->snapshotUser($user);
        $user->delete();
        $this->logAudit($request, $user, 'delete', $before, null);

        return redirect()->route('manager.users.index')
            ->with('success', 'User deleted.');
    }
}
