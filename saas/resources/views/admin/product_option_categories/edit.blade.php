@extends('admin.layout')

@section('content')
    <h1>{{ t("Edit Product Option Category") }}</h1>
    <p class="muted">Scope: {{ $productOptionCategory->manager?->name ?? 'Global' }}</p>

    <div class="card">
        <form method="POST" action="{{ route('admin.product_option_categories.update', $productOptionCategory) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name', $productOptionCategory->name) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" {{ old('is_active', $productOptionCategory->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('is_active', $productOptionCategory->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Save") }}</button>
            <a class="btn secondary" href="{{ route('admin.product_option_categories.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
