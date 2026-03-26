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
                    <th>{{ t("Profile") }}</th>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Username") }}</th>
                    <th>{{ t("Plan") }}</th>
                    <th>{{ t("Expires In") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Max Stores") }}</th>
                    <th>{{ t("Max Devices") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($managers as $manager)
                    <tr>
                        <td>
                            @php
                                $initials = collect(explode(' ', trim($manager->name)))
                                    ->filter()
                                    ->take(2)
                                    ->map(fn ($part) => strtoupper(substr($part, 0, 1)))
                                    ->implode('');
                            @endphp
                            <div class="avatar">{{ $initials ?: 'M' }}</div>
                        </td>
                        <td>{{ $manager->name }}</td>
                        <td>{{ $manager->username }}</td>
                        <td>{{ $manager->plan?->name ?? $manager->plan_name ?? t("No Plan") }}</td>
                        <td>
                            @php
                                $expiresAt = $manager->latestSubscription?->ends_at;
                                if (!$expiresAt) {
                                    $duration = $manager->plan?->duration_days;
                                    $expiresAt = $duration ? $manager->created_at?->copy()->addDays($duration) : null;
                                }
                                $daysLeft = $expiresAt ? now()->diffInDays($expiresAt, false) : null;
                            @endphp
                            @if (is_null($daysLeft))
                                —
                            @elseif ($daysLeft < 0)
                                {{ t("Expired") }} ({{ abs($daysLeft) }} {{ t("days") }})
                            @else
                                {{ $daysLeft }} {{ t("days") }}
                            @endif
                        </td>
                        <td>
                            @include('admin.partials.active_toggle', [
                                'route' => route('admin.toggle_active', ['type' => 'managers', 'id' => $manager->id]),
                                'checked' => $manager->is_active,
                            ])
                        </td>
                        <td>{{ $manager->max_stores ?? 'Unlimited' }}</td>
                        <td>{{ $manager->max_devices ?? 'Unlimited' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.managers.edit', $manager) }}">{{ t("Edit") }}</a>
                            <form method="POST" action="{{ route('admin.managers.destroy', $manager) }}" style="display:inline;">
                                @csrf
                                @method('DELETE')
                                <button class="btn secondary" type="submit" onclick="return confirm('{{ t("Delete this manager?") }}')">
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
        {{ $managers->links() }}
    </div>
@endsection
