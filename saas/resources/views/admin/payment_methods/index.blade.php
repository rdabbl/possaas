@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>Payment Methods</h1>
            <p class="muted">Manage cash and other payment types.</p>
        </div>
        <a class="btn" href="{{ route('admin.payment_methods.create') }}">New Method</a>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.payment_methods.index') }}" class="row">
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
                    <th>Type</th>
                    <th>Default</th>
                    <th>Active</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($methods as $method)
                    <tr>
                        <td>{{ $method->id }}</td>
                        <td>{{ $method->tenant?->name }}</td>
                        <td>{{ $method->name }}</td>
                        <td>{{ $method->type }}</td>
                        <td>{{ $method->is_default ? 'Yes' : 'No' }}</td>
                        <td>{{ $method->is_active ? 'Yes' : 'No' }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $methods->links() }}
    </div>
@endsection
