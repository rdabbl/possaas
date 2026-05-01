@extends('admin.layout')

@section('content')
    <h1>{{ t("New User") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.users.store') }}">
            @csrf
            <div class="field">
                <label>{{ t("Account Type") }}</label>
                <select name="account_type" required>
                    <option value="manager" {{ old('account_type', 'manager') === 'manager' ? 'selected' : '' }}>{{ t("Manager") }}</option>
                    <option value="admin" {{ old('account_type') === 'admin' ? 'selected' : '' }}>{{ t("Admin") }}</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Manager") }}</label>
                <select name="manager_id">
                    <option value="">{{ t("None") }}</option>
                    @foreach ($managers as $manager)
                        <option value="{{ $manager->id }}" {{ old('manager_id') == $manager->id ? 'selected' : '' }}>
                            {{ $manager->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Store") }}</label>
                <select name="store_id">
                    <option value="">{{ t("None") }}</option>
                    @foreach ($stores as $store)
                        <option value="{{ $store->id }}" {{ old('store_id') == $store->id ? 'selected' : '' }}>
                            {{ $store->name }} @if ($store->manager) ({{ $store->manager->name }}) @endif
                        </option>
                    @endforeach
                </select>
            </div>
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
                <input name="pin" inputmode="numeric" pattern="[0-9]{4}" maxlength="4" value="{{ old('pin') }}">
            </div>
            <div class="field">
                <label>{{ t("Roles") }}</label>
                <div class="card" style="padding: 12px;">
                    <div class="row">
                        @forelse ($roles as $role)
                            <label style="display:flex; align-items:center; gap:6px;">
                                <input type="checkbox" name="roles[]" value="{{ $role->id }}"
                                    {{ in_array($role->id, old('roles', []), false) ? 'checked' : '' }}>
                                {{ $role->name }}
                                <span class="muted">{{ $role->manager?->name ?? t("Global") }}</span>
                            </label>
                        @empty
                            <span class="muted">{{ t("No roles yet.") }}</span>
                        @endforelse
                    </div>
                </div>
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" selected>{{ t("Yes") }}</option>
                    <option value="0">{{ t("No") }}</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Allow Loyalty Redemption") }}</label>
                <select name="allow_loyalty_redeem">
                    <option value="" selected>{{ t("Inherit store setting") }}</option>
                    <option value="1">{{ t("Yes") }}</option>
                    <option value="0">{{ t("No") }}</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Create User") }}</button>
            <a class="btn secondary" href="{{ route('admin.users.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
