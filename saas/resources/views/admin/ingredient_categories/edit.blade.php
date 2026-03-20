@extends('admin.layout')

@section('content')
    <h1>Edit Ingredient Category</h1>
    <p class="muted">Tenant: {{ $ingredientCategory->tenant?->name }}</p>

    <div class="card">
        <form method="POST" action="{{ route('admin.ingredient_categories.update', $ingredientCategory) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name', $ingredientCategory->name) }}" required>
            </div>
            <div class="field">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" {{ old('is_active', $ingredientCategory->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('is_active', $ingredientCategory->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <button class="btn" type="submit">Save</button>
            <a class="btn secondary" href="{{ route('admin.ingredient_categories.index') }}">Cancel</a>
        </form>
    </div>
@endsection
