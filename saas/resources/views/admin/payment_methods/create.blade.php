@extends('admin.layout')

@section('content')
    <h1>New Payment Method</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.payment_methods.store') }}">
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
                    <option value="cash" selected>Cash</option>
                    <option value="card">Card</option>
                    <option value="bank">Bank</option>
                    <option value="other">Other</option>
                </select>
            </div>
            <div class="field">
                <label>Default</label>
                <select name="is_default">
                    <option value="0" selected>No</option>
                    <option value="1">Yes</option>
                </select>
            </div>
            <div class="field">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" selected>Yes</option>
                    <option value="0">No</option>
                </select>
            </div>
            <button class="btn" type="submit">Create Method</button>
            <a class="btn secondary" href="{{ route('admin.payment_methods.index') }}">Cancel</a>
        </form>
    </div>
@endsection
