@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Translations") }}</h1>
            <p class="muted">{{ t("Manage UI text for SaaS and Flutter.") }}</p>
        </div>
        <a class="btn" href="{{ route('admin.translations.create') }}">{{ t("New Translation") }}</a>
    </div>

    <div class="card" style="margin-bottom: 16px;">
        <form method="GET" action="{{ route('admin.translations.index') }}" class="row">
            <div style="min-width: 220px;">
                <label>{{ t("Language") }}</label>
                <select name="language_id">
                    <option value="">{{ t("All Languages") }}</option>
                    @foreach ($languages as $language)
                        <option value="{{ $language->id }}" {{ (string) $languageId === (string) $language->id ? 'selected' : '' }}>
                            {{ $language->name }} ({{ $language->code }})
                        </option>
                    @endforeach
                </select>
            </div>
            <div style="min-width: 180px;">
                <label>{{ t("Scope") }}</label>
                <select name="scope">
                    <option value="saas" {{ $scope === 'saas' ? 'selected' : '' }}>{{ t("SaaS") }}</option>
                    <option value="flutter" {{ $scope === 'flutter' ? 'selected' : '' }}>{{ t("Flutter") }}</option>
                </select>
            </div>
            <div style="min-width: 220px;">
                <label>{{ t("Search") }}</label>
                <input name="q" value="{{ $q }}" placeholder="{{ t("Key or value") }}">
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
                    <th>{{ t("Language") }}</th>
                    <th>{{ t("Scope") }}</th>
                    <th>{{ t("Key") }}</th>
                    <th>{{ t("Value") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($translations as $translation)
                    <tr>
                        <td>{{ $translation->language?->name }} ({{ $translation->language?->code }})</td>
                        <td>{{ strtoupper($translation->scope) }}</td>
                        <td>{{ $translation->key }}</td>
                        <td>{{ $translation->value }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.translations.edit', $translation) }}">{{ t("Edit") }}</a>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $translations->links() }}
    </div>
@endsection
