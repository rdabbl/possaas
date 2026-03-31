@extends('manager.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Shipping") }}</h1>
            <p class="muted">{{ t("Manage your shipping methods.") }}</p>
        </div>
        <a class="btn" href="{{ route('manager.shipping.create') }}">{{ t("New Shipping Method") }}</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Type") }}</th>
                    <th>{{ t("Value") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($methods as $method)
                    <tr>
                        <td>{{ $method->name }}</td>
                        <td>{{ $method->type }}</td>
                        <td>{{ $method->value }}</td>
                        <td>{{ $method->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('manager.shipping.edit', $method) }}">{{ t("Edit") }}</a>
                            <form method="POST" action="{{ route('manager.shipping.destroy', $method) }}" style="display:inline-block" onsubmit="return confirm('Delete this shipping method?');">
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
        {{ $methods->links() }}
    </div>
@endsection
