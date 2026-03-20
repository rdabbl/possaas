@extends('admin.layout')

@section('content')
    <h1>New Tax</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.taxes.store') }}">
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
                <label>Rate</label>
                <input name="rate" type="number" step="0.0001" min="0" value="{{ old('rate', 0) }}" required>
            </div>
            <div class="field">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" selected>Yes</option>
                    <option value="0">No</option>
                </select>
            </div>
            <button class="btn" type="submit">Create Tax</button>
            <a class="btn secondary" href="{{ route('admin.taxes.index') }}">Cancel</a>
        </form>
    </div>
@endsection
