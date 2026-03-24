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
                    <th>{{ t("ID") }}</th>
                    <th>{{ t("Scope") }}</th>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Type") }}</th>
                    <th>{{ t("Default") }}</th>
                    <th>{{ t("Active") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($methods as $method)
                    <tr>
                        <td>{{ $method->id }}</td>
                        <td>{{ $method->manager?->name ?? 'Global' }}</td>
                        <td>{{ $method->name }}</td>
                        <td>{{ $method->type }}</td>
                        <td>{{ $method->is_default ? 'Yes' : 'No' }}</td>
                        <td>{{ $method->is_active ? 'Yes' : 'No' }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $methods->links() }}
    </div>
@endsection
