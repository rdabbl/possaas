@extends('admin.layout')

@section('content')
    <h1>{{ t("New Permission") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.permissions.store') }}">
            @csrf
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Description") }}</label>
                <input name="description" value="{{ old('description') }}">
            </div>
            <button class="btn" type="submit">{{ t("Create Permission") }}</button>
            <a class="btn secondary" href="{{ route('admin.permissions.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
