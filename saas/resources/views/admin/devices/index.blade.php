@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>Devices</h1>
            <p class="muted">Manage POS and kiosk devices.</p>
        </div>
        <a class="btn" href="{{ route('admin.devices.create') }}">New Device</a>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.devices.index') }}" class="row">
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
                    <th>Store</th>
                    <th>Name</th>
                    <th>Type</th>
                    <th>Platform</th>
                    <th>Active</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($devices as $device)
                    <tr>
                        <td>{{ $device->id }}</td>
                        <td>{{ $device->tenant?->name }}</td>
                        <td>{{ $device->store?->name }}</td>
                        <td>{{ $device->name }}</td>
                        <td>{{ $device->type }}</td>
                        <td>{{ $device->platform }}</td>
                        <td>{{ $device->is_active ? 'Yes' : 'No' }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $devices->links() }}
    </div>
@endsection
