@extends('admin.layout')

@section('content')
    <h1>{{ t("New Product Option") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.product_options.store') }}" enctype="multipart/form-data">
            @csrf
            <div class="field">
                <label>{{ t("Category") }}</label>
                <select name="product_option_category_id">
                    <option value="">{{ t("No Category") }}</option>
                    @foreach ($categories as $category)
                        <option value="{{ $category->id }}" {{ old('product_option_category_id') == $category->id ? 'selected' : '' }}>
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
                <label>{{ t("Option Type") }}</label>
                <select name="option_type" data-option-type>
                    <option value="boolean" {{ old('option_type', 'boolean') === 'boolean' ? 'selected' : '' }}>{{ t("Booléen") }}</option>
                    <option value="quantity" {{ old('option_type') === 'quantity' ? 'selected' : '' }}>{{ t("Quantity") }}</option>
                </select>
            </div>
            <div class="field" data-option-steps>
                <label>{{ t("Step Action") }}</label>
                <select name="step_action">
                    <option value="add" {{ old('step_action', 'add') === 'add' ? 'selected' : '' }}>{{ t("Add") }}</option>
                    <option value="reduce" {{ old('step_action') === 'reduce' ? 'selected' : '' }}>{{ t("Reduce") }}</option>
                </select>
            </div>
            <div class="field" data-option-steps>
                <label>{{ t("Step Value") }}</label>
                <input type="number" name="step_value" min="1" value="{{ old('step_value', 1) }}">
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
            <button class="btn" type="submit">{{ t("Create Option") }}</button>
            <a class="btn secondary" href="{{ route('admin.product_options.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
