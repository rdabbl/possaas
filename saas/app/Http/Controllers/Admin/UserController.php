<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Manager;
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
        $type = $request->query('type');
        $managerId = $request->query('manager_id');
        $managers = Manager::orderBy('name')->get();

        $users = User::with(['manager', 'store', 'roles'])
            ->when($type === 'admin', fn ($query) => $query->where('is_super_admin', true))
            ->when($type === 'manager', fn ($query) => $query->where('is_super_admin', false)->whereNotNull('manager_id'))
            ->when($managerId, fn ($query) => $query->where('manager_id', $managerId))
            ->orderBy('id', 'desc')
            ->paginate(20)
            ->withQueryString();

        return view('admin.users.index', compact('users', 'managers', 'type', 'managerId'));
    }

    public function create()
    {
        return view('admin.users.create', $this->formOptions());
    }

    public function store(Request $request)
    {
        $data = $this->validatedData($request);
        $accountType = $data['account_type'];
        $managerId = $accountType === 'manager' ? (int) $data['manager_id'] : null;

        $user = User::create([
            'manager_id' => $managerId,
            'store_id' => $this->storeIdForManager($data['store_id'] ?? null, $managerId),
            'name' => $data['name'],
            'username' => $data['username'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'pin' => !empty($data['pin']) ? Hash::make($data['pin']) : null,
            'is_super_admin' => $accountType === 'admin',
            'is_active' => $data['is_active'] ?? true,
            'allow_loyalty_redeem' => $accountType === 'manager'
                ? ($data['allow_loyalty_redeem'] ?? null)
                : null,
        ]);

        $this->syncAllowedRoles($user, $request->input('roles', []), $accountType, $managerId);

        return redirect()->route('admin.users.index')
            ->with('success', 'User created.');
    }

    public function edit(User $user)
    {
        $selectedRoles = $user->roles()->pluck('roles.id')->toArray();

        return view('admin.users.edit', array_merge(
            $this->formOptions(),
            compact('user', 'selectedRoles')
        ));
    }

    public function update(Request $request, User $user)
    {
        $data = $this->validatedData($request, $user);
        $accountType = $data['account_type'];
        $managerId = $accountType === 'manager' ? (int) $data['manager_id'] : null;

        $user->manager_id = $managerId;
        $user->store_id = $this->storeIdForManager($data['store_id'] ?? null, $managerId);
        $user->name = $data['name'];
        $user->username = $data['username'];
        $user->email = $data['email'];
        $user->is_super_admin = $accountType === 'admin';
        $user->is_active = $data['is_active'] ?? $user->is_active;
        $user->allow_loyalty_redeem = $accountType === 'manager'
            ? ($data['allow_loyalty_redeem'] ?? null)
            : null;

        if (!empty($data['password'])) {
            $user->password = Hash::make($data['password']);
        }
        if (!empty($data['pin'])) {
            $user->pin = Hash::make($data['pin']);
        }

        $user->save();
        $this->syncAllowedRoles($user, $request->input('roles', []), $accountType, $managerId);

        return redirect()->route('admin.users.index')
            ->with('success', 'User updated.');
    }

    public function destroy(Request $request, User $user)
    {
        if ($user->id === $request->user()?->id) {
            return redirect()->route('admin.users.index')
                ->with('error', 'You cannot delete your own account.');
        }

        $user->delete();

        return redirect()->route('admin.users.index')
            ->with('success', 'User deleted.');
    }

    private function formOptions(): array
    {
        return [
            'managers' => Manager::orderBy('name')->get(),
            'stores' => Store::with('manager')->orderBy('name')->get(),
            'roles' => Role::with('manager')->orderBy('name')->get(),
        ];
    }

    private function validatedData(Request $request, ?User $user = null): array
    {
        $userId = $user?->id;

        return $request->validate([
            'account_type' => ['required', Rule::in(['admin', 'manager'])],
            'manager_id' => ['nullable', 'required_if:account_type,manager', 'integer', 'exists:managers,id'],
            'store_id' => ['nullable', 'integer', 'exists:stores,id'],
            'name' => ['required', 'string', 'max:255'],
            'username' => ['required', 'string', 'max:255', Rule::unique('users', 'username')->ignore($userId)],
            'email' => ['required', 'email', 'max:255', Rule::unique('users', 'email')->ignore($userId)],
            'password' => [$user ? 'nullable' : 'required', 'string', 'min:6'],
            'pin' => ['nullable', 'digits:4'],
            'is_active' => ['nullable', 'boolean'],
            'allow_loyalty_redeem' => ['nullable', 'boolean'],
            'roles' => ['nullable', 'array'],
            'roles.*' => ['integer', 'exists:roles,id'],
        ]);
    }

    private function storeIdForManager(?int $storeId, ?int $managerId): ?int
    {
        if (!$storeId || !$managerId) {
            return null;
        }

        return Store::where('manager_id', $managerId)->where('id', $storeId)->exists()
            ? $storeId
            : null;
    }

    private function syncAllowedRoles(User $user, array $roleIds, string $accountType, ?int $managerId): void
    {
        $allowed = Role::query()
            ->when($accountType === 'admin', fn ($query) => $query->whereNull('manager_id'))
            ->when($accountType === 'manager', function ($query) use ($managerId) {
                $query->where(function ($inner) use ($managerId) {
                    $inner->whereNull('manager_id')->orWhere('manager_id', $managerId);
                });
            })
            ->pluck('id')
            ->toArray();

        $user->roles()->sync(array_values(array_intersect($roleIds, $allowed)));
    }
}
