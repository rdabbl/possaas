@extends('admin.layout')

@section('content')
    <h1>{{ t("Edit Translation") }}</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.translations.update', $translation) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>{{ t("Language") }}</label>
                <select name="language_id" required>
                    @foreach ($languages as $language)
                        <option value="{{ $language->id }}" {{ (string) old('language_id', $translation->language_id) === (string) $language->id ? 'selected' : '' }}>
                            {{ $language->name }} ({{ $language->code }})
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Scope") }}</label>
                <select name="scope">
                    <option value="saas" {{ old('scope', $translation->scope) === 'saas' ? 'selected' : '' }}>{{ t("SaaS") }}</option>
                    <option value="flutter" {{ old('scope', $translation->scope) === 'flutter' ? 'selected' : '' }}>{{ t("Flutter") }}</option>
                </select>
            </div>
            <div class="field">
                <label>{{ t("Key") }}</label>
                <input name="key" value="{{ old('key', $translation->key) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Value") }}</label>
                <input name="value" value="{{ old('value', $translation->value) }}" required>
            </div>
            <button class="btn" type="submit">{{ t("Save") }}</button>
            <a class="btn secondary" href="{{ route('admin.translations.index') }}">{{ t("Cancel") }}</a>
        </form>
    </div>
@endsection
