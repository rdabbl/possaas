@extends('admin.layout')

@section('content')
    <h1>New Discount</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.discounts.store') }}">
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
                <label>Name</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>Type</label>
                <select name="type">
                    <option value="percent" selected>Percent</option>
                    <option value="fixed">Fixed</option>
                </select>
            </div>
            <div class="field">
                <label>Value</label>
                <input name="value" type="number" step="0.01" min="0" value="{{ old('value', 0) }}" required>
            </div>
            <div class="field">
                <label>Scope</label>
                <select name="scope">
                    <option value="order" selected>Order</option>
                    <option value="item">Item</option>
                </select>
            </div>
            <div class="field">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" selected>Yes</option>
                    <option value="0">No</option>
                </select>
            </div>
            <button class="btn" type="submit">Create Discount</button>
            <a class="btn secondary" href="{{ route('admin.discounts.index') }}">Cancel</a>
        </form>
    </div>
@endsection
