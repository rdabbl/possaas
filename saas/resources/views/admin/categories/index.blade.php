@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>Categories</h1>
            <p class="muted">Manage product categories.</p>
        </div>
        <a class="btn" href="{{ route('admin.categories.create') }}">New Category</a>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.categories.index') }}" class="row">
            <div style="min-width: 220px;">
                <label>Filter by Tenant</label>
                <select name="tenant_id">
                    <option value="">All Tenants</option>
                    @foreach ($tenants as $tenant)
                        <option value="{{ $tenant->id }}" {{ (string) $tenantId === (string) $tenant->id ? 'selected' : '' }}>
                            {{ $tenant->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div style="align-self: end;">
                <button class="btn" type="submit">Filter</button>
            </div>
        </form>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Tenant</th>
                    <th>Picture</th>
                    <th>Name</th>
                    <th>Parent</th>
                    <th>Active</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($categories as $category)
                    <tr>
                        <td>{{ $category->id }}</td>
                        <td>{{ $category->tenant?->name }}</td>
                        <td>
                            @if ($category->image_path)
                                <img src="{{ asset('storage/' . $category->image_path) }}" alt="Category image" style="width: 48px; height: 48px; object-fit: cover; border-radius: 6px;">
                            @else
                                —
                            @endif
                        </td>
                        <td>{{ $category->name }}</td>
                        <td>{{ $category->parent?->name }}</td>
                        <td>{{ $category->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.categories.edit', $category) }}">Edit</a>
                            <form method="POST" action="{{ route('admin.categories.destroy', $category) }}" style="display:inline-block" onsubmit="return confirm('Delete this category?');">
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
        {{ $categories->links() }}
    </div>
@endsection
