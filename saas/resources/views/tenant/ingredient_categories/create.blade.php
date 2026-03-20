@extends('tenant.layout')

@section('content')
    <h1>New Ingredient Category</h1>

    <div class="card">
        <form method="POST" action="{{ route('tenant.ingredient_categories.store') }}">
            @csrf
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" selected>Yes</option>
                    <option value="0">No</option>
                </select>
            </div>
            <button class="btn" type="submit">Create Ingredient Category</button>
            <a class="btn secondary" href="{{ route('tenant.ingredient_categories.index') }}">Cancel</a>
        </form>
    </div>
@endsection
