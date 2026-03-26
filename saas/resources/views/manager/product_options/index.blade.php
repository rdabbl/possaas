@extends('manager.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Product Options") }}</h1>
            <p class="muted">{{ t("Manage product options.") }}</p>
        </div>
        <a class="btn" href="{{ route('manager.product_options.create') }}">{{ t("New Option") }}</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($options as $option)
                    <tr>
                        <td>
                            {{ $option->name }}
                            @if (!$option->manager_id)
                                <span class="muted">{{ t("(Global)") }}</span>
                            @endif
                        </td>
                        <td>{{ $option->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            <form method="POST" action="{{ route('manager.product_options.duplicate', $option) }}" style="display:inline-block">
                                @csrf
                                <button class="btn secondary" type="submit">{{ t("Duplicate") }}</button>
                            </form>
                            @if ($option->manager_id)
                                <a class="btn secondary" href="{{ route('manager.product_options.edit', $option) }}">{{ t("Edit") }}</a>
                                <form method="POST" action="{{ route('manager.product_options.destroy', $option) }}" style="display:inline-block" onsubmit="return confirm('Delete this option?');">
                                    @csrf
                                    @method('DELETE')
                                    <button class="btn secondary" type="submit">{{ t("Delete") }}</button>
                                </form>
                            @endif
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $options->links() }}
    </div>
@endsection
