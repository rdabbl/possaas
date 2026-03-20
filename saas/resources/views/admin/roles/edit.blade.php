@extends('admin.layout')

@section('content')
    <h1>Edit Role</h1>
    <p class="muted">Tenant: {{ $role->tenant?->name ?? 'Global' }}</p>

    <div class="card">
        <form method="POST" action="{{ route('admin.roles.update', $role) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name', $role->name) }}" required>
            </div>
            <div class="field">
                <label>Description</label>
                <input name="description" value="{{ old('description', $role->description) }}">
            </div>
            <div class="field">
                <label>System Role</label>
                <select name="is_system">
                    <option value="0" {{ old('is_system', $role->is_system ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                    <option value="1" {{ old('is_system', $role->is_system ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                </select>
            </div>
            <div class="field">
                <label>Permissions</label>
                <div class="card" style="padding: 12px;">
                    <div class="row">
                        @forelse ($permissions as $permission)
                            <label style="display:flex; align-items:center; gap:6px;">
                                <input type="checkbox" name="permissions[]" value="{{ $permission->id }}"
                                    {{ in_array($permission->id, $selectedPermissions, true) ? 'checked' : '' }}>
                                {{ $permission->name }}
                            </label>
                        @empty
                            <span class="muted">No permissions yet.</span>
                        @endforelse
                    </div>
                </div>
            </div>
            <button class="btn" type="submit">Save</button>
            <a class="btn secondary" href="{{ route('admin.roles.index') }}">Cancel</a>
        </form>
    </div>
@endsection
