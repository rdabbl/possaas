@extends('admin.layout')

@section('content')
    <h1>Edit Customer</h1>
    <p class="muted">Tenant: {{ $customer->tenant?->name }}</p>

    <div class="card">
        <form method="POST" action="{{ route('admin.customers.update', $customer) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name', $customer->name) }}" required>
            </div>
            <div class="field">
                <label>Email</label>
                <input name="email" type="email" value="{{ old('email', $customer->email) }}">
            </div>
            <div class="field">
                <label>Phone</label>
                <input name="phone" value="{{ old('phone', $customer->phone) }}">
            </div>
            <div class="field">
                <label>Address</label>
                <input name="address" value="{{ old('address', $customer->address) }}">
            </div>
            <div class="field">
                <label>Note</label>
                <input name="note" value="{{ old('note', $customer->note) }}">
            </div>
            <div class="field">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" {{ old('is_active', $customer->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('is_active', $customer->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <button class="btn" type="submit">Save</button>
            <a class="btn secondary" href="{{ route('admin.customers.index') }}">Cancel</a>
        </form>
    </div>
@endsection
