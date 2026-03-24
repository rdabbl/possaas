@extends('manager.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Users") }}</h1>
            <p class="muted">{{ t("Manage manager users and roles.") }}</p>
        </div>
        <a class="btn" href="{{ route('manager.users.create') }}">{{ t("New User") }}</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>{{ t("ID") }}</th>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Email") }}</th>
                    <th>{{ t("Store") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($users as $user)
                    <tr>
                        <td>{{ $user->id }}</td>
                        <td>{{ $user->name }}</td>
                        <td>{{ $user->email }}</td>
                        <td>{{ $user->store?->name }}</td>
                        <td>{{ $user->is_active ? t("Yes") : t("No") }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('manager.users.edit', $user) }}">{{ t("Edit") }}</a>
                            <form method="POST" action="{{ route('manager.users.destroy', $user) }}" style="display:inline;">
                                @csrf
                                @method('DELETE')
                                <button class="btn secondary" type="submit" onclick="return confirm('{{ t("Delete this user?") }}')">
                                    {{ t("Delete") }}
                                </button>
                            </form>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $users->links() }}
    </div>
@endsection
