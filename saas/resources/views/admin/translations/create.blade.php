@extends('admin.layout')

@section('content')
    <h1>{{ t("New Translation") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.translations.store') }}">
            @csrf
            <div class="field">
                <label>{{ t("Language") }}</label>
                <select name="language_id" required>
                    <option value="">{{ t("Select Language") }}</option>
                    @foreach ($languages as $language)
                        <option value="{{ $language->id }}" {{ old('language_id') == $language->id ? 'selected' : '' }}>
                            {{ $language->name }} ({{ $language->code }})
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Scope") }}</label>
                <select name="scope">
                    <option value="saas" selected>{{ t("SaaS") }}</option>
                    <option value="flutter">{{ t("Flutter") }}</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Key") }}</label>
                <input name="key" value="{{ old('key') }}" required>
            </div>
            <div class="field">
                <label>{{ t("Value") }}</label>
                <input name="value" value="{{ old('value') }}" required>
            </div>
            <button class="btn" type="submit">{{ t("Create Translation") }}</button>
            <a class="btn secondary" href="{{ route('admin.translations.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
