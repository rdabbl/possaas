@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>Roles</h1>
            <p class="muted">Manage roles and permissions.</p>
        </div>
        <a class="btn" href="{{ route('admin.roles.create') }}">New Role</a>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.roles.index') }}" class="row">
            <div style="min-width: 220px;">
                <label>Filter by Tenant</label>
                <select name="tenant_id">
                    <option value="">All Tenants</option>
                    @foreach ($tenants as $tenant)
                        <option value="{{ $tenant->id }}" {{ (string) $tenantId === (string) $tenant->id ? 'selected' : '' }}>
                            {{ $tenant->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div style="align-self: end;">
                <button class="btn" type="submit">Filter</button>
            </div>
        </form>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Tenant</th>
                    <th>Name</th>
                    <th>System</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($roles as $role)
                    <tr>
                        <td>{{ $role->id }}</td>
                        <td>{{ $role->tenant?->name ?? 'Global' }}</td>
                        <td>{{ $role->name }}</td>
                        <td>{{ $role->is_system ? 'Yes' : 'No' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.roles.edit', $role) }}">Edit</a>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $roles->links() }}
    </div>
@endsection
