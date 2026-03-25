@extends('admin.layout')

@section('content')
    <h1>{{ t("New Product Option Category") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.product_option_categories.store') }}">
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
            <button class="btn" type="submit">{{ t("Create Product Option Category") }}</button>
            <a class="btn secondary" href="{{ route('admin.product_option_categories.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
