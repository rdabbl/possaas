@extends('manager.layout')

@section('content')
    <h1>{{ t("New Discount") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('manager.discounts.store') }}">
            @csrf
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Value") }}</label>
                <input name="value" type="number" step="0.01" min="0" value="{{ old('value', 0) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Type") }}</label>
                <select name="type">
                    <option value="percent" selected>{{ t("Percent") }}</option>
                    <option value="fixed">{{ t("Fixed") }}</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" selected>{{ t("Yes") }}</option>
                    <option value="0">{{ t("No") }}</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Create Discount") }}</button>
            <a class="btn secondary" href="{{ route('manager.discounts.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
