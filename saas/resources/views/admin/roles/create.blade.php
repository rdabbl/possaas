@extends('admin.layout')

@section('content')
    <h1>New Role</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.roles.store') }}">
            @csrf
            <div class="field">
                <label>Tenant (optional)</label>
                <select name="tenant_id">
                    <option value="">Global Role</option>
                    @foreach ($tenants as $tenant)
                        <option value="{{ $tenant->id }}" {{ old('tenant_id') == $tenant->id ? 'selected' : '' }}>
                            {{ $tenant->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>Description</label>
                <input name="description" value="{{ old('description') }}">
            </div>
            <div class="field">
                <label>System Role</label>
                <select name="is_system">
                    <option value="0" selected>No</option>
                    <option value="1">Yes</option>
                </select>
            </div>
            <div class="field">
                <label>Permissions</label>
                <div class="card" style="padding: 12px;">
                    <div class="row">
                        @forelse ($permissions as $permission)
                            <label style="display:flex; align-items:center; gap:6px;">
                                <input type="checkbox" name="permissions[]" value="{{ $permission->id }}">
                                {{ $permission->name }}
                            </label>
                        @empty
                            <span class="muted">No permissions yet.</span>
                        @endforelse
                    </div>
                </div>
            </div>
            <button class="btn" type="submit">Create Role</button>
            <a class="btn secondary" href="{{ route('admin.roles.index') }}">Cancel</a>
        </form>
    </div>
@endsection
