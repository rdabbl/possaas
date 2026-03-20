@extends('tenant.layout')

@section('content')
    <div class="row" style="justify-content: space-between; align-items: center;">
        <div>
            <h1>Taxes</h1>
            <p class="muted">Manage your taxes.</p>
        </div>
        <a class="btn" href="{{ route('tenant.taxes.create') }}">New Tax</a>
    </div>

    <div class="card">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Rate</th>
                    <th>Type</th>
                    <th>Active</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($taxes as $tax)
                    <tr>
                        <td>{{ $tax->id }}</td>
                        <td>{{ $tax->name }}</td>
                        <td>{{ $tax->rate }}</td>
                        <td>{{ $tax->type }}</td>
                        <td>{{ $tax->is_active ? 'Yes' : 'No' }}</td>
                        <td>
                            <a class="btn secondary" href="{{ route('tenant.taxes.edit', $tax) }}">Edit</a>
                            <form method="POST" action="{{ route('tenant.taxes.destroy', $tax) }}" style="display:inline-block" onsubmit="return confirm('Delete this tax?');">
                                @csrf
                                @method('DELETE')
                                <button class="btn secondary" type="submit">Delete</button>
                            </form>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 12px;">
        {{ $taxes->links() }}
    </div>
@endsection
