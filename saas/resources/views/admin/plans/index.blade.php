@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Plans") }}</h1>
            <p class="muted">{{ t("Manage subscription plans.") }}</p>
        </div>
        <a class="btn" href="{{ route('admin.plans.create') }}">{{ t("New Plan") }}</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>{{ t("ID") }}</th>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Duration (days)") }}</th>
                    <th>{{ t("Max Stores") }}</th>
                    <th>{{ t("Max Devices") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($plans as $plan)
                    <tr>
                        <td>{{ $plan->id }}</td>
                        <td>{{ $plan->name }}</td>
                        <td>{{ $plan->duration_days ?? '—' }}</td>
                        <td>{{ $plan->max_stores ?? '—' }}</td>
                        <td>{{ $plan->max_devices ?? '—' }}</td>
                        <td>{{ $plan->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.plans.edit', $plan) }}">{{ t("Edit") }}</a>
                            <form method="POST" action="{{ route('admin.plans.destroy', $plan) }}" style="display:inline-block" onsubmit="return confirm('Delete this plan?');">
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
        {{ $plans->links() }}
    </div>
@endsection
