@extends('manager.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Customers") }}</h1>
            <p class="muted">{{ t("Manage your customers.") }}</p>
        </div>
        <a class="btn" href="{{ route('manager.customers.create') }}">{{ t("New Customer") }}</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Email") }}</th>
                    <th>{{ t("Phone") }}</th>
                    <th>{{ t("Points") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($customers as $customer)
                    <tr>
                        <td>{{ $customer->name }}</td>
                        <td>{{ $customer->email }}</td>
                        <td>{{ $customer->phone }}</td>
                        <td>{{ $customer->loyalty_points_balance ?? 0 }}</td>
                        <td>{{ $customer->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('manager.customers.edit', $customer) }}">{{ t("Edit") }}</a>
                            <form method="POST" action="{{ route('manager.customers.duplicate', $customer) }}" style="display:inline-block">
                                @csrf
                                <button class="btn secondary" type="submit">{{ t("Duplicate") }}</button>
                            </form>
                            <form method="POST" action="{{ route('manager.customers.destroy', $customer) }}" style="display:inline-block" onsubmit="return confirm('Delete this customer?');">
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
