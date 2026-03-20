@extends('tenant.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>Stores</h1>
            <p class="muted">Manage your stores.</p>
        </div>
        <a class="btn" href="{{ route('tenant.stores.create') }}">New Store</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Code</th>
                    <th>Stock</th>
                    <th>Active</th>
                    <th>Actions</th>
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
                            <a class="btn secondary" href="{{ route('tenant.stores.edit', $store) }}">Edit</a>
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
