<form method="POST" action="{{ $route }}" data-toggle-form class="toggle-form">
    @csrf
    @method('PATCH')
    <label class="toggle">
        <input type="checkbox" name="is_active" value="1" {{ $checked ? 'checked' : '' }}>
        <span></span>
    </label>
</form>
