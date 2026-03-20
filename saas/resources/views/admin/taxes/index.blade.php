@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>Taxes</h1>
            <p class="muted">Manage tax rates.</p>
        </div>
        <a class="btn" href="{{ route('admin.taxes.create') }}">New Tax</a>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.taxes.index') }}" class="row">
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
                    <th>Rate</th>
                    <th>Active</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($taxes as $tax)
                    <tr>
                        <td>{{ $tax->id }}</td>
                        <td>{{ $tax->tenant?->name }}</td>
                        <td>{{ $tax->name }}</td>
                        <td>{{ $tax->type }}</td>
                        <td>{{ $tax->rate }}</td>
                        <td>{{ $tax->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.taxes.edit', $tax) }}">Edit</a>
                            <form method="POST" action="{{ route('admin.taxes.destroy', $tax) }}" style="display:inline-block" onsubmit="return confirm('Delete this tax?');">
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
        {{ $taxes->links() }}
    </div>
@endsection
