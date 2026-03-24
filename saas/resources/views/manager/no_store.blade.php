@extends('manager.layout')

@section('content')
    <div class="card" style="max-width: 640px;">
        <h1>{{ t("No store assigned") }}</h1>
        <p class="muted">
            {{ t("Your manager account is not linked to any store yet.") }}
        </p>
        <p class="muted">
            {{ t("Please contact the admin to assign a store to your account.") }}
        </p>
        <div class="row" style="margin-top: 16px;">
            <form method="POST" action="{{ route('logout') }}">
                @csrf
                <button class="btn secondary" type="submit">{{ t("Logout") }}</button>
            </form>
        </div>
    </div>
@endsection
