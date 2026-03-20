@extends('admin.layout')

@section('content')
    <h1>Edit Permission</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.permissions.update', $permission) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name', $permission->name) }}" required>
            </div>
            <div class="field">
                <label>Description</label>
                <input name="description" value="{{ old('description', $permission->description) }}">
            </div>
            <button class="btn" type="submit">Save</button>
            <a class="btn secondary" href="{{ route('admin.permissions.index') }}">Cancel</a>
        </form>
    </div>
@endsection
