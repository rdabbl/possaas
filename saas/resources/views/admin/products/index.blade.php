@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Products") }}</h1>
            <p class="muted">{{ t("Manage products and prices.") }}</p>
        </div>
        <div class="row" style="gap: 8px;">
            <a class="btn secondary" href="{{ route('admin.products.import_form') }}">{{ t("Import Products") }}</a>
            <a class="btn" href="{{ route('admin.products.create') }}">{{ t("New Product") }}</a>
        </div>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.products.index') }}" class="row">
            <div style="min-width: 220px;">
                <label>{{ t("Filter by Manager") }}</label>
                <select name="manager_id">
                    <option value="">{{ t("All Managers") }}</option>
                    @foreach ($managers as $manager)
                        <option value="{{ $manager->id }}" {{ (string) $managerId === (string) $manager->id ? 'selected' : '' }}>
                            {{ $manager->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div style="align-self: end;">
                <button class="btn" type="submit">{{ t("Filter") }}</button>
            </div>
        </form>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>{{ t("ID") }}</th>
                    <th>{{ t("Manager") }}</th>
                    <th>{{ t("Picture") }}</th>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("SKU") }}</th>
                    <th>{{ t("Price") }}</th>
                    <th>{{ t("Stock") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($products as $product)
                    <tr>
                        <td>{{ $product->id }}</td>
                        <td>{{ $product->manager?->name }}</td>
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
                            <a class="btn secondary" href="{{ route('admin.products.edit', $product) }}">{{ t("Edit") }}</a>
                            <form method="POST" action="{{ route('admin.products.destroy', $product) }}" style="display:inline-block" onsubmit="return confirm('Delete this product?');">
                                @csrf
                                @method('DELETE')
                                <button class="btn secondary" type="submit">{{ t("Delete") }}</button>
                            </form>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    @if (session('import_errors'))
        <div class="card" style="margin-top: 16px;">
            <h3>{{ t("Import Warnings") }}</h3>
            <ul>
                @foreach (session('import_errors') as $error)
                    <li>Row {{ $error['row'] ?? '?' }}: {{ $error['message'] ?? 'Unknown error' }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <div style="margin-top: 12px;">
        {{ $products->links() }}
    </div>
@endsection
