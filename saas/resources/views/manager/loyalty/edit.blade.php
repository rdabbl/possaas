@extends('manager.layout')

@section('content')
    <h1>{{ t("Loyalty Program") }}</h1>
    <p class="muted">{{ t("Configure how customers earn and use loyalty points.") }}</p>

    <div class="card">
        <form method="POST" action="{{ route('manager.loyalty.update') }}">
            @csrf
            @method('PUT')

            <div class="field">
                <label>{{ t("Enable Loyalty") }}</label>
                <select name="loyalty_enabled">
                    <option value="1" {{ old('loyalty_enabled', $manager->loyalty_enabled ? 1 : 0) == 1 ? 'selected' : '' }}>{{ t("Yes") }}</option>
                    <option value="0" {{ old('loyalty_enabled', $manager->loyalty_enabled ? 1 : 0) == 0 ? 'selected' : '' }}>{{ t("No") }}</option>
                </select>
            </div>

            <div class="field">
                <label>{{ t("Points per order") }}</label>
                <input name="loyalty_points_per_order" type="number" min="0" value="{{ old('loyalty_points_per_order', $manager->loyalty_points_per_order ?? 0) }}">
                <small class="muted">{{ t("Added once per sale.") }}</small>
            </div>

            <div class="field">
                <label>{{ t("Points per item") }}</label>
                <input name="loyalty_points_per_item" type="number" min="0" value="{{ old('loyalty_points_per_item', $manager->loyalty_points_per_item ?? 0) }}">
                <small class="muted">{{ t("Applied to each item quantity.") }}</small>
            </div>

            <div class="field">
                <label>{{ t("Amount per point") }}</label>
                <input name="loyalty_amount_per_point" type="number" min="0" step="0.01" value="{{ old('loyalty_amount_per_point', $manager->loyalty_amount_per_point ?? 0) }}">
                <small class="muted">{{ t("Spend this amount to earn 1 point.") }}</small>
            </div>

            <div class="field">
                <label>{{ t("Point value") }}</label>
                <input name="loyalty_point_value" type="number" min="0" step="0.01" value="{{ old('loyalty_point_value', $manager->loyalty_point_value ?? 0) }}">
                <small class="muted">{{ t("1 point equals this amount at checkout.") }}</small>
            </div>

            <button class="btn" type="submit">{{ t("Save") }}</button>
            <a class="btn secondary" href="{{ route('manager.dashboard') }}">{{ t("Back") }}</a>
        </form>
    </div>
@endsection
