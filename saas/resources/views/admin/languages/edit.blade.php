@extends('admin.layout')

@section('content')
    <h1>{{ t("Edit Language") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.languages.update', $language) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>{{ t("Code") }}</label>
                <input name="code" value="{{ old('code', $language->code) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name', $language->name) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Native Name") }}</label>
                <input name="native_name" value="{{ old('native_name', $language->native_name) }}">
            </div>
            <div class="field">
                <label>{{ t("Direction") }}</label>
                <select name="direction">
                    <option value="ltr" {{ old('direction', $language->direction) === 'ltr' ? 'selected' : '' }}>LTR</option>
                    <option value="rtl" {{ old('direction', $language->direction) === 'rtl' ? 'selected' : '' }}>RTL</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" {{ old('is_active', $language->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('is_active', $language->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Default") }}</label>
                <select name="is_default">
                    <option value="1" {{ old('is_default', $language->is_default ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('is_default', $language->is_default ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Save") }}</button>
            <a class="btn secondary" href="{{ route('admin.languages.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
