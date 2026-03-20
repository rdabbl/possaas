@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>Ingredients</h1>
            <p class="muted">Manage ingredient options.</p>
        </div>
        <a class="btn" href="{{ route('admin.ingredients.create') }}">New Ingredient</a>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.ingredients.index') }}" class="row">
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
                    <th>Active</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($ingredients as $ingredient)
                    <tr>
                        <td>{{ $ingredient->id }}</td>
                        <td>{{ $ingredient->tenant?->name }}</td>
                        <td>
                            @if ($ingredient->image_path)
                                <img src="{{ asset('storage/' . $ingredient->image_path) }}" alt="Ingredient image" style="width: 48px; height: 48px; object-fit: cover; border-radius: 6px;">
                            @else
                                —
                            @endif
                        </td>
                        <td>{{ $ingredient->name }}</td>
                        <td>{{ $ingredient->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.ingredients.edit', $ingredient) }}">Edit</a>
                            <form method="POST" action="{{ route('admin.ingredients.destroy', $ingredient) }}" style="display:inline-block" onsubmit="return confirm('Delete this ingredient?');">
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
        {{ $ingredients->links() }}
    </div>
@endsection
