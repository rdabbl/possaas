@extends('tenant.layout')

@section('content')
    <h1>New Store</h1>

    <div class="card">
        <form method="POST" action="{{ route('tenant.stores.store') }}" enctype="multipart/form-data">
            @csrf
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>Currency</label>
                <select name="currency_id" required>
                    <option value="">Select Currency</option>
                    @foreach ($currencies as $currency)
                        <option value="{{ $currency->id }}" {{ old('currency_id') == $currency->id ? 'selected' : '' }}>
                            {{ $currency->symbol }} • {{ $currency->code }} • {{ $currency->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>Code</label>
                <input name="code" value="{{ old('code') }}">
            </div>
            <div class="field">
                <label>Phone</label>
                <input name="phone" value="{{ old('phone') }}">
            </div>
            <div class="field">
                <label>Email</label>
                <input name="email" type="email" value="{{ old('email') }}">
            </div>
            <div class="field">
                <label>Address</label>
                <input name="address" value="{{ old('address') }}">
            </div>
            <div class="field">
                <label>Logo</label>
                <input type="file" name="logo" accept="image/*">
            </div>
            <div class="field">
                <label>Stock Enabled</label>
                <select name="stock_enabled">
                    <option value="1" selected>Yes</option>
                    <option value="0">No</option>
                </select>
            </div>
            <div class="field">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" selected>Yes</option>
                    <option value="0">No</option>
                </select>
            </div>
            <button class="btn" type="submit">Create Store</button>
            <a class="btn secondary" href="{{ route('tenant.stores.index') }}">Cancel</a>
        </form>
    </div>
@endsection
