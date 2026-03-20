@extends('tenant.layout')

@section('content')
    <h1>Edit Product</h1>

    <div class="card">
        <form method="POST" action="{{ route('tenant.products.update', $product) }}" enctype="multipart/form-data">
            @csrf
            @method('PUT')
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name', $product->name) }}" required>
            </div>
            <div class="field">
                <label>Category</label>
                <select name="category_id">
                    <option value="">No Category</option>
                    @foreach ($categories as $category)
                        <option value="{{ $category->id }}" {{ (string) old('category_id', $product->category_id) === (string) $category->id ? 'selected' : '' }}>
                            {{ $category->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>Tax</label>
                <select name="tax_id">
                    <option value="">No Tax</option>
                    @foreach ($taxes as $tax)
                        <option value="{{ $tax->id }}" {{ (string) old('tax_id', $product->tax_id) === (string) $tax->id ? 'selected' : '' }}>
                            {{ $tax->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>SKU</label>
                <input name="sku" value="{{ old('sku', $product->sku) }}">
            </div>
            <div class="field">
                <label>Barcode</label>
                <input name="barcode" value="{{ old('barcode', $product->barcode) }}">
            </div>
            <div class="field">
                <label>Price</label>
                <input name="price" type="number" step="0.01" min="0" value="{{ old('price', $product->price) }}">
            </div>
            <div class="field">
                <label>Cost</label>
                <input name="cost" type="number" step="0.01" min="0" value="{{ old('cost', $product->cost) }}">
            </div>
            <div class="field">
                <label>Description</label>
                <input name="description" value="{{ old('description', $product->description) }}">
            </div>
            <div class="field">
                <label>Ingredients (quantity)</label>
                @if ($ingredients->isEmpty())
                    <p class="muted">No ingredients available. Add ingredients first.</p>
                @else
                    @php
                        $ingredientQuantities = $product->ingredientLinks->pluck('pivot.quantity', 'id');
                    @endphp
                    <table>
                        <thead>
                            <tr>
                                <th>Ingredient</th>
                                <th style="width: 140px;">Quantity</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach ($ingredients as $ingredient)
                                <tr>
                                    <td>{{ $ingredient->name }}</td>
                                    <td>
                                        <div class="qty-control">
                                            <button type="button" class="qty-btn" data-action="minus">-</button>
                                            <input type="number" min="0" step="0.01" name="ingredients[{{ $ingredient->id }}]" value="{{ old('ingredients.' . $ingredient->id, $ingredientQuantities[$ingredient->id] ?? 0) }}" class="qty-input">
                                            <button type="button" class="qty-btn" data-action="plus">+</button>
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
                <label>Picture</label>
                @if ($product->image_url)
                    <div style="margin-bottom: 8px;">
                        <img src="{{ $product->image_url }}" alt="Product image" style="max-width: 160px; border-radius: 8px;">
                    </div>
                @endif
                <input type="file" name="image" accept="image/*">
            </div>
            <div class="field">
                <label>Track Stock</label>
                <select name="track_stock">
                    <option value="1" {{ old('track_stock', $product->track_stock ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('track_stock', $product->track_stock ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <div class="field">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" {{ old('is_active', $product->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('is_active', $product->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <button class="btn" type="submit">Save</button>
            <a class="btn secondary" href="{{ route('tenant.products.index') }}">Cancel</a>
        </form>
    </div>

    <div class="card" style="margin-top: 16px;">
        <h2 style="margin-top: 0;">Variants</h2>

        <form method="POST" action="{{ route('tenant.products.variants.store', $product) }}" class="row" style="margin-bottom: 16px;">
            @csrf
            <div style="min-width: 180px; flex: 1;">
                <label>Name</label>
                <input name="name" required>
            </div>
            <div style="min-width: 140px; flex: 1;">
                <label>SKU</label>
                <input name="sku">
            </div>
            <div style="min-width: 140px; flex: 1;">
                <label>Barcode</label>
                <input name="barcode">
            </div>
            <div style="min-width: 120px;">
                <label>Price</label>
                <input name="price" type="number" step="0.01" min="0">
            </div>
            <div style="min-width: 120px;">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" selected>Yes</option>
                    <option value="0">No</option>
                </select>
            </div>
            <div style="align-self: end;">
                <button class="btn" type="submit">Add Variant</button>
            </div>
        </form>

        <table>
            <thead>
                <tr>
                    <th>Name</th>
                    <th>SKU</th>
                    <th>Barcode</th>
                    <th>Price</th>
                    <th>Active</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($variants as $variant)
                    <form id="variant-form-{{ $variant->id }}" method="POST" action="{{ route('tenant.products.variants.update', [$product, $variant]) }}">
                        @csrf
                        @method('PUT')
                    </form>
                    <tr>
                        <td>
                            <input form="variant-form-{{ $variant->id }}" name="name" value="{{ $variant->name }}" required style="min-width: 160px;">
                        </td>
                        <td>
                            <input form="variant-form-{{ $variant->id }}" name="sku" value="{{ $variant->sku }}" style="min-width: 120px;">
                        </td>
                        <td>
                            <input form="variant-form-{{ $variant->id }}" name="barcode" value="{{ $variant->barcode }}" style="min-width: 120px;">
                        </td>
                        <td>
                            <input form="variant-form-{{ $variant->id }}" name="price" type="number" step="0.01" min="0" value="{{ $variant->price }}" style="min-width: 100px;">
                        </td>
                        <td>
                            <select form="variant-form-{{ $variant->id }}" name="is_active" style="min-width: 90px;">
                                <option value="1" {{ $variant->is_active ? 'selected' : '' }}>Yes</option>
                                <option value="0" {{ !$variant->is_active ? 'selected' : '' }}>No</option>
                            </select>
                        </td>
                        <td class="row">
                            <button class="btn" type="submit" form="variant-form-{{ $variant->id }}">Save</button>
                            <form method="POST" action="{{ route('tenant.products.variants.destroy', [$product, $variant]) }}">
                                @csrf
                                @method('DELETE')
                                <button class="btn secondary" type="submit">Delete</button>
                            </form>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" class="muted">No variants yet.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
@endsection
