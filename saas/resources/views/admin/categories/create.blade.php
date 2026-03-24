@extends('admin.layout')

@section('content')
    <h1>{{ t("New Category") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.categories.store') }}" enctype="multipart/form-data">
            @csrf
            <div class="field">
                <label>{{ t("Parent Category") }}</label>
                <select name="parent_id">
                    <option value="">{{ t("No Parent") }}</option>
                    @foreach ($categories as $category)
                        <option value="{{ $category->id }}" {{ old('parent_id') == $category->id ? 'selected' : '' }}>
                            {{ $category->name }}
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
            <button class="btn" type="submit">{{ t("Create Category") }}</button>
            <a class="btn secondary" href="{{ route('admin.categories.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
