@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Users") }}</h1>
            <p class="muted">{{ t("Create admin and manager users, then assign roles.") }}</p>
        </div>
        <a class="btn" href="{{ route('admin.users.create') }}">{{ t("New User") }}</a>
    </div>

    <div class="card" style="margin-bottom: 12px;">
        <form method="GET" action="{{ route('admin.users.index') }}" class="row" style="align-items: flex-end;">
            <div class="field" style="min-width: 200px;">
                <label>{{ t("Type") }}</label>
                <select name="type">
                    <option value="">{{ t("All") }}</option>
                    <option value="admin" {{ $type === 'admin' ? 'selected' : '' }}>{{ t("Admin") }}</option>
                    <option value="manager" {{ $type === 'manager' ? 'selected' : '' }}>{{ t("Manager") }}</option>
                </select>
            </div>
            <div class="field" style="min-width: 240px;">
                <label>{{ t("Manager") }}</label>
                <select name="manager_id">
                    <option value="">{{ t("All Managers") }}</option>
                    @foreach ($managers as $manager)
                        <option value="{{ $manager->id }}" {{ (string) $managerId === (string) $manager->id ? 'selected' : '' }}>
                            {{ $manager->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field" style="margin-bottom: 4px;">
                <button class="btn" type="submit">{{ t("Filter") }}</button>
            </div>
        </form>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Username") }}</th>
                    <th>{{ t("Type") }}</th>
                    <th>{{ t("Manager") }}</th>
                    <th>{{ t("Roles") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($users as $user)
                    <tr>
                        <td>{{ $user->name }}<br><span class="muted">{{ $user->email }}</span></td>
                        <td>{{ $user->username }}</td>
                        <td>{{ $user->is_super_admin ? t("Admin") : t("Manager") }}</td>
                        <td>{{ $user->manager?->name ?? '-' }}</td>
                        <td>{{ $user->roles->pluck('name')->join(', ') ?: '-' }}</td>
                        <td>{{ $user->is_active ? t("Yes") : t("No") }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.users.edit', $user) }}">{{ t("Edit") }}</a>
                            <form method="POST" action="{{ route('admin.users.destroy', $user) }}" style="display:inline;">
                                @csrf
                                @method('DELETE')
                                <button class="btn secondary" type="submit" onclick="return confirm('{{ t("Delete this user?") }}')">
                                    {{ t("Delete") }}
                                </button>
                            </form>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="7" class="muted">{{ t("No users found.") }}</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $users->links() }}
    </div>
@endsection
