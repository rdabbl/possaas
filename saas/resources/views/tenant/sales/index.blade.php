@extends('tenant.layout')

@section('content')
    <h1>Sales</h1>
    <p class="muted">Recent sales.</p>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Status</th>
                    <th>Subtotal</th>
                    <th>Tax</th>
                    <th>Total</th>
                    <th>Ordered At</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($sales as $sale)
                    <tr>
                        <td>{{ $sale->id }}</td>
                        <td>{{ $sale->status }}</td>
                        <td>{{ number_format((float) $sale->subtotal, 2) }}</td>
                        <td>{{ number_format((float) $sale->tax_total, 2) }}</td>
                        <td>{{ number_format((float) $sale->grand_total, 2) }}</td>
                        <td>{{ $sale->ordered_at }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('tenant.sales.show', $sale) }}">View</a>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $sales->links() }}
    </div>
@endsection
