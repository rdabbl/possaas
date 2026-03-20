@extends('admin.layout')

@section('content')
    <h1>New Category</h1>

    <div class="card">
        <form method="POST" action="{{ route('admin.categories.store') }}" enctype="multipart/form-data">
            @csrf
            <div class="field">
                <label>Tenant</label>
                <select name="tenant_id" required>
                    <option value="">Select Tenant</option>
                    @foreach ($tenants as $tenant)
                        <option value="{{ $tenant->id }}" {{ old('tenant_id') == $tenant->id ? 'selected' : '' }}>
                            {{ $tenant->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label>Parent Category</label>
                <select name="parent_id">
                    <option value="">No Parent</option>
                    @foreach ($categories as $category)
                        <option value="{{ $category->id }}" {{ old('parent_id') == $category->id ? 'selected' : '' }}>
                            {{ $category->name }} ({{ $category->tenant?->name }})
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
            <a class="btn secondary" href="{{ route('admin.categories.index') }}">Cancel</a>
        </form>
    </div>
@endsection
