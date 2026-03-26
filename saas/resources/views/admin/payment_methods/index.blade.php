@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Payment Methods") }}</h1>
            <p class="muted">{{ t("Manage cash and other payment types.") }}</p>
        </div>
        <a class="btn" href="{{ route('admin.payment_methods.create') }}">{{ t("New Method") }}</a>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.payment_methods.index') }}" class="row">
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
                    <th>{{ t("Default") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($methods as $method)
                    <tr>
                        <td>{{ $method->manager?->name ?? 'Global' }}</td>
                        <td>{{ $method->name }}</td>
                        <td>{{ $method->type }}</td>
                        <td>{{ $method->is_default ? 'Yes' : 'No' }}</td>
                        <td>
                            @include('admin.partials.active_toggle', [
                                'route' => route('admin.toggle_active', ['type' => 'payment_methods', 'id' => $method->id]),
                                'checked' => $method->is_active,
                            ])
                        </td>
                        <td>
                            <form method="POST" action="{{ route('admin.payment_methods.destroy', $method) }}" style="display:inline;">
                                @csrf
                                @method('DELETE')
                                <button class="btn secondary" type="submit" onclick="return confirm('{{ t("Delete this payment method?") }}')">
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
        {{ $methods->links() }}
    </div>
@endsection
