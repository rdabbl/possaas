@extends('tenant.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>Ingredients</h1>
            <p class="muted">Manage ingredient options.</p>
        </div>
        <a class="btn" href="{{ route('tenant.ingredients.create') }}">New Ingredient</a>
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
                @foreach ($ingredients as $ingredient)
                    <tr>
                        <td>{{ $ingredient->id }}</td>
                        <td>{{ $ingredient->name }}</td>
                        <td>{{ $ingredient->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('tenant.ingredients.edit', $ingredient) }}">Edit</a>
                            <form method="POST" action="{{ route('tenant.ingredients.destroy', $ingredient) }}" style="display:inline-block" onsubmit="return confirm('Delete this ingredient?');">
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
