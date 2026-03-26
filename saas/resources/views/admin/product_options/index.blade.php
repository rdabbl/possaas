@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Product Options") }}</h1>
            <p class="muted">{{ t("Manage product options.") }}</p>
        </div>
        <a class="btn" href="{{ route('admin.product_options.create') }}">{{ t("New Option") }}</a>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.product_options.index') }}" class="row">
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
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($options as $option)
                    <tr>
                        <td>{{ $option->manager?->name ?? 'Global' }}</td>
                        <td>
                            @if ($option->image_path)
                                <img src="{{ asset('storage/' . $option->image_path) }}" alt="Option image" style="width: 48px; height: 48px; object-fit: cover; border-radius: 6px;">
                            @else
                                —
                            @endif
                        </td>
                        <td>{{ $option->name }}</td>
                        <td>
                            @include('admin.partials.active_toggle', [
                                'route' => route('admin.toggle_active', ['type' => 'product_options', 'id' => $option->id]),
                                'checked' => $option->is_active,
                            ])
                        </td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.product_options.edit', $option) }}">{{ t("Edit") }}</a>
                            <form method="POST" action="{{ route('admin.product_options.destroy', $option) }}" style="display:inline-block" onsubmit="return confirm('Delete this option?');">
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
        {{ $options->links() }}
    </div>
@endsection
