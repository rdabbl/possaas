@extends('admin.layout')

@section('content')
    <h1>Dashboard</h1>
    <p class="muted">Quick overview of your SaaS.</p>

    <div class="grid">
        <div class="card">
            <div class="muted">Tenants</div>
            <h2>{{ $stats['tenants'] }}</h2>
        </div>
        <div class="card">
            <div class="muted">Stores</div>
            <h2>{{ $stats['stores'] }}</h2>
        </div>
        <div class="card">
            <div class="muted">Devices</div>
            <h2>{{ $stats['devices'] }}</h2>
        </div>
        <div class="card">
            <div class="muted">Users</div>
            <h2>{{ $stats['users'] }}</h2>
        </div>
        <div class="card">
            <div class="muted">Products</div>
            <h2>{{ $stats['products'] }}</h2>
        </div>
        <div class="card">
            <div class="muted">Sales</div>
            <h2>{{ $stats['sales'] }}</h2>
        </div>
    </div>
@endsection
