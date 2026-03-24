@extends('admin.layout')

@section('content')
    <h1>{{ t("New Role") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.roles.store') }}">
            @csrf
            <div class="field">
                <label>{{ t("Manager (optional)") }}</label>
                <select name="manager_id">
                    <option value="">{{ t("Global Role") }}</option>
                    @foreach ($managers as $manager)
                        <option value="{{ $manager->id }}" {{ old('manager_id') == $manager->id ? 'selected' : '' }}>
                            {{ $manager->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Description") }}</label>
                <input name="description" value="{{ old('description') }}">
            </div>
            <div class="field">
                <label>{{ t("System Role") }}</label>
                <select name="is_system">
                    <option value="0" selected>{{ t("No") }}</option>
                    <option value="1">{{ t("Yes") }}</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Permissions") }}</label>
                <div class="card" style="padding: 12px;">
                    <div class="row">
                        @forelse ($permissions as $permission)
                            <label style="display:flex; align-items:center; gap:6px;">
                                <input type="checkbox" name="permissions[]" value="{{ $permission->id }}">
                                {{ $permission->name }}
                            </label>
                        @empty
                            <span class="muted">{{ t("No permissions yet.") }}</span>
                        @endforelse
                    </div>
                </div>
            </div>
            <button class="btn" type="submit">{{ t("Create Role") }}</button>
            <a class="btn secondary" href="{{ route('admin.roles.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
