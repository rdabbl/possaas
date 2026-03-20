@extends('tenant.layout')

@section('content')
    <h1>Import Products</h1>

    <div class="card">
        <form method="POST" action="{{ route('tenant.products.import') }}" enctype="multipart/form-data">
            @csrf
            <div class="field">
                <label>CSV/TXT File</label>
                <input type="file" name="file" accept=".csv,.txt" required>
                <p class="muted">Required columns: name, price. Optional: sku, barcode, cost, description, category, track_stock, is_active, image_url, tax.</p>
            </div>
            <button class="btn" type="submit">Import</button>
            <a class="btn secondary" href="{{ route('tenant.products.index') }}">Cancel</a>
        </form>
    </div>
@endsection
