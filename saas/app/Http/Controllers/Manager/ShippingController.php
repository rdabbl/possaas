<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\ShippingMethod;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ShippingController extends Controller
{
    private const TYPES = ['free', 'order_percent', 'per_item', 'manual'];

    public function index(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $methods = ShippingMethod::where('manager_id', $managerId)
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('manager.shipping.index', compact('methods'));
    }

    public function create()
    {
        $types = self::TYPES;
        return view('manager.shipping.create', compact('types'));
    }

    public function store(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'type' => ['required', Rule::in(self::TYPES)],
            'value' => ['nullable', 'numeric', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = $managerId;
        $data['is_active'] = $data['is_active'] ?? true;
        $data['value'] = $data['value'] ?? 0;

        ShippingMethod::create($data);

        return redirect()->route('manager.shipping.index')
            ->with('success', 'Shipping method created.');
    }

    public function edit(Request $request, ShippingMethod $shipping)
    {
        $managerId = $request->user()->manager_id;
        if ($shipping->manager_id !== $managerId) {
            abort(403);
        }
        $types = self::TYPES;
        return view('manager.shipping.edit', compact('shipping', 'types'));
    }

    public function update(Request $request, ShippingMethod $shipping)
    {
        $managerId = $request->user()->manager_id;
        if ($shipping->manager_id !== $managerId) {
            abort(403);
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'type' => ['required', Rule::in(self::TYPES)],
            'value' => ['nullable', 'numeric', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['value'] = $data['value'] ?? 0;

        $shipping->update($data);

        return redirect()->route('manager.shipping.index')
            ->with('success', 'Shipping method updated.');
    }

    public function destroy(Request $request, ShippingMethod $shipping)
    {
        $managerId = $request->user()->manager_id;
        if ($shipping->manager_id !== $managerId) {
            abort(403);
        }

        $shipping->delete();

        return redirect()->route('manager.shipping.index')
            ->with('success', 'Shipping method deleted.');
    }
}
