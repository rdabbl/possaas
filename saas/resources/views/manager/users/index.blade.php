@extends('manager.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Users") }}</h1>
            <p class="muted">{{ t("Manage manager users and roles.") }}</p>
        </div>
        <a class="btn" href="{{ route('manager.users.create') }}">{{ t("New User") }}</a>
    </div>

    <div class="card" style="margin-bottom: 12px;">
        <form method="GET" action="{{ route('manager.users.index') }}" class="row" style="gap: 12px; align-items: flex-end;">
            <div class="field" style="min-width: 240px;">
                <label>{{ t("Store") }}</label>
                <select name="store_id">
                    <option value="">{{ t("All") }}</option>
                    @foreach ($stores as $store)
                        <option value="{{ $store->id }}" {{ (string) $storeFilter === (string) $store->id ? 'selected' : '' }}>
                            {{ $store->name }}
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
                    <th>{{ t("Email") }}</th>
                    <th>{{ t("Store") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($users as $user)
                    <tr>
                        <td>{{ $user->name }}</td>
                        <td>{{ $user->username }}</td>
                        <td>{{ $user->email }}</td>
                        <td>{{ $user->store?->name }}</td>
                        <td>{{ $user->is_active ? t("Yes") : t("No") }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('manager.users.edit', $user) }}">{{ t("Edit") }}</a>
                            <form method="POST" action="{{ route('manager.users.duplicate', $user) }}" style="display:inline;">
                                @csrf
                                <button class="btn secondary" type="submit">{{ t("Duplicate") }}</button>
                            </form>
                            <form method="POST" action="{{ route('manager.users.destroy', $user) }}" style="display:inline;">
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
                        <td colspan="6" class="muted">{{ t("No users found.") }}</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $users->links() }}
    </div>
@endsection
