@extends('tenant.layout')

@section('content')
    <h1>Stock Management</h1>

    <div class="card" style="margin-bottom: 16px;">
        <h2 style="margin-top: 0;">Store Stock</h2>
        <table>
            <thead>
                <tr>
                    <th>Store</th>
                    <th>Stock Enabled</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($stores as $store)
                    <tr>
                        <td>{{ $store->name }}</td>
                        <td>
                            <form id="store-stock-{{ $store->id }}" method="POST" action="{{ route('tenant.stock.stores.update', $store) }}">
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
        <h2 style="margin-top: 0;">Product Stock</h2>
        <table>
            <thead>
                <tr>
                    <th>Product</th>
                    <th>Track Stock</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($products as $product)
                    <tr>
                        <td>{{ $product->name }}</td>
                        <td>
                            <form id="product-stock-{{ $product->id }}" method="POST" action="{{ route('tenant.stock.products.update', $product) }}">
                                @csrf
                                @method('PUT')
                                <select name="track_stock">
                                    <option value="1" {{ $product->track_stock ? 'selected' : '' }}>Yes</option>
                                    <option value="0" {{ !$product->track_stock ? 'selected' : '' }}>No</option>
                                </select>
                            </form>
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
