@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>Tenants</h1>
            <p class="muted">Manage companies and limits.</p>
        </div>
        <a class="btn" href="{{ route('admin.tenants.create') }}">New Tenant</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Slug</th>
                    <th>Active</th>
                    <th>Max Stores</th>
                    <th>Max Devices</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($tenants as $tenant)
                    <tr>
                        <td>{{ $tenant->id }}</td>
                        <td>{{ $tenant->name }}</td>
                        <td>{{ $tenant->slug }}</td>
                        <td>{{ $tenant->is_active ? 'Yes' : 'No' }}</td>
                        <td>{{ $tenant->max_stores ?? 'Unlimited' }}</td>
                        <td>{{ $tenant->max_devices ?? 'Unlimited' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.tenants.edit', $tenant) }}">Edit</a>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $tenants->links() }}
    </div>
@endsection
