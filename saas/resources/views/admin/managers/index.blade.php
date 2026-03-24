@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Managers") }}</h1>
            <p class="muted">{{ t("Manage companies and limits.") }}</p>
        </div>
        <a class="btn" href="{{ route('admin.managers.create') }}">{{ t("New Manager") }}</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>{{ t("ID") }}</th>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Slug") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Max Stores") }}</th>
                    <th>{{ t("Max Devices") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($managers as $manager)
                    <tr>
                        <td>{{ $manager->id }}</td>
                        <td>{{ $manager->name }}</td>
                        <td>{{ $manager->slug }}</td>
                        <td>{{ $manager->is_active ? 'Yes' : 'No' }}</td>
                        <td>{{ $manager->max_stores ?? 'Unlimited' }}</td>
                        <td>{{ $manager->max_devices ?? 'Unlimited' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.managers.edit', $manager) }}">{{ t("Edit") }}</a>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $managers->links() }}
    </div>
@endsection
