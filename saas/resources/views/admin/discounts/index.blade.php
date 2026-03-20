@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>Discounts</h1>
            <p class="muted">Manage discounts.</p>
        </div>
        <a class="btn" href="{{ route('admin.discounts.create') }}">New Discount</a>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.discounts.index') }}" class="row">
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
                    <th>Value</th>
                    <th>Scope</th>
                    <th>Active</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($discounts as $discount)
                    <tr>
                        <td>{{ $discount->id }}</td>
                        <td>{{ $discount->tenant?->name }}</td>
                        <td>{{ $discount->name }}</td>
                        <td>{{ $discount->type }}</td>
                        <td>{{ $discount->value }}</td>
                        <td>{{ $discount->scope }}</td>
                        <td>{{ $discount->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.discounts.edit', $discount) }}">Edit</a>
                            <form method="POST" action="{{ route('admin.discounts.destroy', $discount) }}" style="display:inline-block" onsubmit="return confirm('Delete this discount?');">
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
        {{ $discounts->links() }}
    </div>
@endsection
