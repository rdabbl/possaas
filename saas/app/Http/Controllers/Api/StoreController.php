<?php

namespace App\Http\Controllers\Api;

use App\Models\Store;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class StoreController extends BaseApiController
{
    public function index(Request $request)
    {
        $manager = $this->managerOrFail($request);

        $stores = Store::with('currency')
            ->where('manager_id', $manager->id)
            ->orderBy('id', 'desc')
            ->get();

        return response()->json($stores);
    }

    public function store(Request $request)
    {
        $manager = $this->managerOrFail($request);

        if ($manager->max_stores !== null) {
            $count = Store::where('manager_id', $manager->id)->count();
            if ($count >= $manager->max_stores) {
                return response()->json([
                    'message' => 'Store limit reached for this manager.',
                ], 422);
            }
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'currency_id' => ['nullable', Rule::exists('currencies', 'id')->where('is_active', true)],
            'code' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('stores', 'code')->where('manager_id', $manager->id),
            ],
            'phone' => ['nullable', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'stock_enabled' => ['nullable', 'boolean'],
            'is_currency_right' => ['nullable', 'boolean'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = $manager->id;
        $data['stock_enabled'] = $data['stock_enabled'] ?? true;
        $data['is_currency_right'] = $data['is_currency_right'] ?? true;
        $data['is_active'] = $data['is_active'] ?? true;

        $store = Store::create($data);

        return response()->json($store, 201);
    }

    public function update(Request $request, Store $store)
    {
        $manager = $this->managerOrFail($request);

        if ($store->manager_id !== $manager->id) {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        $data = $request->validate([
            'currency' => ['nullable', 'integer'],
            'currency_id' => ['nullable', Rule::exists('currencies', 'id')->where('is_active', true)],
            'is_currency_right' => ['nullable', 'boolean'],
        ]);

        if (array_key_exists('currency', $data) && empty($data['currency_id'])) {
            $data['currency_id'] = $data['currency'];
        }

        $store->update($data);

        return response()->json($store->fresh('currency'));
    }
}
