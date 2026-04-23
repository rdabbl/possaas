@extends('admin.layout')

@section('content')
    @php
        $defaultExportTables = request()->query('tables', $tables);
        $defaultImportTables = old('selected_tables', $tables);
        $dependencyMap = $dependencies ?? [];
    @endphp

    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Data Export / Import") }}</h1>
            <p class="muted">{{ t("Export and import admin startup data as JSON.") }}</p>
        </div>
    </div>

    <div class="card" style="margin-top: 16px;">
        <h3 style="margin-top: 0;">{{ t("Included Tables") }} ({{ $tableCount }})</h3>
        <p class="muted">{{ t("Managers, clients, currencies, payments, products, categories, taxes, and related admin data.") }}</p>
        <p class="muted">{{ t("Dependencies are auto-selected (example: payments => sales + payment_methods).") }}</p>

        <form method="GET" action="{{ route('admin.data_transfer.export') }}" style="margin-top: 12px;">
            <div class="field">
                <label>
                    <input type="checkbox" data-select-all="export" checked>
                    {{ t("Select all for export") }}
                </label>
            </div>
            <div class="row" data-table-list="export">
                @foreach ($tables as $table)
                    <label class="muted" style="padding: 6px 10px; border: 1px solid var(--border); border-radius: 999px; background: var(--card);">
                        <input
                            type="checkbox"
                            name="tables[]"
                            value="{{ $table }}"
                            data-table="{{ $table }}"
                            {{ in_array($table, $defaultExportTables, true) ? 'checked' : '' }}
                        >
                        {{ $table }}
                    </label>
                @endforeach
            </div>
            <div style="margin-top: 12px;">
                <button class="btn" type="submit">{{ t("Export JSON") }}</button>
            </div>
        </form>
    </div>

    <div class="card" style="margin-top: 16px;">
        <h3 style="margin-top: 0;">{{ t("Import JSON") }}</h3>
        <p class="muted">
            {{ t("Warning: import replaces only selected tables before inserting JSON data.") }}
        </p>

        <form method="POST" action="{{ route('admin.data_transfer.import') }}" enctype="multipart/form-data">
            @csrf
            <div class="field">
                <label>
                    <input type="checkbox" data-select-all="import" checked>
                    {{ t("Select all for import") }}
                </label>
            </div>
            <div class="row" data-table-list="import">
                @foreach ($tables as $table)
                    <label class="muted" style="padding: 6px 10px; border: 1px solid var(--border); border-radius: 999px; background: var(--card);">
                        <input
                            type="checkbox"
                            name="selected_tables[]"
                            value="{{ $table }}"
                            data-table="{{ $table }}"
                            {{ in_array($table, $defaultImportTables, true) ? 'checked' : '' }}
                        >
                        {{ $table }}
                    </label>
                @endforeach
            </div>
            <div class="field">
                <label for="snapshot">{{ t("Snapshot File (.json)") }}</label>
                <input id="snapshot" name="snapshot" type="file" accept=".json,application/json,text/plain" required>
            </div>
            <button class="btn" type="submit">{{ t("Import JSON") }}</button>
        </form>
    </div>

    <script>
        const dependencyMap = @json($dependencyMap);

        const enforceDependencies = (scope, changedInput) => {
            if (!changedInput || !changedInput.checked) {
                return;
            }
            const container = document.querySelector(`[data-table-list="${scope}"]`);
            if (!container) return;

            const allInputs = Array.from(container.querySelectorAll('input[type="checkbox"][data-table]'));
            const byTable = {};
            allInputs.forEach((input) => {
                byTable[input.dataset.table] = input;
            });

            const visit = (table) => {
                const deps = dependencyMap[table] || [];
                deps.forEach((dep) => {
                    const input = byTable[dep];
                    if (!input || input.checked) {
                        return;
                    }
                    input.checked = true;
                    visit(dep);
                });
            };

            visit(changedInput.dataset.table);
        };

        const bindBulkSelect = (scope) => {
            const master = document.querySelector(`[data-select-all="${scope}"]`);
            const container = document.querySelector(`[data-table-list="${scope}"]`);
            if (!master || !container) return;

            const getItems = () => Array.from(container.querySelectorAll('input[type="checkbox"]'));
            const syncMaster = () => {
                const items = getItems();
                master.checked = items.length > 0 && items.every((item) => item.checked);
            };

            master.addEventListener('change', () => {
                getItems().forEach((item) => {
                    item.checked = master.checked;
                });
            });

            getItems().forEach((item) => {
                item.addEventListener('change', () => {
                    enforceDependencies(scope, item);
                    syncMaster();
                });
            });

            syncMaster();
        };

        bindBulkSelect('export');
        bindBulkSelect('import');
    </script>
@endsection
