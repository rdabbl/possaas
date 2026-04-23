@extends('manager.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Catalog Export / Import") }}</h1>
            <p class="muted">{{ t("Export or import only manager catalog data.") }}</p>
        </div>
        <a class="btn" href="{{ route('manager.catalog_transfer.export') }}">{{ t("Export JSON") }}</a>
    </div>

    <div class="card" style="margin-top: 16px;">
        <h3 style="margin-top: 0;">{{ t("Included Elements") }}</h3>
        <p class="muted">{{ t("Products, product variants, categories, product options, and product option categories.") }}</p>
        <div class="row">
            <span class="muted" style="padding: 6px 10px; border: 1px solid var(--border); border-radius: 999px;">product_option_categories</span>
            <span class="muted" style="padding: 6px 10px; border: 1px solid var(--border); border-radius: 999px;">categories</span>
            <span class="muted" style="padding: 6px 10px; border: 1px solid var(--border); border-radius: 999px;">product_options</span>
            <span class="muted" style="padding: 6px 10px; border: 1px solid var(--border); border-radius: 999px;">products</span>
            <span class="muted" style="padding: 6px 10px; border: 1px solid var(--border); border-radius: 999px;">product_variants</span>
            <span class="muted" style="padding: 6px 10px; border: 1px solid var(--border); border-radius: 999px;">product_option_product</span>
        </div>
    </div>

    <div class="card" style="margin-top: 16px;">
        <h3 style="margin-top: 0;">{{ t("Import JSON") }}</h3>
        <p class="muted">{{ t("Warning: this replaces your current manager catalog data.") }}</p>

        <form method="POST" action="{{ route('manager.catalog_transfer.import') }}" enctype="multipart/form-data">
            @csrf
            <div class="field">
                <label for="snapshot">{{ t("Snapshot File (.json)") }}</label>
                <input id="snapshot" name="snapshot" type="file" accept=".json,application/json,text/plain" required>
            </div>
            <button class="btn" type="submit">{{ t("Import JSON") }}</button>
        </form>
    </div>
@endsection
