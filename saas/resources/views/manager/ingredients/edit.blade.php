@extends('manager.layout')

@section('content')
    <h1>{{ t("Edit Ingredient") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('manager.ingredients.update', $ingredient) }}" enctype="multipart/form-data">
            @csrf
            @method('PUT')
            <div class="field">
                <label>{{ t("Category") }}</label>
                <select name="ingredient_category_id">
                    <option value="">{{ t("No Category") }}</option>
                    @foreach ($categories as $category)
                        <option value="{{ $category->id }}" {{ (string) old('ingredient_category_id', $ingredient->ingredient_category_id) === (string) $category->id ? 'selected' : '' }}>
                            {{ $category->name }}@if (!$category->manager_id) (Global)@endif
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name', $ingredient->name) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Picture") }}</label>
                @if ($ingredient->image_path)
                    <div style="margin-bottom: 8px;">
                        <img src="{{ asset('storage/' . $ingredient->image_path) }}" alt="Ingredient image" style="max-width: 160px; border-radius: 8px;">
                    </div>
                @endif
                <input type="file" name="image" accept="image/*">
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" {{ old('is_active', $ingredient->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('is_active', $ingredient->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Save") }}</button>
            <a class="btn secondary" href="{{ route('manager.ingredients.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
