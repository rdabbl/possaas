@extends('admin.layout')

@section('content')
    <h1>{{ t("New Language") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.languages.store') }}">
            @csrf
            <div class="field">
                <label>{{ t("Code") }}</label>
                <input name="code" value="{{ old('code') }}" placeholder="{{ t("en") }}" required>
            </div>
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name') }}" placeholder="{{ t("English") }}" required>
            </div>
            <div class="field">
                <label>{{ t("Native Name") }}</label>
                <input name="native_name" value="{{ old('native_name') }}" placeholder="{{ t("English") }}">
            </div>
            <div class="field">
                <label>{{ t("Direction") }}</label>
                <select name="direction">
                    <option value="ltr" selected>{{ t("LTR") }}</option>
                    <option value="rtl">{{ t("RTL") }}</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" selected>{{ t("Yes") }}</option>
                    <option value="0">{{ t("No") }}</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Default") }}</label>
                <select name="is_default">
                    <option value="0" selected>{{ t("No") }}</option>
                    <option value="1">{{ t("Yes") }}</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Create Language") }}</button>
            <a class="btn secondary" href="{{ route('admin.languages.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
