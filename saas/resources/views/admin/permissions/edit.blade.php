@extends('admin.layout')

@section('content')
    <h1>{{ t("Edit Permission") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.permissions.update', $permission) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name', $permission->name) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Description") }}</label>
                <input name="description" value="{{ old('description', $permission->description) }}">
            </div>
            <button class="btn" type="submit">{{ t("Save") }}</button>
            <a class="btn secondary" href="{{ route('admin.permissions.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
