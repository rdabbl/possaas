@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Data Export / Import") }}</h1>
            <p class="muted">{{ t("Simple full export/import for admin data in JSON.") }}</p>
        </div>
        <a class="btn" href="{{ route('admin.data_transfer.export') }}">{{ t("Export JSON") }}</a>
    </div>

    <div class="card" style="margin-top: 16px;">
        <h3 style="margin-top: 0;">{{ t("Included Tables") }} ({{ $tableCount }})</h3>
        <p class="muted">{{ t("Managers, clients, currencies, payments, products, categories, taxes, and related admin data.") }}</p>
        <div class="row">
            @foreach ($tables as $table)
                <span class="muted" style="padding: 6px 10px; border: 1px solid var(--border); border-radius: 999px; background: var(--card);">
                    {{ $table }}
                </span>
            @endforeach
        </div>
    </div>

    <div class="card" style="margin-top: 16px;">
        <h3 style="margin-top: 0;">{{ t("Import JSON") }}</h3>
        <p class="muted">
            {{ t("Warning: import replaces all included tables before inserting JSON data.") }}
        </p>

        <form method="POST" action="{{ route('admin.data_transfer.import') }}" enctype="multipart/form-data">
            @csrf
            <div class="field">
                <label for="snapshot">{{ t("Snapshot File (.json)") }}</label>
                <input id="snapshot" name="snapshot" type="file" accept=".json,application/json,text/plain" required>
            </div>
            <button class="btn" type="submit">{{ t("Import JSON") }}</button>
        </form>
    </div>
@endsection
