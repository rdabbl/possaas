@extends('admin.layout')

@section('content')
    <h1>{{ t("Sales Reports") }}</h1>
    <p class="muted">{{ t("Daily, monthly, and top products.") }}</p>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.reports.index') }}" class="row">
            <div style="min-width: 220px;">
                <label>{{ t("Manager") }}</label>
                <select name="manager_id">
                    <option value="">{{ t("All Managers") }}</option>
                    @foreach ($managers as $manager)
                        <option value="{{ $manager->id }}" {{ (string) $managerId === (string) $manager->id ? 'selected' : '' }}>
                            {{ $manager->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div>
                <label>{{ t("From") }}</label>
                <input type="date" name="from" value="{{ $from }}">
            </div>
            <div>
                <label>{{ t("To") }}</label>
                <input type="date" name="to" value="{{ $to }}">
            </div>
            <div style="align-self: end;">
                <button class="btn" type="submit">{{ t("Apply") }}</button>
            </div>
        </form>
    </div>

    <div class="grid">
        <div class="card">
            <h3>{{ t("Daily Sales") }}</h3>
            <table>
                <thead>
                    <tr>
                        <th>{{ t("Date") }}</th>
                        <th>{{ t("Count") }}</th>
                        <th>{{ t("Total") }}</th>
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
                        <tr><td colspan="3" class="muted">{{ t("No data") }}</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="card">
            <h3>{{ t("Monthly Sales") }}</h3>
            <table>
                <thead>
                    <tr>
                        <th>{{ t("Month") }}</th>
                        <th>{{ t("Count") }}</th>
                        <th>{{ t("Total") }}</th>
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
                        <tr><td colspan="3" class="muted">{{ t("No data") }}</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <div class="card" style="margin-top: 16px;">
        <h3>{{ t("Top Products") }}</h3>
        <table>
            <thead>
                <tr>
                    <th>{{ t("Product") }}</th>
                    <th>{{ t("Qty") }}</th>
                    <th>{{ t("Total") }}</th>
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
                    <tr><td colspan="3" class="muted">{{ t("No data") }}</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
@endsection
