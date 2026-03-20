@extends('tenant.layout')

@section('content')
    <h1>Edit Discount</h1>

    <div class="card">
        <form method="POST" action="{{ route('tenant.discounts.update', $discount) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name', $discount->name) }}" required>
            </div>
            <div class="field">
                <label>Value</label>
                <input name="value" type="number" step="0.01" min="0" value="{{ old('value', $discount->value) }}" required>
            </div>
            <div class="field">
                <label>Type</label>
                <select name="type">
                    <option value="percent" {{ old('type', $discount->type) === 'percent' ? 'selected' : '' }}>Percent</option>
                    <option value="fixed" {{ old('type', $discount->type) === 'fixed' ? 'selected' : '' }}>Fixed</option>
                </select>
            </div>
            <div class="field">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" {{ old('is_active', $discount->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('is_active', $discount->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <button class="btn" type="submit">Save</button>
            <a class="btn secondary" href="{{ route('tenant.discounts.index') }}">Cancel</a>
        </form>
    </div>
@endsection
