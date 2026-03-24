@extends('manager.layout')

@section('content')
    <h1>Sale #{{ $sale->id }}</h1>
    <p class="muted">Status: {{ $sale->status }}</p>

    <div class="grid">
        <div class="card">
            <h3>{{ t("Summary") }}</h3>
            <p>Subtotal: {{ number_format((float) $sale->subtotal, 2) }}</p>
            <p>Discount: {{ number_format((float) $sale->discount_total, 2) }}</p>
            <p>Tax: {{ number_format((float) $sale->tax_total, 2) }}</p>
            <p><strong>Total: {{ number_format((float) $sale->grand_total, 2) }}</strong></p>
        </div>
        <div class="card">
            <h3>{{ t("Payments") }}</h3>
            <table>
                <thead>
                    <tr>
                        <th>{{ t("Method") }}</th>
                        <th>{{ t("Amount") }}</th>
                        <th>{{ t("Paid At") }}</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($sale->payments as $payment)
                        <tr>
                            <td>{{ $payment->paymentMethod?->name }}</td>
                            <td>{{ number_format((float) $payment->amount, 2) }}</td>
                            <td>{{ $payment->paid_at }}</td>
                        </tr>
                    @empty
                        <tr><td colspan="3" class="muted">{{ t("No payments") }}</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <div class="card" style="margin-top: 16px;">
        <h3>{{ t("Items") }}</h3>
        <table>
            <thead>
                <tr>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Qty") }}</th>
                    <th>{{ t("Unit Price") }}</th>
                    <th>{{ t("Total") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($sale->items as $item)
                    <tr>
                        <td>{{ $item->name }}</td>
                        <td>{{ $item->quantity }}</td>
                        <td>{{ number_format((float) $item->unit_price, 2) }}</td>
                        <td>{{ number_format((float) $item->total, 2) }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>
@endsection
