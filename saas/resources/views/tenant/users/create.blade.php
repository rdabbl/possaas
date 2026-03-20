@extends('tenant.layout')

@section('content')
    <h1>New User</h1>

    <div class="card">
        <form method="POST" action="{{ route('tenant.users.store') }}">
            @csrf
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>Email</label>
                <input name="email" type="email" value="{{ old('email') }}" required>
            </div>
            <div class="field">
                <label>Password</label>
                <input name="password" type="password" required>
            </div>
            <div class="field">
                <label>Store</label>
                <select name="store_id">
                    <option value="">No Store</option>
                    @foreach ($stores as $store)
                        <option value="{{ $store->id }}" {{ old('store_id') == $store->id ? 'selected' : '' }}>
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
                                <input type="checkbox" name="roles[]" value="{{ $role->id }}">
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
                    <option value="1" selected>Yes</option>
                    <option value="0">No</option>
                </select>
            </div>
            <button class="btn" type="submit">Create User</button>
            <a class="btn secondary" href="{{ route('tenant.users.index') }}">Cancel</a>
        </form>
    </div>
@endsection
