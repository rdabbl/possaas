@extends('manager.layout')

@section('content')
    <h1>{{ t("Dashboard") }}</h1>
    <p class="muted">{{ t("Overview for your manager.") }}</p>

    <div class="grid">
        <div class="card">
            <div class="muted">{{ t("Products") }}</div>
            <h2>{{ $stats['products'] }}</h2>
        </div>
        <div class="card">
            <div class="muted">{{ t("Customers") }}</div>
            <h2>{{ $stats['customers'] }}</h2>
        </div>
        <div class="card">
            <div class="muted">{{ t("Sales") }}</div>
            <h2>{{ $stats['sales'] }}</h2>
        </div>
    </div>
@endsection
