@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Categories") }}</h1>
            <p class="muted">{{ t("Manage product categories.") }}</p>
        </div>
        <a class="btn" href="{{ route('admin.categories.create') }}">{{ t("New Category") }}</a>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.categories.index') }}" class="row">
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
                    <th>{{ t("Scope") }}</th>
                    <th>{{ t("Picture") }}</th>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Parent") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($categories as $category)
                    <tr>
                        <td>{{ $category->manager?->name ?? 'Global' }}</td>
                        <td>
                            @if ($category->image_path)
                                <img src="{{ asset('storage/' . $category->image_path) }}" alt="Category image" style="width: 48px; height: 48px; object-fit: cover; border-radius: 6px;">
                            @else
                                —
                            @endif
                        </td>
                        <td>{{ $category->name }}</td>
                        <td>{{ $category->parent?->name }}</td>
                        <td>
                            @include('admin.partials.active_toggle', [
                                'route' => route('admin.toggle_active', ['type' => 'categories', 'id' => $category->id]),
                                'checked' => $category->is_active,
                            ])
                        </td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.categories.edit', $category) }}">{{ t("Edit") }}</a>
                            <form method="POST" action="{{ route('admin.categories.destroy', $category) }}" style="display:inline-block" onsubmit="return confirm('Delete this category?');">
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
        {{ $categories->links() }}
    </div>
@endsection
