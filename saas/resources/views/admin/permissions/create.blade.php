@extends('admin.layout')

@section('content')
    <h1>New Permission</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.permissions.store') }}">
            @csrf
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>Description</label>
                <input name="description" value="{{ old('description') }}">
            </div>
            <button class="btn" type="submit">Create Permission</button>
            <a class="btn secondary" href="{{ route('admin.permissions.index') }}">Cancel</a>
        </form>
    </div>
@endsection
