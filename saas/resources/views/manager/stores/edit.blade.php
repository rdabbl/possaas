@extends('manager.layout')

@section('content')
    <h1>{{ t("Edit Store") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('manager.stores.update', $store) }}" enctype="multipart/form-data">
            @csrf
            @method('PUT')
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name', $store->name) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Currency") }}</label>
                <select name="currency_id" required>
                    <option value="">{{ t("Select Currency") }}</option>
                    @foreach ($currencies as $currency)
                        <option value="{{ $currency->id }}" {{ old('currency_id', $store->currency_id) == $currency->id ? 'selected' : '' }}>
                            {{ $currency->symbol }} • {{ $currency->code }} • {{ $currency->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Code") }}</label>
                <input name="code" value="{{ old('code', $store->code) }}">
            </div>
            <div class="field">
                <label>{{ t("Phone") }}</label>
                <input name="phone" value="{{ old('phone', $store->phone) }}">
            </div>
            <div class="field">
                <label>{{ t("Email") }}</label>
                <input name="email" type="email" value="{{ old('email', $store->email) }}">
            </div>
            <div class="field">
                <label>{{ t("Address") }}</label>
                <input name="address" value="{{ old('address', $store->address) }}">
            </div>
            <div class="field">
                <label>{{ t("Logo") }}</label>
                @if ($store->logo_path)
                    <div style="margin-bottom: 8px;">
                        <img src="{{ asset('storage/' . $store->logo_path) }}" alt="Store logo" style="max-width: 160px; border-radius: 8px;">
                    </div>
                @endif
                <input type="file" name="logo" accept="image/*">
            </div>
            <div class="field">
                <label>{{ t("Stock Enabled") }}</label>
                <select name="stock_enabled">
                    <option value="1" {{ old('stock_enabled', $store->stock_enabled ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('stock_enabled', $store->stock_enabled ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Allow Loyalty Redemption") }}</label>
                <select name="allow_loyalty_redeem">
                    <option value="1" {{ old('allow_loyalty_redeem', $store->allow_loyalty_redeem ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('allow_loyalty_redeem', $store->allow_loyalty_redeem ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" {{ old('is_active', $store->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('is_active', $store->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Save") }}</button>
            <a class="btn secondary" href="{{ route('manager.stores.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
