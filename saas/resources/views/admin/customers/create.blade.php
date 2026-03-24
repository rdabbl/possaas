@extends('admin.layout')

@section('content')
    <h1>{{ t("New Customer") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.customers.store') }}">
            @csrf
            <div class="field">
                <label>{{ t("Manager") }}</label>
                <select name="manager_id" required>
                    <option value="">{{ t("Select Manager") }}</option>
                    @foreach ($managers as $manager)
                        <option value="{{ $manager->id }}" {{ old('manager_id') == $manager->id ? 'selected' : '' }}>
                            {{ $manager->name }}
                        </option>
                    @endforeach
                </select>
            </div>
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
            <a class="btn secondary" href="{{ route('admin.customers.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
