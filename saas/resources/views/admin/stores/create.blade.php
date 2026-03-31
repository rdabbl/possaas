@extends('admin.layout')

@section('content')
    <h1>{{ t("New Store") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.stores.store') }}" enctype="multipart/form-data">
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
                <label>{{ t("Currency") }}</label>
                <select name="currency_id" required>
                    <option value="">{{ t("Select Currency") }}</option>
                    @foreach ($currencies as $currency)
                        <option value="{{ $currency->id }}" {{ old('currency_id') == $currency->id ? 'selected' : '' }}>
                            {{ $currency->symbol }} • {{ $currency->code }} • {{ $currency->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Code") }}</label>
                <input name="code" value="{{ old('code') }}">
            </div>
            <div class="field">
                <label>{{ t("Phone") }}</label>
                <input name="phone" value="{{ old('phone') }}">
            </div>
            <div class="field">
                <label>{{ t("Email") }}</label>
                <input name="email" type="email" value="{{ old('email') }}">
            </div>
            <div class="field">
                <label>{{ t("Address") }}</label>
                <input name="address" value="{{ old('address') }}">
            </div>
            <div class="field">
                <label>{{ t("Logo") }}</label>
                <input type="file" name="logo" accept="image/*">
            </div>
            <div class="field">
                <label>{{ t("Stock Enabled") }}</label>
                <select name="stock_enabled">
                    <option value="1" selected>{{ t("Yes") }}</option>
                    <option value="0">{{ t("No") }}</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Allow Loyalty Redemption") }}</label>
                <select name="allow_loyalty_redeem">
                    <option value="1" selected>{{ t("Yes") }}</option>
                    <option value="0">{{ t("No") }}</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Active") }}</label>
                <select name="is_active">
                    <option value="1" selected>{{ t("Yes") }}</option>
                    <option value="0">{{ t("No") }}</option>
                </select>
            </div>
            <button class="btn" type="submit">{{ t("Create Store") }}</button>
            <a class="btn secondary" href="{{ route('admin.stores.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
