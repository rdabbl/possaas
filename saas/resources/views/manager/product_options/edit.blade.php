@extends('manager.layout')

@section('content')
    <h1>{{ t("Edit Product Option") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('manager.product_options.update', $productOption) }}" enctype="multipart/form-data">
            @csrf
            @method('PUT')
            <div class="field">
                <label>{{ t("Category") }}</label>
                <select name="product_option_category_id">
                    <option value="">{{ t("No Category") }}</option>
                    @foreach ($categories as $category)
                        <option value="{{ $category->id }}" {{ (string) old('product_option_category_id', $productOption->product_option_category_id) === (string) $category->id ? 'selected' : '' }}>
                            {{ $category->name }}@if (!$category->manager_id) (Global)@endif
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name', $productOption->name) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Picture") }}</label>
                @if ($productOption->image_path)
                    <div style="margin-bottom: 8px;">
                        <img src="{{ asset('storage/' . $productOption->image_path) }}" alt="Option image" style="max-width: 160px; border-radius: 8px;">
                    </div>
                @endif
                <input type="file" name="image" accept="image/*">
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" {{ old('is_active', $productOption->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('is_active', $productOption->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Save") }}</button>
            <a class="btn secondary" href="{{ route('manager.product_options.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
