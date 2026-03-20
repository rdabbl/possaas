@extends('admin.layout')

@section('content')
    <h1>New Plan</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.plans.store') }}">
            @csrf
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>Duration (days)</label>
                <input name="duration_days" type="number" min="1" value="{{ old('duration_days') }}">
            </div>
            <div class="field">
                <label>Max Stores (empty = unlimited)</label>
                <input name="max_stores" type="number" min="0" value="{{ old('max_stores') }}">
            </div>
            <div class="field">
                <label>Max Devices (empty = unlimited)</label>
                <input name="max_devices" type="number" min="0" value="{{ old('max_devices') }}">
            </div>
            <div class="field">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" selected>Yes</option>
                    <option value="0">No</option>
                </select>
            </div>
            <button class="btn" type="submit">Create Plan</button>
            <a class="btn secondary" href="{{ route('admin.plans.index') }}">Cancel</a>
        </form>
    </div>
@endsection
