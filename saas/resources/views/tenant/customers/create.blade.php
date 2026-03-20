@extends('tenant.layout')

@section('content')
    <h1>New Customer</h1>

    <div class="card">
        <form method="POST" action="{{ route('tenant.customers.store') }}">
            @csrf
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>Email</label>
                <input name="email" type="email" value="{{ old('email') }}">
            </div>
            <div class="field">
                <label>Phone</label>
                <input name="phone" value="{{ old('phone') }}">
            </div>
            <div class="field">
                <label>Address</label>
                <input name="address" value="{{ old('address') }}">
            </div>
            <div class="field">
                <label>Note</label>
                <input name="note" value="{{ old('note') }}">
            </div>
            <div class="field">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" selected>Yes</option>
                    <option value="0">No</option>
                </select>
            </div>
            <button class="btn" type="submit">Create Customer</button>
            <a class="btn secondary" href="{{ route('tenant.customers.index') }}">Cancel</a>
        </form>
    </div>
@endsection
