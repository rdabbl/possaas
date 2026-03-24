@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Ingredients") }}</h1>
            <p class="muted">{{ t("Manage ingredient options.") }}</p>
        </div>
        <a class="btn" href="{{ route('admin.ingredients.create') }}">{{ t("New Ingredient") }}</a>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.ingredients.index') }}" class="row">
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
                    <th>{{ t("Scope") }}</th>
                    <th>{{ t("Picture") }}</th>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($ingredients as $ingredient)
                    <tr>
                        <td>{{ $ingredient->id }}</td>
                        <td>{{ $ingredient->manager?->name ?? 'Global' }}</td>
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
                            <a class="btn secondary" href="{{ route('admin.ingredients.edit', $ingredient) }}">{{ t("Edit") }}</a>
                            <form method="POST" action="{{ route('admin.ingredients.destroy', $ingredient) }}" style="display:inline-block" onsubmit="return confirm('Delete this ingredient?');">
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

    <div style="margin-top: 12px;">
        {{ $ingredients->links() }}
    </div>
@endsection
