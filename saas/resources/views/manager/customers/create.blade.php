@extends('manager.layout')

@section('content')
    <h1>{{ t("New Customer") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('manager.customers.store') }}">
            @csrf
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Email") }}</label>
                <input name="email" type="email" value="{{ old('email') }}">
            </div>
            <div class="field">
                <label>{{ t("Phone") }}</label>
                <input name="phone" value="{{ old('phone') }}">
            </div>
            <div class="field">
                <label>{{ t("Address") }}</label>
                <input name="address" value="{{ old('address') }}">
            </div>
            <div class="field">
                <label>{{ t("Note") }}</label>
                <input name="note" value="{{ old('note') }}">
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" selected>{{ t("Yes") }}</option>
                    <option value="0">{{ t("No") }}</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Create Customer") }}</button>
            <a class="btn secondary" href="{{ route('manager.customers.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
