@extends('admin.layout')

@section('content')
    <h1>{{ t("Import Products") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.products.import') }}" enctype="multipart/form-data">
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
                <label>{{ t("CSV/TXT File") }}</label>
                <input type="file" name="file" accept=".csv,.txt" required>
                <p class="muted">{{ t("Required columns: name, price. Optional: sku, barcode, cost, description, category, track_stock, is_active, image_url, tax.") }}</p>
            </div>
            <button class="btn" type="submit">{{ t("Import") }}</button>
            <a class="btn secondary" href="{{ route('admin.products.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
