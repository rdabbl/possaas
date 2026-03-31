@extends('manager.layout')

@section('content')
    <h1>{{ t("New Shipping Method") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('manager.shipping.store') }}">
            @csrf
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Type") }}</label>
                <select name="type" required>
                    @foreach ($types as $type)
                        <option value="{{ $type }}" {{ old('type') == $type ? 'selected' : '' }}>
                            {{ $type }}
                        </option>
                    @endforeach
                </select>
                <small class="muted">{{ t("free, order_percent, per_item, manual") }}</small>
            </div>
            <div class="field">
                <label>{{ t("Value") }}</label>
                <input name="value" type="number" min="0" step="0.01" value="{{ old('value', 0) }}">
                <small class="muted">{{ t("Used for percent or per item. Leave 0 for free/manual.") }}</small>
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" selected>{{ t("Yes") }}</option>
                    <option value="0">{{ t("No") }}</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Create") }}</button>
            <a class="btn secondary" href="{{ route('manager.shipping.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
