@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Currencies") }}</h1>
            <p class="muted">{{ t("Manage available currencies.") }}</p>
        </div>
        <a class="btn" href="{{ route('admin.currencies.create') }}">{{ t("New Currency") }}</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>{{ t("ID") }}</th>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Code") }}</th>
                    <th>{{ t("Symbol") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($currencies as $currency)
                    <tr>
                        <td>{{ $currency->id }}</td>
                        <td>{{ $currency->name }}</td>
                        <td>{{ $currency->code }}</td>
                        <td>{{ $currency->symbol }}</td>
                        <td>{{ $currency->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.currencies.edit', $currency) }}">{{ t("Edit") }}</a>
                            <form method="POST" action="{{ route('admin.currencies.destroy', $currency) }}" style="display:inline;">
                                @csrf
                                @method('DELETE')
                                <button class="btn secondary" type="submit" onclick="return confirm('{{ t("Delete this currency?") }}')">
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
        {{ $currencies->links() }}
    </div>
@endsection
