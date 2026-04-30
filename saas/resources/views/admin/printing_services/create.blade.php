@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("New printing service") }}</h1>
            <p class="muted">{{ t("Create a backend printer service.") }}</p>
        </div>
        <a class="btn secondary" href="{{ route('admin.printing_services.index') }}">{{ t("Back") }}</a>
    </div>

    <div class="card">
        <form method="POST" action="{{ route('admin.printing_services.store') }}">
            @csrf
            <div class="field">
                <label>{{ t("Manager") }}</label>
                <select name="manager_id" required>
                    <option value="">{{ t("Select manager") }}</option>
                    @foreach ($managers as $manager)
                        <option value="{{ $manager->id }}" {{ old('manager_id') == $manager->id ? 'selected' : '' }}>{{ $manager->name }}</option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Store") }}</label>
                <select name="store_id" required>
                    <option value="">{{ t("Select store") }}</option>
                    @foreach ($stores as $store)
                        <option value="{{ $store->id }}" {{ old('store_id') == $store->id ? 'selected' : '' }}>{{ $store->name }}</option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Service name") }}</label>
                <input type="text" name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Service type") }}</label>
                <input type="text" name="type" value="{{ old('type') }}" placeholder="pos, caisse, cuisine, borne">
            </div>
            <div class="field">
                <label>{{ t("Print template") }}</label>
                <select name="template" required>
                    @foreach ($templates as $key => $label)
                        <option value="{{ $key }}" {{ old('template', 'receipt') === $key ? 'selected' : '' }}>{{ $label }}</option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Order") }}</label>
                <input type="number" name="sort_order" min="0" value="{{ old('sort_order', 0) }}">
            </div>
            <div class="field">
                <label>
                    <input type="checkbox" name="is_active" value="1" {{ old('is_active', true) ? 'checked' : '' }}>
                    {{ t("Active") }}
                </label>
            </div>
            <button class="btn" type="submit">{{ t("Save") }}</button>
        </form>
    </div>
@endsection
