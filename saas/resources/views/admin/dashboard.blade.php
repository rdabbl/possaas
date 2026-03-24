@extends('admin.layout')

@section('content')
    <h1>{{ t("Dashboard") }}</h1>
    <p class="muted">{{ t("Quick overview of your SaaS.") }}</p>

    <div class="grid">
        <div class="card">
            <div class="muted">{{ t("Managers") }}</div>
            <h2>{{ $stats['managers'] }}</h2>
        </div>
        <div class="card">
            <div class="muted">{{ t("Stores") }}</div>
            <h2>{{ $stats['stores'] }}</h2>
        </div>
        <div class="card">
            <div class="muted">{{ t("Devices") }}</div>
            <h2>{{ $stats['devices'] }}</h2>
        </div>
        <div class="card">
            <div class="muted">{{ t("Users") }}</div>
            <h2>{{ $stats['users'] }}</h2>
        </div>
        <div class="card">
            <div class="muted">{{ t("Products") }}</div>
            <h2>{{ $stats['products'] }}</h2>
        </div>
        <div class="card">
            <div class="muted">{{ t("Sales") }}</div>
            <h2>{{ $stats['sales'] }}</h2>
        </div>
    </div>
@endsection
