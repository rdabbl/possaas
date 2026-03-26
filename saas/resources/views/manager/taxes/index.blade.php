@extends('manager.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Taxes") }}</h1>
            <p class="muted">{{ t("Manage your taxes.") }}</p>
        </div>
        <a class="btn" href="{{ route('manager.taxes.create') }}">{{ t("New Tax") }}</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Rate") }}</th>
                    <th>{{ t("Type") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($taxes as $tax)
                    <tr>
                        <td>
                            {{ $tax->name }}
                            @if (!$tax->manager_id)
                                <span class="muted">{{ t("(Global)") }}</span>
                            @endif
                        </td>
                        <td>{{ $tax->rate }}</td>
                        <td>{{ $tax->type }}</td>
                        <td>{{ $tax->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            @if ($tax->manager_id)
                                <a class="btn secondary" href="{{ route('manager.taxes.edit', $tax) }}">{{ t("Edit") }}</a>
                                <form method="POST" action="{{ route('manager.taxes.destroy', $tax) }}" style="display:inline-block" onsubmit="return confirm('Delete this tax?');">
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
        {{ $taxes->links() }}
    </div>
@endsection
