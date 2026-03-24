@extends('admin.layout')

@section('content')
    <h1>{{ t("New Plan") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.plans.store') }}">
            @csrf
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Duration (days)") }}</label>
                <input name="duration_days" type="number" min="1" value="{{ old('duration_days') }}">
            </div>
            <div class="field">
                <label>{{ t("Max Stores (empty = unlimited)") }}</label>
                <input name="max_stores" type="number" min="0" value="{{ old('max_stores') }}">
            </div>
            <div class="field">
                <label>{{ t("Max Devices (empty = unlimited)") }}</label>
                <input name="max_devices" type="number" min="0" value="{{ old('max_devices') }}">
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" selected>{{ t("Yes") }}</option>
                    <option value="0">{{ t("No") }}</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Create Plan") }}</button>
            <a class="btn secondary" href="{{ route('admin.plans.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
