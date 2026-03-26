@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Customers") }}</h1>
            <p class="muted">{{ t("Manage customers.") }}</p>
        </div>
        <a class="btn" href="{{ route('admin.customers.create') }}">{{ t("New Customer") }}</a>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.customers.index') }}" class="row">
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
                    <th>{{ t("Email") }}</th>
                    <th>{{ t("Phone") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($customers as $customer)
                    <tr>
                        <td>{{ $customer->manager?->name }}</td>
                        <td>{{ $customer->name }}</td>
                        <td>{{ $customer->email }}</td>
                        <td>{{ $customer->phone }}</td>
                        <td>
                            @include('admin.partials.active_toggle', [
                                'route' => route('admin.toggle_active', ['type' => 'customers', 'id' => $customer->id]),
                                'checked' => $customer->is_active,
                            ])
                        </td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.customers.edit', $customer) }}">{{ t("Edit") }}</a>
                            <form method="POST" action="{{ route('admin.customers.destroy', $customer) }}" style="display:inline-block" onsubmit="return confirm('Delete this customer?');">
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
        {{ $customers->links() }}
    </div>
@endsection
