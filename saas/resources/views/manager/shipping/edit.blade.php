@extends('manager.layout')

@section('content')
    <h1>{{ t("Edit Shipping Method") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('manager.shipping.update', $shipping) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name', $shipping->name) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Type") }}</label>
                <select name="type" required>
                    @foreach ($types as $type)
                        <option value="{{ $type }}" {{ old('type', $shipping->type) == $type ? 'selected' : '' }}>
                            {{ $type }}
                        </option>
                    @endforeach
                </select>
                <small class="muted">{{ t("free, order_percent, per_item, manual") }}</small>
            </div>
            <div class="field">
                <label>{{ t("Value") }}</label>
                <input name="value" type="number" min="0" step="0.01" value="{{ old('value', $shipping->value) }}">
                <small class="muted">{{ t("Used for percent or per item. Leave 0 for free/manual.") }}</small>
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" {{ old('is_active', $shipping->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>{{ t("Yes") }}</option>
                    <option value="0" {{ old('is_active', $shipping->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>{{ t("No") }}</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Save") }}</button>
            <a class="btn secondary" href="{{ route('manager.shipping.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
