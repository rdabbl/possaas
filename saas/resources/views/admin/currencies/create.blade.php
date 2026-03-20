@extends('admin.layout')

@section('content')
    <h1>New Currency</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.currencies.store') }}">
            @csrf
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>Code (3 letters)</label>
                <input name="code" maxlength="3" value="{{ old('code') }}" required>
            </div>
            <div class="field">
                <label>Symbol</label>
                <input name="symbol" value="{{ old('symbol') }}" required>
            </div>
            <div class="field">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" selected>Yes</option>
                    <option value="0">No</option>
                </select>
            </div>
            <button class="btn" type="submit">Create Currency</button>
            <a class="btn secondary" href="{{ route('admin.currencies.index') }}">Cancel</a>
        </form>
    </div>
@endsection
