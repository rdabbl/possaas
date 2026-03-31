@extends('manager.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>{{ t("Edit printing service") }}</h1>
            <p class="muted">{{ t("Update the service configuration.") }}</p>
        </div>
        <a class="btn secondary" href="{{ route('manager.printing_services.index') }}">{{ t("Back") }}</a>
    </div>

    <div class="card">
        <form method="POST" action="{{ route('manager.printing_services.update', $service) }}">
            @csrf
            @method('PUT')
            <div class="field">
                <label>{{ t("Service name") }}</label>
                <input type="text" name="name" value="{{ old('name', $service->name) }}" required>
            </div>
            <div class="field">
                <label>{{ t("Service type") }}</label>
                <input type="text" name="type" value="{{ old('type', $service->type) }}" placeholder="pos, caisse, cuisine, borne">
            </div>
            <div class="field">
                <label>{{ t("Print template") }}</label>
                <select name="template" required>
                    @foreach ($templates as $key => $label)
                        <option value="{{ $key }}" {{ old('template', $service->template) === $key ? 'selected' : '' }}>{{ $label }}</option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>{{ t("Order") }}</label>
                <input type="number" name="sort_order" min="0" value="{{ old('sort_order', $service->sort_order) }}">
            </div>
            <div class="field">
                <label>
                    <input type="checkbox" name="is_active" value="1" {{ old('is_active', $service->is_active) ? 'checked' : '' }}>
                    {{ t("Active") }}
                </label>
            </div>
            <button class="btn" type="submit">{{ t("Update") }}</button>
        </form>
    </div>
@endsection
