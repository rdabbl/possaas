@extends('admin.layout')

@section('content')
    <h1>{{ t("Edit Role") }}</h1>
    <p class="muted">Manager: {{ $role->manager?->name ?? 'Global' }}</p>

    <div class="card">
        <form method="POST" action="{{ route('admin.roles.update', $role) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name', $role->name) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Description") }}</label>
                <input name="description" value="{{ old('description', $role->description) }}">
            </div>
            <div class="field">
                <label>{{ t("System Role") }}</label>
                <select name="is_system">
                    <option value="0" {{ old('is_system', $role->is_system ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                    <option value="1" {{ old('is_system', $role->is_system ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Permissions") }}</label>
                <div class="card" style="padding: 12px;">
                    <div class="row">
                        @forelse ($permissions as $permission)
                            <label style="display:flex; align-items:center; gap:6px;">
                                <input type="checkbox" name="permissions[]" value="{{ $permission->id }}"
                                    {{ in_array($permission->id, $selectedPermissions, true) ? 'checked' : '' }}>
                                {{ $permission->name }}
                            </label>
                        @empty
                            <span class="muted">{{ t("No permissions yet.") }}</span>
                        @endforelse
                    </div>
                </div>
            </div>
            <button class="btn" type="submit">{{ t("Save") }}</button>
            <a class="btn secondary" href="{{ route('admin.roles.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
