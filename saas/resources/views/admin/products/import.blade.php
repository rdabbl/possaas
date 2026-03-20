@extends('admin.layout')

@section('content')
    <h1>Import Products</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.products.import') }}" enctype="multipart/form-data">
            @csrf
            <div class="field">
                <label>Tenant</label>
                <select name="tenant_id" required>
                    <option value="">Select Tenant</option>
                    @foreach ($tenants as $tenant)
                        <option value="{{ $tenant->id }}" {{ old('tenant_id') == $tenant->id ? 'selected' : '' }}>
                            {{ $tenant->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>CSV/TXT File</label>
                <input type="file" name="file" accept=".csv,.txt" required>
                <p class="muted">Required columns: name, price. Optional: sku, barcode, cost, description, category, track_stock, is_active, image_url, tax.</p>
            </div>
            <button class="btn" type="submit">Import</button>
            <a class="btn secondary" href="{{ route('admin.products.index') }}">Cancel</a>
        </form>
    </div>
@endsection
