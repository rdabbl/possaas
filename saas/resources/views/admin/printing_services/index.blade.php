@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Printing services") }}</h1>
            <p class="muted">{{ t("Manage backend printer services for POS and kiosk.") }}</p>
        </div>
        <a class="btn" href="{{ route('admin.printing_services.create') }}">{{ t("New Service") }}</a>
    </div>

    <div class="card" style="margin-bottom: 12px;">
        <form method="GET" class="row">
            <div style="min-width: 240px;">
                <label>{{ t("Manager") }}</label>
                <select name="manager_id">
                    <option value="">{{ t("All") }}</option>
                    @foreach ($managers as $manager)
                        <option value="{{ $manager->id }}" {{ request('manager_id') == $manager->id ? 'selected' : '' }}>{{ $manager->name }}</option>
                    @endforeach
                </select>
            </div>
            <div style="min-width: 240px;">
                <label>{{ t("Store") }}</label>
                <select name="store_id">
                    <option value="">{{ t("All") }}</option>
                    @foreach ($stores as $store)
                        <option value="{{ $store->id }}" {{ request('store_id') == $store->id ? 'selected' : '' }}>{{ $store->name }}</option>
                    @endforeach
                </select>
            </div>
            <div style="align-self: end;">
                <button type="submit" class="btn">{{ t("Filter") }}</button>
            </div>
        </form>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Manager") }}</th>
                    <th>{{ t("Store") }}</th>
                    <th>{{ t("Type") }}</th>
                    <th>{{ t("Template") }}</th>
                    <th>{{ t("Order") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($services as $service)
                    <tr>
                        <td>{{ $service->name }}</td>
                        <td>{{ $service->manager?->name ?? '-' }}</td>
                        <td>{{ $service->store?->name ?? '-' }}</td>
                        <td>{{ $service->type ?: '-' }}</td>
                        <td>{{ $templates[$service->template] ?? $service->template }}</td>
                        <td>{{ $service->sort_order }}</td>
                        <td>{{ $service->is_active ? t('Yes') : t('No') }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.printing_services.edit', $service) }}">{{ t("Edit") }}</a>
                            <form method="POST" action="{{ route('admin.printing_services.destroy', $service) }}" style="display:inline-block" onsubmit="return confirm('Delete this service?');">
                                @csrf
                                @method('DELETE')
                                <button class="btn secondary" type="submit">{{ t("Delete") }}</button>
                            </form>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="8" class="muted">{{ t("No printing services yet.") }}</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $services->links() }}
    </div>
@endsection
