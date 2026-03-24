@extends('manager.layout')

@section('content')
    <h1>{{ t("Edit Ingredient Category") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('manager.ingredient_categories.update', $ingredientCategory) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name', $ingredientCategory->name) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" {{ old('is_active', $ingredientCategory->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('is_active', $ingredientCategory->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Save") }}</button>
            <a class="btn secondary" href="{{ route('manager.ingredient_categories.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
