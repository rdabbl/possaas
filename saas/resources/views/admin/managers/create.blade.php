@extends('admin.layout')

@section('content')
    <h1>{{ t("New Manager") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.managers.store') }}">
            @csrf
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Username") }}</label>
                <input name="username" value="{{ old('username') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Email") }}</label>
                <input name="email" type="email" value="{{ old('email') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Password") }}</label>
                <input name="password" type="password" required>
            </div>
            <div class="field">
                <label>{{ t("POS PIN (4 digits)") }}</label>
                <input name="pin" inputmode="numeric" pattern="[0-9]{4}" maxlength="4" value="{{ old('pin') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" selected>{{ t("Yes") }}</option>
                    <option value="0">{{ t("No") }}</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Currency") }}</label>
                <select name="currency">
                    @foreach ($currencies as $currency)
                        <option value="{{ $currency->code }}" {{ old('currency', 'USD') === $currency->code ? 'selected' : '' }}>
                            {{ $currency->symbol }} • {{ $currency->code }} • {{ $currency->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Timezone") }}</label>
                <select name="timezone">
                    @foreach ($timezones as $timezone)
                        <option value="{{ $timezone }}" {{ old('timezone', 'UTC') === $timezone ? 'selected' : '' }}>
                            {{ $timezone }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Plan") }}</label>
                <select name="plan_id">
                    <option value="">{{ t("Select Plan") }}</option>
                    @foreach ($plans as $plan)
                        <option value="{{ $plan->id }}" {{ (string) old('plan_id') === (string) $plan->id ? 'selected' : '' }}>
                            {{ $plan->name }} ({{ $plan->duration_days ?? 'No duration' }} days)
                        </option>
                    @endforeach
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Create Manager") }}</button>
            <a class="btn secondary" href="{{ route('admin.managers.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
