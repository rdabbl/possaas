@extends('manager.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Discounts") }}</h1>
            <p class="muted">{{ t("Manage your discounts.") }}</p>
        </div>
        <a class="btn" href="{{ route('manager.discounts.create') }}">{{ t("New Discount") }}</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Value") }}</th>
                    <th>{{ t("Type") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($discounts as $discount)
                    <tr>
                        <td>
                            {{ $discount->name }}
                            @if (!$discount->manager_id)
                                <span class="muted">{{ t("(Global)") }}</span>
                            @endif
                        </td>
                        <td>{{ $discount->value }}</td>
                        <td>{{ $discount->type }}</td>
                        <td>{{ $discount->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            @if ($discount->manager_id)
                                <a class="btn secondary" href="{{ route('manager.discounts.edit', $discount) }}">{{ t("Edit") }}</a>
                                <form method="POST" action="{{ route('manager.discounts.destroy', $discount) }}" style="display:inline-block" onsubmit="return confirm('Delete this discount?');">
                                    @csrf
                                    @method('DELETE')
                                    <button class="btn secondary" type="submit">{{ t("Delete") }}</button>
                                </form>
                            @else
                                <span class="muted">{{ t("Global") }}</span>
                            @endif
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
