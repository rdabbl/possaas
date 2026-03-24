@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Stores") }}</h1>
            <p class="muted">{{ t("Manage manager stores.") }}</p>
        </div>
        <a class="btn" href="{{ route('admin.stores.create') }}">{{ t("New Store") }}</a>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.stores.index') }}" class="row">
            <div style="min-width: 220px;">
                <label>{{ t("Filter by Manager") }}</label>
                <select name="manager_id">
                    <option value="">{{ t("All Managers") }}</option>
                    @foreach ($managers as $manager)
                        <option value="{{ $manager->id }}" {{ (string) $managerId === (string) $manager->id ? 'selected' : '' }}>
                            {{ $manager->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div style="align-self: end;">
                <button class="btn" type="submit">{{ t("Filter") }}</button>
            </div>
        </form>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>{{ t("ID") }}</th>
                    <th>{{ t("Manager") }}</th>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Code") }}</th>
                    <th>{{ t("Stock") }}</th>
                    <th>{{ t("Active") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($stores as $store)
                    <tr>
                        <td>{{ $store->id }}</td>
                        <td>{{ $store->manager?->name }}</td>
                        <td>{{ $store->name }}</td>
                        <td>{{ $store->code }}</td>
                        <td>{{ $store->stock_enabled ? 'Enabled' : 'Disabled' }}</td>
                        <td>{{ $store->is_active ? 'Yes' : 'No' }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $stores->links() }}
    </div>
@endsection
