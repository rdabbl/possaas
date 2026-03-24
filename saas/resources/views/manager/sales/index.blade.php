@extends('manager.layout')

@section('content')
    <h1>{{ t("Sales") }}</h1>
    <p class="muted">{{ t("Recent sales.") }}</p>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>{{ t("ID") }}</th>
                    <th>{{ t("Status") }}</th>
                    <th>{{ t("Subtotal") }}</th>
                    <th>{{ t("Tax") }}</th>
                    <th>{{ t("Total") }}</th>
                    <th>{{ t("Ordered At") }}</th>
                    <th>{{ t("Actions") }}</th>
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
                            <a class="btn secondary" href="{{ route('manager.sales.show', $sale) }}">{{ t("View") }}</a>
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
