@extends('manager.layout')

@section('content')
    <h1>{{ t("New Ingredient") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('manager.ingredients.store') }}" enctype="multipart/form-data">
            @csrf
            <div class="field">
                <label>{{ t("Category") }}</label>
                <select name="ingredient_category_id">
                    <option value="">{{ t("No Category") }}</option>
                    @foreach ($categories as $category)
                        <option value="{{ $category->id }}" {{ old('ingredient_category_id') == $category->id ? 'selected' : '' }}>
                            {{ $category->name }}@if (!$category->manager_id) (Global)@endif
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Picture") }}</label>
                <input type="file" name="image" accept="image/*">
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" selected>{{ t("Yes") }}</option>
                    <option value="0">{{ t("No") }}</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Create Ingredient") }}</button>
            <a class="btn secondary" href="{{ route('manager.ingredients.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
