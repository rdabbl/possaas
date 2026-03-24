@extends('manager.layout')

@section('content')
    <h1>{{ t("Edit Tax") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('manager.taxes.update', $tax) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name', $tax->name) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Rate") }}</label>
                <input name="rate" type="number" step="0.01" min="0" value="{{ old('rate', $tax->rate) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Type") }}</label>
                <select name="type">
                    <option value="percent" {{ old('type', $tax->type) === 'percent' ? 'selected' : '' }}>Percent</option>
                    <option value="fixed" {{ old('type', $tax->type) === 'fixed' ? 'selected' : '' }}>Fixed</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" {{ old('is_active', $tax->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('is_active', $tax->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Save") }}</button>
            <a class="btn secondary" href="{{ route('manager.taxes.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
