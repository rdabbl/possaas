@extends('manager.layout')

@section('content')
    <div class="card">
        <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap;">
            <div>
                <h1>{{ t("Payment Methods") }}</h1>
                <p class="muted">{{ t("Activate or deactivate payment methods added by admin.") }}</p>
            </div>
        </div>

        <table style="margin-top:16px;">
            <thead>
                <tr>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Type") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Default") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($globalMethods as $method)
                    @php
                        $key = mb_strtolower(trim($method->name)) . '|' . ($method->type ?? '');
                        $override = $overrides[$key] ?? null;
                        $isActive = $override?->is_active ?? $method->is_active;
                        $isDefault = $override?->is_default ?? false;
                    @endphp
                    <tr>
                        <td>{{ $method->name }}</td>
                        <td>{{ strtoupper($method->type ?? 'other') }}</td>
                        <td>{{ $isActive ? t("Yes") : t("No") }}</td>
                        <td>{{ $isDefault ? t("Yes") : t("No") }}</td>
                        <td>
                            <form method="POST" action="{{ route('manager.payment_methods.update', $method->id) }}" class="row" style="align-items:center;">
                                @csrf
                                @method('PUT')
                                <label style="margin:0;">
                                    <input type="hidden" name="is_active" value="0">
                                    <input type="checkbox" name="is_active" value="1" {{ $isActive ? 'checked' : '' }}>
                                    {{ t("Active") }}
                                </label>
                                <label style="margin:0;">
                                    <input type="hidden" name="is_default" value="0">
                                    <input type="checkbox" name="is_default" value="1" {{ $isDefault ? 'checked' : '' }}>
                                    {{ t("Default") }}
                                </label>
                                <button class="btn" type="submit">{{ t("Save") }}</button>
                            </form>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="5" class="muted">{{ t("No payment methods available.") }}</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
@endsection
