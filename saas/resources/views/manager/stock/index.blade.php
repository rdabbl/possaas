@extends('manager.layout')

@section('content')
    <h1>{{ t("Stock Management") }}</h1>

    <div class="card" style="margin-bottom: 16px;">
        <h2 style="margin-top: 0;">{{ t("Store Stock") }}</h2>
        <table>
            <thead>
                <tr>
                    <th>{{ t("Store") }}</th>
                    <th>{{ t("Stock Enabled") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($stores as $store)
                    <tr>
                        <td>{{ $store->name }}</td>
                        <td>
                            <form id="store-stock-{{ $store->id }}" method="POST" action="{{ route('manager.stock.stores.update', $store) }}">
                                @csrf
                                @method('PUT')
                                <select name="stock_enabled">
                                    <option value="1" {{ $store->stock_enabled ? 'selected' : '' }}>Yes</option>
                                    <option value="0" {{ !$store->stock_enabled ? 'selected' : '' }}>No</option>
                                </select>
                            </form>
                        </td>
                        <td>
                            <button class="btn" type="submit" form="store-stock-{{ $store->id }}">Save</button>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div class="card">
        <h2 style="margin-top: 0;">{{ t("Product Stock") }}</h2>
        <form method="GET" action="{{ route('manager.stock.index') }}" style="margin-bottom: 12px; display: flex; gap: 8px; align-items: center;">
            <label for="store_id_filter">{{ t("Store") }}</label>
            <select id="store_id_filter" name="store_id">
                @foreach ($stores as $store)
                    <option value="{{ $store->id }}" {{ (int) $selectedStoreId === (int) $store->id ? 'selected' : '' }}>
                        {{ $store->name }}
                    </option>
                @endforeach
            </select>
            <button class="btn" type="submit">{{ t("Apply") }}</button>
        </form>
        <table>
            <thead>
                <tr>
                    <th>{{ t("Product") }}</th>
                    <th>{{ t("Track Stock") }}</th>
                    <th>{{ t("Current Quantity") }}</th>
                    <th>{{ t("Set Quantity") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($products as $product)
                    <tr>
                        <td>{{ $product->name }}</td>
                        <td>
                            <form id="product-stock-{{ $product->id }}" method="POST" action="{{ route('manager.stock.products.update', $product) }}">
                                @csrf
                                @method('PUT')
                                <select name="track_stock">
                                    <option value="1" {{ $product->track_stock ? 'selected' : '' }}>Yes</option>
                                    <option value="0" {{ !$product->track_stock ? 'selected' : '' }}>No</option>
                                </select>
                                <input type="hidden" name="store_id" value="{{ $selectedStoreId > 0 ? $selectedStoreId : '' }}">
                            </form>
                        </td>
                        <td>
                            {{ number_format((float) ($product->stock_quantity ?? 0), 0) }}
                        </td>
                        <td>
                            <input
                                type="number"
                                name="stock_quantity"
                                min="0"
                                step="1"
                                form="product-stock-{{ $product->id }}"
                                value="{{ (int) round((float) ($product->stock_quantity ?? 0)) }}"
                            >
                        </td>
                        <td>
                            <button class="btn" type="submit" form="product-stock-{{ $product->id }}">Save</button>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>
@endsection
