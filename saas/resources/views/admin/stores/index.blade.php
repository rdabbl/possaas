@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Stores") }}</h1>
            <p class="muted">{{ t("Manage manager stores.") }}</p>
        </div>
        <a class="btn" href="{{ route('admin.stores.create') }}">{{ t("New Store") }}</a>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.stores.index') }}" class="row">
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
                    <th>{{ t("Manager") }}</th>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Code") }}</th>
                    <th>{{ t("Stock") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($stores as $store)
                    <tr>
                        <td>{{ $store->manager?->name }}</td>
                        <td>{{ $store->name }}</td>
                        <td>{{ $store->code }}</td>
                        <td>{{ $store->stock_enabled ? 'Enabled' : 'Disabled' }}</td>
                        <td>
                            @include('admin.partials.active_toggle', [
                                'route' => route('admin.toggle_active', ['type' => 'stores', 'id' => $store->id]),
                                'checked' => $store->is_active,
                            ])
                        </td>
                        <td>
                            <form method="POST" action="{{ route('admin.stores.destroy', $store) }}" style="display:inline;">
                                @csrf
                                @method('DELETE')
                                <button class="btn secondary" type="submit" onclick="return confirm('{{ t("Delete this store?") }}')">
                                    {{ t("Delete") }}
                                </button>
                            </form>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $stores->links() }}
    </div>
@endsection
