@extends('admin.layout')

@section('content')
    <h1>{{ t("New Subscription") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.subscriptions.store') }}">
            @csrf
            <div class="field">
                <label>{{ t("Manager") }}</label>
                <select name="manager_id" required>
                    <option value="">{{ t("Select Manager") }}</option>
                    @foreach ($managers as $manager)
                        <option value="{{ $manager->id }}" {{ (string) old('manager_id') === (string) $manager->id ? 'selected' : '' }}>
                            {{ $manager->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Plan") }}</label>
                <select name="plan_id">
                    <option value="">{{ t("No Plan") }}</option>
                    @foreach ($plans as $plan)
                        <option value="{{ $plan->id }}" {{ (string) old('plan_id') === (string) $plan->id ? 'selected' : '' }}>
                            {{ $plan->name }} ({{ $plan->duration_days ?? 'No duration' }} {{ t("days") }})
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="row">
                <div style="flex: 1; min-width: 220px;">
                    <label>{{ t("Starts At") }}</label>
                    <input type="date" name="starts_at" value="{{ old('starts_at') }}">
                </div>
                <div style="flex: 1; min-width: 220px;">
                    <label>{{ t("Ends At") }}</label>
                    <input type="date" name="ends_at" value="{{ old('ends_at') }}">
                </div>
            </div>
            <div class="row">
                <div style="flex: 1; min-width: 220px;">
                    <label>{{ t("Status") }}</label>
                    <select name="status">
                        <option value="active" {{ old('status', 'active') === 'active' ? 'selected' : '' }}>{{ t("Active") }}</option>
                        <option value="paused" {{ old('status') === 'paused' ? 'selected' : '' }}>{{ t("Paused") }}</option>
                        <option value="canceled" {{ old('status') === 'canceled' ? 'selected' : '' }}>{{ t("Canceled") }}</option>
                        <option value="expired" {{ old('status') === 'expired' ? 'selected' : '' }}>{{ t("Expired") }}</option>
                    </select>
                </div>
                <div style="flex: 1; min-width: 220px;">
                    <label>{{ t("Device Limit") }}</label>
                    <input type="number" name="device_limit" min="0" value="{{ old('device_limit') }}" placeholder="{{ t("Plan limit") }}">
                </div>
            </div>
            <div class="field">
                <label>{{ t("Notes") }}</label>
                <textarea name="notes" rows="3">{{ old('notes') }}</textarea>
            </div>
            <button class="btn" type="submit">{{ t("Create Subscription") }}</button>
            <a class="btn secondary" href="{{ route('admin.subscriptions.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
