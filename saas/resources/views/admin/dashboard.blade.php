@extends('admin.layout')

@section('content')
    <h1>{{ t("Dashboard") }}</h1>
    <p class="muted">{{ t("Quick overview of your SaaS.") }}</p>

    <div class="grid">
        @foreach ($cards as $card)
            <a class="card card-link" href="{{ $card['route'] }}">
                <div class="muted">{{ t($card['label']) }}</div>
                @if (is_null($card['count']))
                    <h2>{{ t("Open") }}</h2>
                @else
                    <h2>{{ $card['count'] }}</h2>
                @endif
            </a>
        @endforeach
    </div>
@endsection
