@extends('admin.layout')

@section('content')
    <h1>Edit Tenant</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.tenants.update', $tenant) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name', $tenant->name) }}" required>
            </div>
            <div class="field">
                <label>Slug</label>
                <input name="slug" value="{{ old('slug', $tenant->slug) }}" required>
            </div>
            <div class="field">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" {{ old('is_active', $tenant->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('is_active', $tenant->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <div class="field">
                <label>Currency</label>
                <select name="currency">
                    @foreach ($currencies as $currency)
                        <option value="{{ $currency->code }}" {{ old('currency', $tenant->currency) === $currency->code ? 'selected' : '' }}>
                            {{ $currency->symbol }} • {{ $currency->code }} • {{ $currency->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>Timezone</label>
                <select name="timezone">
                    @foreach ($timezones as $timezone)
                        <option value="{{ $timezone }}" {{ old('timezone', $tenant->timezone) === $timezone ? 'selected' : '' }}>
                            {{ $timezone }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>Plan</label>
                <select name="plan_id">
                    <option value="">Select Plan</option>
                    @foreach ($plans as $plan)
                        <option value="{{ $plan->id }}" {{ (string) old('plan_id', $tenant->plan_id) === (string) $plan->id ? 'selected' : '' }}>
                            {{ $plan->name }} ({{ $plan->duration_days ?? 'No duration' }} days)
                        </option>
                    @endforeach
                </select>
            </div>
            <button class="btn" type="submit">Save</button>
            <a class="btn secondary" href="{{ route('admin.tenants.index') }}">Cancel</a>
        </form>
    </div>
@endsection
