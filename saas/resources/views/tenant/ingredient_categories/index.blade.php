@extends('tenant.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>Ingredient Categories</h1>
            <p class="muted">Manage your ingredient categories.</p>
        </div>
        <a class="btn" href="{{ route('tenant.ingredient_categories.create') }}">New Ingredient Category</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Active</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($categories as $category)
                    <tr>
                        <td>{{ $category->id }}</td>
                        <td>{{ $category->name }}</td>
                        <td>{{ $category->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('tenant.ingredient_categories.edit', $category) }}">Edit</a>
                            <form method="POST" action="{{ route('tenant.ingredient_categories.destroy', $category) }}" style="display:inline-block" onsubmit="return confirm('Delete this ingredient category?');">
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
