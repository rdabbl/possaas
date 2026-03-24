@extends('manager.layout')

@section('content')
    <h1>{{ t("New Tax") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('manager.taxes.store') }}">
            @csrf
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Rate") }}</label>
                <input name="rate" type="number" step="0.01" min="0" value="{{ old('rate', 0) }}" required>
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
            <button class="btn" type="submit">{{ t("Create Tax") }}</button>
            <a class="btn secondary" href="{{ route('manager.taxes.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
