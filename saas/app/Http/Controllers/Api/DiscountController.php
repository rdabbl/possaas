<?php

namespace App\Http\Controllers\Api;

use App\Models\Discount;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class DiscountController extends BaseApiController
{
    public function index(Request $request)
    {
        $manager = $this->managerOrFail($request);
        $perPage = (int) $request->query('per_page', 50);

        $discounts = Discount::where(function ($query) use ($manager) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $manager->id);
        })
            ->orderBy('id', 'desc')
            ->paginate($perPage);

        return response()->json($discounts);
    }

    public function show(Request $request, int $id)
    {
        $manager = $this->managerOrFail($request);

        $discount = Discount::where(function ($query) use ($manager) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $manager->id);
        })->findOrFail($id);

        return response()->json($discount);
    }

    public function store(Request $request)
    {
        $manager = $this->managerOrFail($request);

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('discounts', 'name')->where('manager_id', $manager->id),
            ],
            'type' => ['required', Rule::in(['percent', 'fixed'])],
            'value' => ['required', 'numeric', 'min:0'],
            'scope' => ['required', Rule::in(['order', 'item'])],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = $manager->id;
        $data['is_active'] = $data['is_active'] ?? true;

        $discount = Discount::create($data);

        return response()->json($discount, 201);
    }

    public function update(Request $request, int $id)
    {
        $manager = $this->managerOrFail($request);

        $discount = Discount::where('manager_id', $manager->id)->findOrFail($id);

        $data = $request->validate([
            'name' => [
                'sometimes',
                'string',
                'max:255',
                Rule::unique('discounts', 'name')->where('manager_id', $manager->id)->ignore($discount->id),
            ],
            'type' => ['sometimes', Rule::in(['percent', 'fixed'])],
            'value' => ['sometimes', 'numeric', 'min:0'],
            'scope' => ['sometimes', Rule::in(['order', 'item'])],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $discount->update($data);

        return response()->json($discount);
    }

    public function destroy(Request $request, int $id)
    {
        $manager = $this->managerOrFail($request);

        $discount = Discount::where('manager_id', $manager->id)->findOrFail($id);
        $discount->delete();

        return response()->json(['message' => 'Deleted']);
    }
}
