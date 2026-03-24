@extends('admin.layout')

@section('content')
    <h1>{{ t("New Currency") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.currencies.store') }}">
            @csrf
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Code (3 letters)") }}</label>
                <input name="code" maxlength="3" value="{{ old('code') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Symbol") }}</label>
                <input name="symbol" value="{{ old('symbol') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" selected>{{ t("Yes") }}</option>
                    <option value="0">{{ t("No") }}</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Create Currency") }}</button>
            <a class="btn secondary" href="{{ route('admin.currencies.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
