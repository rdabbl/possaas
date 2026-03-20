@extends('admin.layout')

@section('content')
    <h1>Edit Ingredient</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.ingredients.update', $ingredient) }}" enctype="multipart/form-data">
            @csrf
            @method('PUT')
            <div class="field">
                <label>Category</label>
                <select name="ingredient_category_id">
                    <option value="">No Category</option>
                    @foreach ($categories as $category)
                        <option value="{{ $category->id }}" {{ (string) old('ingredient_category_id', $ingredient->ingredient_category_id) === (string) $category->id ? 'selected' : '' }}>
                            {{ $category->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name', $ingredient->name) }}" required>
            </div>
            <div class="field">
                <label>Picture</label>
                @if ($ingredient->image_path)
                    <div style="margin-bottom: 8px;">
                        <img src="{{ asset('storage/' . $ingredient->image_path) }}" alt="Ingredient image" style="max-width: 160px; border-radius: 8px;">
                    </div>
                @endif
                <input type="file" name="image" accept="image/*">
            </div>
            <div class="field">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" {{ old('is_active', $ingredient->is_active ? 1 : 0) == 1 ? 'selected' : '' }}>Yes</option>
                    <option value="0" {{ old('is_active', $ingredient->is_active ? 1 : 0) == 0 ? 'selected' : '' }}>No</option>
                </select>
            </div>
            <button class="btn" type="submit">Save</button>
            <a class="btn secondary" href="{{ route('admin.ingredients.index') }}">Cancel</a>
        </form>
    </div>
@endsection
