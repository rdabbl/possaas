@extends('tenant.layout')

@section('content')
    <h1>New Category</h1>

    <div class="card">
        <form method="POST" action="{{ route('tenant.categories.store') }}" enctype="multipart/form-data">
            @csrf
            <div class="field">
                <label>Parent Category</label>
                <select name="parent_id">
                    <option value="">No Parent</option>
                    @foreach ($categories as $category)
                        <option value="{{ $category->id }}" {{ old('parent_id') == $category->id ? 'selected' : '' }}>
                            {{ $category->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>Name</label>
                <input name="name" value="{{ old('name') }}" required>
            </div>
            <div class="field">
                <label>Picture</label>
                <input type="file" name="image" accept="image/*">
            </div>
            <div class="field">
                <label>Active</label>
                <select name="is_active">
                    <option value="1" selected>Yes</option>
                    <option value="0">No</option>
                </select>
            </div>
            <button class="btn" type="submit">Create Category</button>
            <a class="btn secondary" href="{{ route('tenant.categories.index') }}">Cancel</a>
        </form>
    </div>
@endsection
