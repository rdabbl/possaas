@extends('admin.layout')

@section('content')
    <h1>New Tenant</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.tenants.store') }}">
            @csrf
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>Slug</label>
                <input name="slug" value="{{ old('slug') }}">
            </div>
            <div class="field">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" selected>Yes</option>
                    <option value="0">No</option>
                </select>
            </div>
            <div class="field">
                <label>Currency</label>
                <select name="currency">
                    @foreach ($currencies as $currency)
                        <option value="{{ $currency->code }}" {{ old('currency', 'USD') === $currency->code ? 'selected' : '' }}>
                            {{ $currency->symbol }} • {{ $currency->code }} • {{ $currency->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>Timezone</label>
                <select name="timezone">
                    @foreach ($timezones as $timezone)
                        <option value="{{ $timezone }}" {{ old('timezone', 'UTC') === $timezone ? 'selected' : '' }}>
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
                        <option value="{{ $plan->id }}" {{ (string) old('plan_id') === (string) $plan->id ? 'selected' : '' }}>
                            {{ $plan->name }} ({{ $plan->duration_days ?? 'No duration' }} days)
                        </option>
                    @endforeach
                </select>
            </div>
            <hr style="border:0;border-top:1px solid #e5e7eb;margin:16px 0;">
            <h3>Tenant Admin User (Optional)</h3>
            <div class="field">
                <label>Admin Name</label>
                <input name="admin_name" value="{{ old('admin_name') }}">
            </div>
            <div class="field">
                <label>Admin Email</label>
                <input name="admin_email" type="email" value="{{ old('admin_email') }}">
            </div>
            <div class="field">
                <label>Admin Password</label>
                <input name="admin_password" type="password">
            </div>
            <button class="btn" type="submit">Create Tenant</button>
            <a class="btn secondary" href="{{ route('admin.tenants.index') }}">Cancel</a>
        </form>
    </div>
@endsection
