@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Subscriptions") }}</h1>
            <p class="muted">{{ t("Manage manager subscriptions and device limits.") }}</p>
        </div>
        <a class="btn" href="{{ route('admin.subscriptions.create') }}">{{ t("New Subscription") }}</a>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.subscriptions.index') }}" class="row">
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
            <div style="min-width: 180px;">
                <label>{{ t("Status") }}</label>
                <select name="status">
                    <option value="">{{ t("All") }}</option>
                    <option value="active" {{ $status === 'active' ? 'selected' : '' }}>{{ t("Active") }}</option>
                    <option value="paused" {{ $status === 'paused' ? 'selected' : '' }}>{{ t("Paused") }}</option>
                    <option value="canceled" {{ $status === 'canceled' ? 'selected' : '' }}>{{ t("Canceled") }}</option>
                    <option value="expired" {{ $status === 'expired' ? 'selected' : '' }}>{{ t("Expired") }}</option>
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
                    <th>{{ t("Manager") }}</th>
                    <th>{{ t("Plan") }}</th>
                    <th>{{ t("Status") }}</th>
                    <th>{{ t("Period") }}</th>
                    <th>{{ t("Days Left") }}</th>
                    <th>{{ t("Devices") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($subscriptions as $subscription)
                    @php
                        $startsAt = $subscription->starts_at;
                        $endsAt = $subscription->ends_at;
                        $daysLeft = $endsAt ? now()->diffInDays($endsAt, false) : null;
                        $deviceCount = $subscription->manager?->devices_count ?? 0;
                        $deviceLimit = $subscription->device_limit ?? $subscription->plan?->max_devices;
                    @endphp
                    <tr>
                        <td>{{ $subscription->manager?->name }}</td>
                        <td>{{ $subscription->plan?->name ?? t("No Plan") }}</td>
                        <td>{{ ucfirst($subscription->status) }}</td>
                        <td>
                            @if ($startsAt)
                                {{ $startsAt->format('Y-m-d') }}
                            @else
                                —
                            @endif
                            →
                            @if ($endsAt)
                                {{ $endsAt->format('Y-m-d') }}
                            @else
                                —
                            @endif
                        </td>
                        <td>
                            @if (is_null($daysLeft))
                                —
                            @elseif ($daysLeft < 0)
                                {{ t("Expired") }} ({{ abs($daysLeft) }} {{ t("days") }})
                            @else
                                {{ $daysLeft }} {{ t("days") }}
                            @endif
                        </td>
                        <td>
                            {{ $deviceCount }} / {{ $deviceLimit ?? t("Unlimited") }}
                        </td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.subscriptions.edit', $subscription) }}">{{ t("Edit") }}</a>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $subscriptions->links() }}
    </div>
@endsection
