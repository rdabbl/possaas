<?php

namespace App\Http\Controllers\Api;

use App\Models\StockMovement;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class StockMovementController extends BaseApiController
{
    public function index(Request $request)
    {
        $manager = $this->managerOrFail($request);
        $perPage = (int) $request->query('per_page', 50);

        $movements = StockMovement::where('manager_id', $manager->id)
            ->orderBy('id', 'desc')
            ->paginate($perPage);

        return response()->json($movements);
    }

    public function store(Request $request)
    {
        $manager = $this->managerOrFail($request);

        $data = $request->validate([
            'product_id' => [
                'required',
                Rule::exists('products', 'id')->where('manager_id', $manager->id),
            ],
            'store_id' => [
                'nullable',
                Rule::exists('stores', 'id')->where('manager_id', $manager->id),
            ],
            'user_id' => ['nullable', 'integer'],
            'quantity' => ['required', 'numeric', 'not_in:0'],
            'type' => ['nullable', Rule::in(['in', 'out', 'sale', 'refund', 'adjust'])],
            'reason' => ['nullable', 'string', 'max:255'],
            'ref_type' => ['nullable', 'string', 'max:255'],
            'ref_id' => ['nullable', 'integer'],
            'occurred_at' => ['nullable', 'date'],
        ]);

        $data['manager_id'] = $manager->id;
        $data['type'] = $data['type'] ?? 'adjust';
        $data['occurred_at'] = $data['occurred_at'] ?? now();

        $movement = StockMovement::create($data);

        return response()->json($movement, 201);
    }
}
