@extends('tenant.layout')

@section('content')
    <h1>Dashboard</h1>
    <p class="muted">Overview for your tenant.</p>

    <div class="grid">
        <div class="card">
            <div class="muted">Products</div>
            <h2>{{ $stats['products'] }}</h2>
        </div>
        <div class="card">
            <div class="muted">Customers</div>
            <h2>{{ $stats['customers'] }}</h2>
        </div>
        <div class="card">
            <div class="muted">Sales</div>
            <h2>{{ $stats['sales'] }}</h2>
        </div>
    </div>
@endsection
