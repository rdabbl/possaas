@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>Plans</h1>
            <p class="muted">Manage subscription plans.</p>
        </div>
        <a class="btn" href="{{ route('admin.plans.create') }}">New Plan</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Duration (days)</th>
                    <th>Max Stores</th>
                    <th>Max Devices</th>
                    <th>Active</th>
                    <th>Actions</th>
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
                            <a class="btn secondary" href="{{ route('admin.plans.edit', $plan) }}">Edit</a>
                            <form method="POST" action="{{ route('admin.plans.destroy', $plan) }}" style="display:inline-block" onsubmit="return confirm('Delete this plan?');">
                                @csrf
                                @method('DELETE')
                                <button class="btn secondary" type="submit">Delete</button>
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
