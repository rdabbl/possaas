<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\Role;
use App\Models\Store;
use App\Models\User;
use App\Models\UserAudit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    private function managerStores(int $managerId)
    {
        return Store::where('manager_id', $managerId)
            ->orderBy('name')
            ->get();
    }

    private function resolveStoreFilter(Request $request, int $managerId): ?int
    {
        $storeId = $request->query('store_id');
        if (!$storeId) {
            return null;
        }
        $storeId = (int) $storeId;
        $exists = Store::where('manager_id', $managerId)->where('id', $storeId)->exists();
        return $exists ? $storeId : null;
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
        $stores = $this->managerStores($managerId);
        $storeFilter = $this->resolveStoreFilter($request, $managerId);

        $users = User::with('store')
            ->where('manager_id', $managerId)
            ->where('is_super_admin', false)
            ->when($storeFilter, fn ($q) => $q->where('store_id', $storeFilter))
            ->orderBy('id', 'desc')
            ->paginate(20)
            ->withQueryString();

        return view('manager.users.index', compact('users', 'stores', 'storeFilter'));
    }

    public function create(Request $request)
    {
        $managerId = $request->user()->manager_id;
        $stores = $this->managerStores($managerId);
        if ($stores->isEmpty()) {
            return redirect()->route('manager.no_store');
        }
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

        $data = $request->validate([
            'store_id' => [
                'required',
                'integer',
                Rule::exists('stores', 'id')->where('manager_id', $managerId),
            ],
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:6'],
            'is_active' => ['nullable', 'boolean'],
            'roles' => ['nullable', 'array'],
            'roles.*' => ['integer', 'exists:roles,id'],
        ]);

        $user = User::create([
            'manager_id' => $managerId,
            'store_id' => $data['store_id'],
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

        if ($user->manager_id !== $managerId || $user->is_super_admin) {
            abort(403);
        }

        $stores = $this->managerStores($managerId);
        if ($stores->isEmpty()) {
            return redirect()->route('manager.no_store');
        }
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

        if ($user->manager_id !== $managerId || $user->is_super_admin) {
            abort(403);
        }

        $data = $request->validate([
            'store_id' => [
                'required',
                'integer',
                Rule::exists('stores', 'id')->where('manager_id', $managerId),
            ],
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
        $user->store_id = $data['store_id'];
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

        if ($user->manager_id !== $managerId || $user->is_super_admin) {
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

    public function duplicate(Request $request, User $user)
    {
        $managerId = $request->user()->manager_id;
        if ($user->manager_id !== $managerId || $user->is_super_admin) {
            abort(403);
        }

        $newEmail = $this->uniqueEmail($user->email);
        $newUser = User::create([
            'manager_id' => $managerId,
            'store_id' => $user->store_id,
            'name' => trim($user->name) . ' (Copy)',
            'email' => $newEmail,
            'password' => Hash::make(Str::random(12)),
            'is_active' => false,
            'is_super_admin' => false,
        ]);

        $roleIds = $user->roles()->pluck('roles.id')->toArray();
        if (!empty($roleIds)) {
            $newUser->roles()->sync($roleIds);
        }

        $this->logAudit($request, $newUser, 'duplicate', null, $this->snapshotUser($newUser));

        return redirect()->route('manager.users.edit', $newUser)
            ->with('success', 'User duplicated. Update email/password.');
    }

    private function uniqueEmail(string $email): string
    {
        $email = trim($email);
        $local = $email;
        $domain = 'example.local';
        if (str_contains($email, '@')) {
            [$local, $domain] = explode('@', $email, 2);
        }
        $local = preg_replace('/\\+.*/', '', $local) ?? $local;

        $candidate = $local . '+copy' . time() . '@' . $domain;
        while (User::where('email', $candidate)->exists()) {
            $candidate = $local . '+copy' . Str::random(6) . '@' . $domain;
        }
        return $candidate;
    }
}
