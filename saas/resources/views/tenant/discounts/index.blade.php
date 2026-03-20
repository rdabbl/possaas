@extends('tenant.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>Discounts</h1>
            <p class="muted">Manage your discounts.</p>
        </div>
        <a class="btn" href="{{ route('tenant.discounts.create') }}">New Discount</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Value</th>
                    <th>Type</th>
                    <th>Active</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($discounts as $discount)
                    <tr>
                        <td>{{ $discount->id }}</td>
                        <td>{{ $discount->name }}</td>
                        <td>{{ $discount->value }}</td>
                        <td>{{ $discount->type }}</td>
                        <td>{{ $discount->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('tenant.discounts.edit', $discount) }}">Edit</a>
                            <form method="POST" action="{{ route('tenant.discounts.destroy', $discount) }}" style="display:inline-block" onsubmit="return confirm('Delete this discount?');">
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
