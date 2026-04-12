<?php

namespace App\Http\Controllers\Api;

use App\Models\PaymentMethod;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PaymentMethodController extends BaseApiController
{
    public function index(Request $request)
    {
        $manager = $this->managerOrFail($request);
        $perPage = (int) $request->query('per_page', 50);

        $globalMethods = PaymentMethod::whereNull('manager_id')
            ->orderBy('id', 'desc')
            ->get();
        $overrides = PaymentMethod::where('manager_id', $manager->id)
            ->get()
            ->keyBy(function (PaymentMethod $method) {
                return mb_strtolower(trim($method->name)) . '|' . ($method->type ?? '');
            });

        $methods = $globalMethods
            ->map(function (PaymentMethod $method) use ($overrides) {
                $key = mb_strtolower(trim($method->name)) . '|' . ($method->type ?? '');
                return $overrides[$key] ?? $method;
            })
            ->filter(fn (PaymentMethod $method) => $method->is_active)
            ->values();

        $paginated = new \Illuminate\Pagination\LengthAwarePaginator(
            $methods->forPage(1, $perPage)->values(),
            $methods->count(),
            $perPage,
            1
        );

        return response()->json($paginated);
    }

    public function show(Request $request, int $id)
    {
        $this->managerOrFail($request);

        $method = PaymentMethod::whereNull('manager_id')->findOrFail($id);

        return response()->json($method);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        if (!$user?->is_super_admin) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('payment_methods', 'name')->whereNull('manager_id'),
            ],
            'type' => ['nullable', Rule::in(['cash', 'card', 'bank', 'other'])],
            'is_active' => ['nullable', 'boolean'],
            'is_default' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = null;
        $data['type'] = $data['type'] ?? 'cash';
        $data['is_active'] = $data['is_active'] ?? true;
        $data['is_default'] = $data['is_default'] ?? false;

        $method = PaymentMethod::create($data);

        return response()->json($method, 201);
    }

    public function update(Request $request, int $id)
    {
        $user = $request->user();
        if (!$user?->is_super_admin) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $method = PaymentMethod::whereNull('manager_id')->findOrFail($id);

        $data = $request->validate([
            'name' => [
                'sometimes',
                'string',
                'max:255',
                Rule::unique('payment_methods', 'name')->whereNull('manager_id')->ignore($method->id),
            ],
            'type' => ['sometimes', Rule::in(['cash', 'card', 'bank', 'other'])],
            'is_active' => ['nullable', 'boolean'],
            'is_default' => ['nullable', 'boolean'],
        ]);

        $method->update($data);

        return response()->json($method);
    }

    public function destroy(Request $request, int $id)
    {
        $user = $request->user();
        if (!$user?->is_super_admin) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $method = PaymentMethod::whereNull('manager_id')->findOrFail($id);
        $method->delete();

        return response()->json(['message' => 'Deleted']);
    }
}
