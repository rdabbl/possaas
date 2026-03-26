@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Taxes") }}</h1>
            <p class="muted">{{ t("Manage tax rates.") }}</p>
        </div>
        <a class="btn" href="{{ route('admin.taxes.create') }}">{{ t("New Tax") }}</a>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.taxes.index') }}" class="row">
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
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Type") }}</th>
                    <th>{{ t("Rate") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($taxes as $tax)
                    <tr>
                        <td>{{ $tax->manager?->name ?? 'Global' }}</td>
                        <td>{{ $tax->name }}</td>
                        <td>{{ $tax->type }}</td>
                        <td>{{ $tax->rate }}</td>
                        <td>
                            @include('admin.partials.active_toggle', [
                                'route' => route('admin.toggle_active', ['type' => 'taxes', 'id' => $tax->id]),
                                'checked' => $tax->is_active,
                            ])
                        </td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.taxes.edit', $tax) }}">{{ t("Edit") }}</a>
                            <form method="POST" action="{{ route('admin.taxes.destroy', $tax) }}" style="display:inline-block" onsubmit="return confirm('Delete this tax?');">
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
        {{ $taxes->links() }}
    </div>
@endsection
