@extends('manager.layout')

@section('content')
    @php
        use App\Models\Store;
        $user = auth()->user();
        $manager = $user?->manager;
        $storeCount = $manager ? Store::where('manager_id', $manager->id)->count() : 0;
        $maxStores = $manager?->max_stores;
        $canCreateStore = $manager && ($maxStores === null || $storeCount < $maxStores);
    @endphp
    <div class="card" style="max-width: 640px;">
        <h1>{{ t("No store assigned") }}</h1>
        <p class="muted">
            {{ t("Your manager account is not linked to any store yet.") }}
        </p>
        @if ($canCreateStore)
            <p class="muted">
                {{ t("You can create your first store to start using the POS.") }}
            </p>
        @else
            <p class="muted">
                {{ t("Please contact the admin to assign a store to your account.") }}
            </p>
        @endif
        <div class="row" style="margin-top: 16px;">
            @if ($canCreateStore)
                <a class="btn" href="{{ route('manager.stores.create') }}">
                    {{ t("Create a store") }}
                </a>
                <span style="width: 8px;"></span>
            @endif
            <form method="POST" action="{{ route('logout') }}">
                @csrf
                <button class="btn secondary" type="submit">{{ t("Logout") }}</button>
            </form>
        </div>
    </div>
@endsection
