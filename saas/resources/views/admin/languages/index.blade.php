@extends('admin.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Languages") }}</h1>
            <p class="muted">{{ t("Manage available languages.") }}</p>
        </div>
        <a class="btn" href="{{ route('admin.languages.create') }}">{{ t("New Language") }}</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>{{ t("Code") }}</th>
                    <th>{{ t("Name") }}</th>
                    <th>{{ t("Native") }}</th>
                    <th>{{ t("Direction") }}</th>
                    <th>{{ t("Default") }}</th>
                    <th>{{ t("Active") }}</th>
                    <th>{{ t("Actions") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($languages as $language)
                    <tr>
                        <td>{{ $language->code }}</td>
                        <td>{{ $language->name }}</td>
                        <td>{{ $language->native_name ?? '—' }}</td>
                        <td>{{ strtoupper($language->direction) }}</td>
                        <td>{{ $language->is_default ? 'Yes' : 'No' }}</td>
                        <td>{{ $language->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('admin.languages.edit', $language) }}">{{ t("Edit") }}</a>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $languages->links() }}
    </div>
@endsection
