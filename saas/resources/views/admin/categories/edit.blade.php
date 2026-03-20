@extends('admin.layout')

@section('content')
    <h1>Edit Category</h1>
    <p class="muted">Tenant: {{ $category->tenant?->name }}</p>

    <div class="card">
        <form method="POST" action="{{ route('admin.categories.update', $category) }}" enctype="multipart/form-data">
            @csrf
            @method('PUT')
            <div class="field">
                <label>Parent Category</label>
                <select name="parent_id">
                    <option value="">No Parent</option>
                    @foreach ($categories as $parent)
                        <option value="{{ $parent->id }}" {{ (string) old('parent_id', $category->parent_id) === (string) $parent->id ? 'selected' : '' }}>
                            {{ $parent->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name', $category->name) }}" required>
            </div>
            <div class="field">
                <label>Picture</label>
                @if ($category->image_path)
                    <div style="margin-bottom: 8px;">
                        <img src="{{ asset('storage/' . $category->image_path) }}" alt="Category image" style="max-width: 160px; border-radius: 8px;">
                    </div>
                @endif
                <input type="file" name="image" accept="image/*">
            </div>
            <div class="field">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" {{ old('is_active', $category->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('is_active', $category->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <button class="btn" type="submit">Save</button>
            <a class="btn secondary" href="{{ route('admin.categories.index') }}">Cancel</a>
        </form>
    </div>
@endsection
