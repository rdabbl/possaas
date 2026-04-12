@extends('manager.layout')

@section('content')
    <h1>{{ t("Edit User") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('manager.users.update', $user) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name', $user->name) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Username") }}</label>
                <input name="username" value="{{ old('username', $user->username) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Email") }}</label>
                <input name="email" type="email" value="{{ old('email', $user->email) }}" required>
            </div>
            <div class="field">
                <label>{{ t("New Password (optional)") }}</label>
                <input name="password" type="password">
            </div>
            <div class="field">
                <label>{{ t("Store") }}</label>
                <select name="store_id" required>
                    @foreach ($stores as $store)
                        <option value="{{ $store->id }}" {{ old('store_id', $user->store_id) == $store->id ? 'selected' : '' }}>
                            {{ $store->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Roles") }}</label>
                <div class="card" style="padding: 12px;">
                    <div class="row">
                        @forelse ($roles as $role)
                            <label style="display:flex; align-items:center; gap:6px;">
                                <input type="checkbox" name="roles[]" value="{{ $role->id }}"
                                    {{ in_array($role->id, $selectedRoles, true) ? 'checked' : '' }}>
                                {{ $role->name }}
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
                    <option value="1" {{ old('is_active', $user->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>{{ t("Yes") }}</option>
                    <option value="0" {{ old('is_active', $user->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>{{ t("No") }}</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Allow Loyalty Redemption") }}</label>
                <select name="allow_loyalty_redeem">
                    @php
                        $allowLoyalty = old('allow_loyalty_redeem', $user->allow_loyalty_redeem);
                    @endphp
                    <option value="" {{ $allowLoyalty === null || $allowLoyalty === '' ? 'selected' : '' }}>{{ t("Inherit store setting") }}</option>
                    <option value="1" {{ (string) $allowLoyalty === '1' ? 'selected' : '' }}>{{ t("Yes") }}</option>
                    <option value="0" {{ (string) $allowLoyalty === '0' ? 'selected' : '' }}>{{ t("No") }}</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Save") }}</button>
            <a class="btn secondary" href="{{ route('manager.users.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
