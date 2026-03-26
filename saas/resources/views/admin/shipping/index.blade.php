@extends('admin.layout')

@section('content')
    <h1>{{ t("Shipping") }}</h1>
    <p class="muted">{{ t("Prepare shipping settings for the POS mobile app.") }}</p>

    <div class="card">
        <h3>{{ t("Coming Soon") }}</h3>
        <p class="muted">{{ t("This module will manage shipping methods, rates, and zones used by the Flutter POS app.") }}</p>
    </div>
@endsection
