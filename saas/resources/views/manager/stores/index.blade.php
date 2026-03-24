@extends('manager.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Stores") }}</h1>
            <p class="muted">{{ t("Manage your stores.") }}</p>
        </div>
        <a class="btn" href="{{ route('manager.stores.create') }}">{{ t("New Store") }}</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>{{ t("ID") }}</th>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Code") }}</th>
                    <th>{{ t("Stock") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($stores as $store)
                    <tr>
                        <td>{{ $store->id }}</td>
                        <td>{{ $store->name }}</td>
                        <td>{{ $store->code }}</td>
                        <td>{{ $store->stock_enabled ? 'Yes' : 'No' }}</td>
                        <td>{{ $store->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('manager.stores.edit', $store) }}">{{ t("Edit") }}</a>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $stores->links() }}
    </div>
@endsection
