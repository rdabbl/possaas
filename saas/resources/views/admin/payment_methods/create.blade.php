@extends('admin.layout')

@section('content')
    <h1>{{ t("New Payment Method") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.payment_methods.store') }}">
            @csrf
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Type") }}</label>
                <select name="type">
                    <option value="cash" selected>{{ t("Cash") }}</option>
                    <option value="card">{{ t("Card") }}</option>
                    <option value="bank">{{ t("Bank") }}</option>
                    <option value="other">{{ t("Other") }}</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Default") }}</label>
                <select name="is_default">
                    <option value="0" selected>{{ t("No") }}</option>
                    <option value="1">{{ t("Yes") }}</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" selected>{{ t("Yes") }}</option>
                    <option value="0">{{ t("No") }}</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Create Method") }}</button>
            <a class="btn secondary" href="{{ route('admin.payment_methods.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
