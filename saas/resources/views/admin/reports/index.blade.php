@extends('admin.layout')

@section('content')
    <h1>Sales Reports</h1>
    <p class="muted">Daily, monthly, and top products.</p>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.reports.index') }}" class="row">
            <div style="min-width: 220px;">
                <label>Tenant</label>
                <select name="tenant_id">
                    <option value="">All Tenants</option>
                    @foreach ($tenants as $tenant)
                        <option value="{{ $tenant->id }}" {{ (string) $tenantId === (string) $tenant->id ? 'selected' : '' }}>
                            {{ $tenant->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div>
                <label>From</label>
                <input type="date" name="from" value="{{ $from }}">
            </div>
            <div>
                <label>To</label>
                <input type="date" name="to" value="{{ $to }}">
            </div>
            <div style="align-self: end;">
                <button class="btn" type="submit">Apply</button>
            </div>
        </form>
    </div>

    <div class="grid">
        <div class="card">
            <h3>Daily Sales</h3>
            <table>
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Count</th>
                        <th>Total</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($daily as $row)
                        <tr>
                            <td>{{ $row->day }}</td>
                            <td>{{ $row->count }}</td>
                            <td>{{ number_format((float) $row->total, 2) }}</td>
                        </tr>
                    @empty
                        <tr><td colspan="3" class="muted">No data</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="card">
            <h3>Monthly Sales</h3>
            <table>
                <thead>
                    <tr>
                        <th>Month</th>
                        <th>Count</th>
                        <th>Total</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($monthly as $row)
                        <tr>
                            <td>{{ $row->month }}</td>
                            <td>{{ $row->count }}</td>
                            <td>{{ number_format((float) $row->total, 2) }}</td>
                        </tr>
                    @empty
                        <tr><td colspan="3" class="muted">No data</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <div class="card" style="margin-top: 16px;">
        <h3>Top Products</h3>
        <table>
            <thead>
                <tr>
                    <th>Product</th>
                    <th>Qty</th>
                    <th>Total</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($topProducts as $row)
                    <tr>
                        <td>{{ $row->name }}</td>
                        <td>{{ $row->qty }}</td>
                        <td>{{ number_format((float) $row->total, 2) }}</td>
                    </tr>
                @empty
                    <tr><td colspan="3" class="muted">No data</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
@endsection
