@extends('admin.layout')

@section('content')
    <h1>New Device</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.devices.store') }}">
            @csrf
            <div class="field">
                <label>Tenant</label>
                <select name="tenant_id" required>
                    <option value="">Select Tenant</option>
                    @foreach ($tenants as $tenant)
                        <option value="{{ $tenant->id }}" {{ old('tenant_id') == $tenant->id ? 'selected' : '' }}>
                            {{ $tenant->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>Store</label>
                <select name="store_id" required>
                    <option value="">Select Store</option>
                    @foreach ($stores as $store)
                        <option value="{{ $store->id }}" {{ old('store_id') == $store->id ? 'selected' : '' }}>
                            {{ $store->name }} ({{ $store->tenant?->name }})
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>Type</label>
                <select name="type">
                    <option value="pos" selected>POS</option>
                    <option value="kiosk">Kiosk</option>
                </select>
            </div>
            <div class="field">
                <label>Platform</label>
                <input name="platform" value="{{ old('platform', 'android') }}">
            </div>
            <div class="field">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" selected>Yes</option>
                    <option value="0">No</option>
                </select>
            </div>
            <button class="btn" type="submit">Create Device</button>
            <a class="btn secondary" href="{{ route('admin.devices.index') }}">Cancel</a>
        </form>
    </div>
@endsection
