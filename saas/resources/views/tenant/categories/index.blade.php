@extends('tenant.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>Categories</h1>
            <p class="muted">Manage your product categories.</p>
        </div>
        <a class="btn" href="{{ route('tenant.categories.create') }}">New Category</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
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
                        <td>{{ $category->name }}</td>
                        <td>{{ $category->parent?->name }}</td>
                        <td>{{ $category->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('tenant.categories.edit', $category) }}">Edit</a>
                            <form method="POST" action="{{ route('tenant.categories.destroy', $category) }}" style="display:inline-block" onsubmit="return confirm('Delete this category?');">
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
