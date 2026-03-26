@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Permissions") }}</h1>
            <p class="muted">{{ t("Manage system permissions.") }}</p>
        </div>
        <a class="btn" href="{{ route('admin.permissions.create') }}">{{ t("New Permission") }}</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Description") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($permissions as $permission)
                    <tr>
                        <td>{{ $permission->name }}</td>
                        <td>{{ $permission->description }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.permissions.edit', $permission) }}">{{ t("Edit") }}</a>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $permissions->links() }}
    </div>
@endsection
