<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\Tax;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class TaxController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $taxes = Tax::where(function ($query) use ($managerId) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $managerId);
        })
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('manager.taxes.index', compact('taxes'));
    }

    public function create()
    {
        return view('manager.taxes.create');
    }

    public function store(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('taxes', 'name')->where('manager_id', $managerId),
            ],
            'rate' => ['required', 'numeric', 'min:0'],
            'type' => ['required', Rule::in(['percent', 'fixed'])],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = $managerId;
        $data['is_active'] = $data['is_active'] ?? true;

        Tax::create($data);

        return redirect()->route('manager.taxes.index')
            ->with('success', 'Tax created.');
    }

    public function edit(Request $request, Tax $tax)
    {
        $managerId = $request->user()->manager_id;
        if ($tax->manager_id !== $managerId) {
            abort(403);
        }

        return view('manager.taxes.edit', compact('tax'));
    }

    public function update(Request $request, Tax $tax)
    {
        $managerId = $request->user()->manager_id;
        if ($tax->manager_id !== $managerId) {
            abort(403);
        }

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('taxes', 'name')->where('manager_id', $managerId)->ignore($tax->id),
            ],
            'rate' => ['required', 'numeric', 'min:0'],
            'type' => ['required', Rule::in(['percent', 'fixed'])],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $tax->update($data);

        return redirect()->route('manager.taxes.index')
            ->with('success', 'Tax updated.');
    }

    public function destroy(Request $request, Tax $tax)
    {
        $managerId = $request->user()->manager_id;
        if ($tax->manager_id !== $managerId) {
            abort(403);
        }

        $tax->delete();

        return redirect()->route('manager.taxes.index')
            ->with('success', 'Tax deleted.');
    }
}
