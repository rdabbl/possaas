@extends('manager.layout')

@section('content')
    <h1>{{ t("New Ingredient Category") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('manager.ingredient_categories.store') }}">
            @csrf
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" selected>{{ t("Yes") }}</option>
                    <option value="0">{{ t("No") }}</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Create Ingredient Category") }}</button>
            <a class="btn secondary" href="{{ route('manager.ingredient_categories.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
