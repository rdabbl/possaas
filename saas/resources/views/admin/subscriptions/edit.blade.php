@extends('admin.layout')

@section('content')
    <h1>{{ t("Edit Subscription") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.subscriptions.update', $subscription) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>{{ t("Manager") }}</label>
                <select name="manager_id" required>
                    @foreach ($managers as $manager)
                        <option value="{{ $manager->id }}" {{ (string) old('manager_id', $subscription->manager_id) === (string) $manager->id ? 'selected' : '' }}>
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
                        <option value="{{ $plan->id }}" {{ (string) old('plan_id', $subscription->plan_id) === (string) $plan->id ? 'selected' : '' }}>
                            {{ $plan->name }} ({{ $plan->duration_days ?? 'No duration' }} {{ t("days") }})
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="row">
                <div style="flex: 1; min-width: 220px;">
                    <label>{{ t("Starts At") }}</label>
                    <input type="date" name="starts_at" value="{{ old('starts_at', optional($subscription->starts_at)->format('Y-m-d')) }}">
                </div>
                <div style="flex: 1; min-width: 220px;">
                    <label>{{ t("Ends At") }}</label>
                    <input type="date" name="ends_at" value="{{ old('ends_at', optional($subscription->ends_at)->format('Y-m-d')) }}">
                </div>
            </div>
            <div class="row">
                <div style="flex: 1; min-width: 220px;">
                    <label>{{ t("Status") }}</label>
                    <select name="status">
                        <option value="active" {{ old('status', $subscription->status) === 'active' ? 'selected' : '' }}>{{ t("Active") }}</option>
                        <option value="paused" {{ old('status', $subscription->status) === 'paused' ? 'selected' : '' }}>{{ t("Paused") }}</option>
                        <option value="canceled" {{ old('status', $subscription->status) === 'canceled' ? 'selected' : '' }}>{{ t("Canceled") }}</option>
                        <option value="expired" {{ old('status', $subscription->status) === 'expired' ? 'selected' : '' }}>{{ t("Expired") }}</option>
                    </select>
                </div>
                <div style="flex: 1; min-width: 220px;">
                    <label>{{ t("Device Limit") }}</label>
                    <input type="number" name="device_limit" min="0" value="{{ old('device_limit', $subscription->device_limit) }}" placeholder="{{ t("Plan limit") }}">
                </div>
            </div>
            <div class="field">
                <label>{{ t("Notes") }}</label>
                <textarea name="notes" rows="3">{{ old('notes', $subscription->notes) }}</textarea>
            </div>
            <button class="btn" type="submit">{{ t("Save") }}</button>
            <a class="btn secondary" href="{{ route('admin.subscriptions.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
