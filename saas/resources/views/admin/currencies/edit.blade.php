@extends('admin.layout')

@section('content')
    <h1>{{ t("Edit Currency") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.currencies.update', $currency) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name', $currency->name) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Code (3 letters)") }}</label>
                <input name="code" maxlength="3" value="{{ old('code', $currency->code) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Symbol") }}</label>
                <input name="symbol" value="{{ old('symbol', $currency->symbol) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" {{ old('is_active', $currency->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('is_active', $currency->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Save") }}</button>
            <a class="btn secondary" href="{{ route('admin.currencies.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
