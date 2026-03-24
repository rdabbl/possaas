@extends('manager.layout')

@section('content')
    <h1>{{ t("Edit Category") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('manager.categories.update', $category) }}" enctype="multipart/form-data">
            @csrf
            @method('PUT')
            <div class="field">
                <label>{{ t("Parent Category") }}</label>
                <select name="parent_id">
                    <option value="">{{ t("No Parent") }}</option>
                    @foreach ($categories as $parent)
                        <option value="{{ $parent->id }}" {{ (string) old('parent_id', $category->parent_id) === (string) $parent->id ? 'selected' : '' }}>
                            {{ $parent->name }}@if (!$parent->manager_id) (Global)@endif
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name', $category->name) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Picture") }}</label>
                @if ($category->image_path)
                    <div style="margin-bottom: 8px;">
                        <img src="{{ asset('storage/' . $category->image_path) }}" alt="Category image" style="max-width: 160px; border-radius: 8px;">
                    </div>
                @endif
                <input type="file" name="image" accept="image/*">
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" {{ old('is_active', $category->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('is_active', $category->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Save") }}</button>
            <a class="btn secondary" href="{{ route('manager.categories.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
