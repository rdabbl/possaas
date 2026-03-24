@extends('admin.layout')

@section('content')
    <h1>{{ t("New Device") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.devices.store') }}">
            @csrf
            <div class="field">
                <label>{{ t("Manager") }}</label>
                <select name="manager_id" required>
                    <option value="">{{ t("Select Manager") }}</option>
                    @foreach ($managers as $manager)
                        <option value="{{ $manager->id }}" {{ old('manager_id') == $manager->id ? 'selected' : '' }}>
                            {{ $manager->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Store") }}</label>
                <select name="store_id" required>
                    <option value="">{{ t("Select Store") }}</option>
                    @foreach ($stores as $store)
                        <option value="{{ $store->id }}" {{ old('store_id') == $store->id ? 'selected' : '' }}>
                            {{ $store->name }} ({{ $store->manager?->name }})
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Type") }}</label>
                <select name="type">
                    <option value="pos" selected>{{ t("POS") }}</option>
                    <option value="kiosk">{{ t("Kiosk") }}</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Platform") }}</label>
                <input name="platform" value="{{ old('platform', 'android') }}">
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" selected>{{ t("Yes") }}</option>
                    <option value="0">{{ t("No") }}</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Create Device") }}</button>
            <a class="btn secondary" href="{{ route('admin.devices.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
