@extends('manager.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Printing services") }}</h1>
            <p class="muted">{{ t("Configure the printers used by your services.") }}</p>
            @if ($store)
                <p class="muted">{{ t("Store") }}: {{ $store->name }}</p>
            @endif
        </div>
        <a class="btn" href="{{ route('manager.printing_services.create') }}">{{ t("New Service") }}</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>{{ t("Name") }}</th>
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
                        <td>{{ $service->type ?: '-' }}</td>
                        <td>{{ $templates[$service->template] ?? $service->template }}</td>
                        <td>{{ $service->sort_order }}</td>
                        <td>{{ $service->is_active ? t('Yes') : t('No') }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('manager.printing_services.edit', $service) }}">{{ t("Edit") }}</a>
                            <form method="POST" action="{{ route('manager.printing_services.destroy', $service) }}" style="display:inline-block" onsubmit="return confirm('Delete this service?');">
                                @csrf
                                @method('DELETE')
                                <button class="btn secondary" type="submit">{{ t("Delete") }}</button>
                            </form>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" class="muted">{{ t("No printing services yet.") }}</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $services->links() }}
    </div>
@endsection
