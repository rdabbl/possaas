@extends('manager.layout')

@section('content')
    <h1>{{ t("New Product") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('manager.products.store') }}" enctype="multipart/form-data">
            @csrf
            <div class="field">
                <label>{{ t("Name") }}</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Category") }}</label>
                <select name="category_id">
                    <option value="">{{ t("No Category") }}</option>
                    @foreach ($categories as $category)
                        <option value="{{ $category->id }}" {{ old('category_id') == $category->id ? 'selected' : '' }}>
                            {{ $category->name }}@if (!$category->manager_id) (Global)@endif
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Tax") }}</label>
                <select name="tax_id">
                    <option value="">{{ t("No Tax") }}</option>
                    @foreach ($taxes as $tax)
                        <option value="{{ $tax->id }}" {{ old('tax_id') == $tax->id ? 'selected' : '' }}>
                            {{ $tax->name }}@if (!$tax->manager_id) (Global)@endif
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("SKU") }}</label>
                <input name="sku" value="{{ old('sku') }}">
            </div>
            <div class="field">
                <label>{{ t("Barcode") }}</label>
                <input name="barcode" value="{{ old('barcode') }}">
            </div>
            <div class="field">
                <label>{{ t("Price") }}</label>
                <input name="price" type="number" step="0.01" min="0" value="{{ old('price', 0) }}">
            </div>
            <div class="field">
                <label>{{ t("Cost") }}</label>
                <input name="cost" type="number" step="0.01" min="0" value="{{ old('cost', 0) }}">
            </div>
            <div class="field">
                <label>{{ t("Description") }}</label>
                <input name="description" value="{{ old('description') }}">
            </div>
            <div class="field">
                <label>{{ t("Ingredients (quantity)") }}</label>
                @if ($ingredients->isEmpty())
                    <p class="muted">{{ t("No ingredients available. Add ingredients first.") }}</p>
                @else
                    <table>
                        <thead>
                            <tr>
                                <th>{{ t("Ingredient") }}</th>
                                <th style="width: 140px;">{{ t("Quantity") }}</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach ($ingredients as $ingredient)
                                <tr>
                                    <td>{{ $ingredient->name }}@if (!$ingredient->manager_id) <span class="muted">{{ t("(Global)") }}</span>@endif</td>
                                    <td>
                                        <div class="qty-control">
                                            <button type="button" class="qty-btn" data-action="minus">-</button>
                                            <input type="number" min="0" step="0.01" name="ingredients[{{ $ingredient->id }}]" value="{{ old('ingredients.' . $ingredient->id, 0) }}" class="qty-input">
                                            <button type="button" class="qty-btn" data-action="plus">{{ t("+") }}</button>
                                        </div>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                @endif
            </div>
            <script>
                document.addEventListener('click', function (event) {
                    const button = event.target.closest('.qty-btn');
                    if (!button) return;
                    const input = button.parentElement.querySelector('.qty-input');
                    if (!input) return;
                    const step = parseFloat(input.getAttribute('step') || '1');
                    const current = parseFloat(input.value || '0');
                    const next = button.dataset.action === 'plus' ? current + step : current - step;
                    input.value = Math.max(0, Math.round(next * 100) / 100);
                    input.dispatchEvent(new Event('input', { bubbles: true }));
                });
            </script>
            <div class="field">
                <label>{{ t("Picture") }}</label>
                <input type="file" name="image" accept="image/*">
            </div>
            <div class="field">
                <label>{{ t("Track Stock") }}</label>
                <select name="track_stock">
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
            <button class="btn" type="submit">{{ t("Create Product") }}</button>
            <a class="btn secondary" href="{{ route('manager.products.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
