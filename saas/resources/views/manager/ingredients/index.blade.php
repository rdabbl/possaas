@extends('manager.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Ingredients") }}</h1>
            <p class="muted">{{ t("Manage ingredient options.") }}</p>
        </div>
        <a class="btn" href="{{ route('manager.ingredients.create') }}">{{ t("New Ingredient") }}</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>{{ t("ID") }}</th>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($ingredients as $ingredient)
                    <tr>
                        <td>{{ $ingredient->id }}</td>
                        <td>
                            {{ $ingredient->name }}
                            @if (!$ingredient->manager_id)
                                <span class="muted">{{ t("(Global)") }}</span>
                            @endif
                        </td>
                        <td>{{ $ingredient->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            @if ($ingredient->manager_id)
                                <a class="btn secondary" href="{{ route('manager.ingredients.edit', $ingredient) }}">{{ t("Edit") }}</a>
                                <form method="POST" action="{{ route('manager.ingredients.destroy', $ingredient) }}" style="display:inline-block" onsubmit="return confirm('Delete this ingredient?');">
                                    @csrf
                                    @method('DELETE')
                                    <button class="btn secondary" type="submit">{{ t("Delete") }}</button>
                                </form>
                            @else
                                <span class="muted">{{ t("Global") }}</span>
                            @endif
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
