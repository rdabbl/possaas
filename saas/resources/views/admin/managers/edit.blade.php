@extends('admin.layout')

@section('content')
    <h1>{{ t("Edit Manager") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.managers.update', $manager) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name', $manager->name) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Username") }}</label>
                <input name="username" value="{{ old('username', $manager->username) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" {{ old('is_active', $manager->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('is_active', $manager->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Currency") }}</label>
                <select name="currency">
                    @foreach ($currencies as $currency)
                        <option value="{{ $currency->code }}" {{ old('currency', $manager->currency) === $currency->code ? 'selected' : '' }}>
                            {{ $currency->symbol }} • {{ $currency->code }} • {{ $currency->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Timezone") }}</label>
                <select name="timezone">
                    @foreach ($timezones as $timezone)
                        <option value="{{ $timezone }}" {{ old('timezone', $manager->timezone) === $timezone ? 'selected' : '' }}>
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
                        <option value="{{ $plan->id }}" {{ (string) old('plan_id', $manager->plan_id) === (string) $plan->id ? 'selected' : '' }}>
                            {{ $plan->name }} ({{ $plan->duration_days ?? 'No duration' }} days)
                        </option>
                    @endforeach
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Save") }}</button>
            <a class="btn secondary" href="{{ route('admin.managers.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
