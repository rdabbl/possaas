@extends('tenant.layout')

@section('content')
    <h1>Edit User</h1>

    <div class="card">
        <form method="POST" action="{{ route('tenant.users.update', $user) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name', $user->name) }}" required>
            </div>
            <div class="field">
                <label>Email</label>
                <input name="email" type="email" value="{{ old('email', $user->email) }}" required>
            </div>
            <div class="field">
                <label>New Password (optional)</label>
                <input name="password" type="password">
            </div>
            <div class="field">
                <label>Store</label>
                <select name="store_id">
                    <option value="">No Store</option>
                    @foreach ($stores as $store)
                        <option value="{{ $store->id }}" {{ (string) old('store_id', $user->store_id) === (string) $store->id ? 'selected' : '' }}>
                            {{ $store->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>Roles</label>
                <div class="card" style="padding: 12px;">
                    <div class="row">
                        @forelse ($roles as $role)
                            <label style="display:flex; align-items:center; gap:6px;">
                                <input type="checkbox" name="roles[]" value="{{ $role->id }}"
                                    {{ in_array($role->id, $selectedRoles, true) ? 'checked' : '' }}>
                                {{ $role->name }}
                            </label>
                        @empty
                            <span class="muted">No roles yet.</span>
                        @endforelse
                    </div>
                </div>
            </div>
            <div class="field">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" {{ old('is_active', $user->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('is_active', $user->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <button class="btn" type="submit">Save</button>
            <a class="btn secondary" href="{{ route('tenant.users.index') }}">Cancel</a>
        </form>
    </div>
@endsection
