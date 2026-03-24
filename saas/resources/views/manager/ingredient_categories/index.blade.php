@extends('manager.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Ingredient Categories") }}</h1>
            <p class="muted">{{ t("Manage your ingredient categories.") }}</p>
        </div>
        <a class="btn" href="{{ route('manager.ingredient_categories.create') }}">{{ t("New Ingredient Category") }}</a>
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
                @foreach ($categories as $category)
                    <tr>
                        <td>{{ $category->id }}</td>
                        <td>
                            {{ $category->name }}
                            @if (!$category->manager_id)
                                <span class="muted">{{ t("(Global)") }}</span>
                            @endif
                        </td>
                        <td>{{ $category->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            @if ($category->manager_id)
                                <a class="btn secondary" href="{{ route('manager.ingredient_categories.edit', $category) }}">{{ t("Edit") }}</a>
                                <form method="POST" action="{{ route('manager.ingredient_categories.destroy', $category) }}" style="display:inline-block" onsubmit="return confirm('Delete this ingredient category?');">
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
        {{ $categories->links() }}
    </div>
@endsection
