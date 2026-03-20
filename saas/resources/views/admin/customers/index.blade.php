@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>Customers</h1>
            <p class="muted">Manage customers.</p>
        </div>
        <a class="btn" href="{{ route('admin.customers.create') }}">New Customer</a>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.customers.index') }}" class="row">
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
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Active</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($customers as $customer)
                    <tr>
                        <td>{{ $customer->id }}</td>
                        <td>{{ $customer->tenant?->name }}</td>
                        <td>{{ $customer->name }}</td>
                        <td>{{ $customer->email }}</td>
                        <td>{{ $customer->phone }}</td>
                        <td>{{ $customer->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.customers.edit', $customer) }}">Edit</a>
                            <form method="POST" action="{{ route('admin.customers.destroy', $customer) }}" style="display:inline-block" onsubmit="return confirm('Delete this customer?');">
                                @csrf
                                @method('DELETE')
                                <button class="btn secondary" type="submit">Delete</button>
                            </form>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $customers->links() }}
    </div>
@endsection
