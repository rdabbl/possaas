@extends('manager.layout')

@section('content')
    <h1>{{ t("New User") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('manager.users.store') }}">
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
                <label>{{ t("Store") }}</label>
                <select name="store_id" required>
                    @foreach ($stores as $store)
                        <option value="{{ $store->id }}" {{ old('store_id') == $store->id ? 'selected' : '' }}>
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
                                <input type="checkbox" name="roles[]" value="{{ $role->id }}">
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
            <a class="btn secondary" href="{{ route('manager.users.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
