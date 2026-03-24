@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Discounts") }}</h1>
            <p class="muted">{{ t("Manage discounts.") }}</p>
        </div>
        <a class="btn" href="{{ route('admin.discounts.create') }}">{{ t("New Discount") }}</a>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.discounts.index') }}" class="row">
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
                    <th>{{ t("Value") }}</th>
                    <th>{{ t("Scope") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($discounts as $discount)
                    <tr>
                        <td>{{ $discount->id }}</td>
                        <td>{{ $discount->manager?->name ?? 'Global' }}</td>
                        <td>{{ $discount->name }}</td>
                        <td>{{ $discount->type }}</td>
                        <td>{{ $discount->value }}</td>
                        <td>{{ $discount->scope }}</td>
                        <td>{{ $discount->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.discounts.edit', $discount) }}">{{ t("Edit") }}</a>
                            <form method="POST" action="{{ route('admin.discounts.destroy', $discount) }}" style="display:inline-block" onsubmit="return confirm('Delete this discount?');">
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
        {{ $discounts->links() }}
    </div>
@endsection
