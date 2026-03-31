<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Manager;
use App\Models\ShippingMethod;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ShippingController extends Controller
{
    private const TYPES = ['free', 'order_percent', 'per_item', 'manual'];

    public function index(Request $request)
    {
        $managerId = $request->query('manager_id');

        $query = ShippingMethod::query()->with('manager')->orderBy('id', 'desc');
        if ($managerId) {
            $query->where('manager_id', $managerId);
        }
        $methods = $query->paginate(20)->withQueryString();
        $managers = Manager::orderBy('name')->get();

        return view('admin.shipping.index', compact('methods', 'managers', 'managerId'));
    }

    public function create()
    {
        $managers = Manager::orderBy('name')->get();
        $types = self::TYPES;

        return view('admin.shipping.create', compact('managers', 'types'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'manager_id' => ['required', 'exists:managers,id'],
            'name' => ['required', 'string', 'max:255'],
            'type' => ['required', Rule::in(self::TYPES)],
            'value' => ['nullable', 'numeric', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['is_active'] = $data['is_active'] ?? true;
        $data['value'] = $data['value'] ?? 0;

        ShippingMethod::create($data);

        return redirect()->route('admin.shipping.index')
            ->with('success', 'Shipping method created.');
    }

    public function edit(ShippingMethod $shipping)
    {
        $managers = Manager::orderBy('name')->get();
        $types = self::TYPES;

        return view('admin.shipping.edit', compact('shipping', 'managers', 'types'));
    }

    public function update(Request $request, ShippingMethod $shipping)
    {
        $data = $request->validate([
            'manager_id' => ['required', 'exists:managers,id'],
            'name' => ['required', 'string', 'max:255'],
            'type' => ['required', Rule::in(self::TYPES)],
            'value' => ['nullable', 'numeric', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['is_active'] = $data['is_active'] ?? true;
        $data['value'] = $data['value'] ?? 0;

        $shipping->update($data);

        return redirect()->route('admin.shipping.index')
            ->with('success', 'Shipping method updated.');
    }

    public function destroy(ShippingMethod $shipping)
    {
        $shipping->delete();

        return redirect()->route('admin.shipping.index')
            ->with('success', 'Shipping method deleted.');
    }
}
