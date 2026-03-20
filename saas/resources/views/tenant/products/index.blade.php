@extends('tenant.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>Products</h1>
            <p class="muted">Manage your products.</p>
        </div>
        <div class="row" style="gap: 8px;">
            <a class="btn secondary" href="{{ route('tenant.products.import_form') }}">Import Products</a>
            <a class="btn" href="{{ route('tenant.products.create') }}">New Product</a>
        </div>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Picture</th>
                    <th>Name</th>
                    <th>SKU</th>
                    <th>Price</th>
                    <th>Stock</th>
                    <th>Active</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($products as $product)
                    <tr>
                        <td>{{ $product->id }}</td>
                        <td>
                            @if ($product->image_url)
                                <img src="{{ $product->image_url }}" alt="Product image" style="width: 48px; height: 48px; object-fit: cover; border-radius: 6px;">
                            @else
                                —
                            @endif
                        </td>
                        <td>{{ $product->name }}</td>
                        <td>{{ $product->sku }}</td>
                        <td>{{ number_format((float) $product->price, 2) }}</td>
                        <td>{{ $product->track_stock ? 'Yes' : 'No' }}</td>
                        <td>{{ $product->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('tenant.products.edit', $product) }}">Edit</a>
                            <form method="POST" action="{{ route('tenant.products.destroy', $product) }}" style="display:inline-block" onsubmit="return confirm('Delete this product?');">
                                @csrf
                                @method('DELETE')
                                <button class="btn secondary" type="submit">Delete</button>
                            </form>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $products->links() }}
    </div>

    @if (session('import_errors'))
        <div class="card" style="margin-top: 16px;">
            <h3>Import Warnings</h3>
            <ul>
                @foreach (session('import_errors') as $error)
                    <li>Row {{ $error['row'] ?? '?' }}: {{ $error['message'] ?? 'Unknown error' }}</li>
                @endforeach
            </ul>
        </div>
    @endif
@endsection
