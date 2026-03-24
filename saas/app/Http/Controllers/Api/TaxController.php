<?php

namespace App\Http\Controllers\Api;

use App\Models\Tax;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class TaxController extends BaseApiController
{
    public function index(Request $request)
    {
        $manager = $this->managerOrFail($request);
        $perPage = (int) $request->query('per_page', 50);

        $taxes = Tax::where(function ($query) use ($manager) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $manager->id);
        })
            ->orderBy('id', 'desc')
            ->paginate($perPage);

        return response()->json($taxes);
    }

    public function show(Request $request, int $id)
    {
        $manager = $this->managerOrFail($request);

        $tax = Tax::where(function ($query) use ($manager) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $manager->id);
        })->findOrFail($id);

        return response()->json($tax);
    }

    public function store(Request $request)
    {
        $manager = $this->managerOrFail($request);

        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('taxes', 'name')->where('manager_id', $manager->id),
            ],
            'rate' => ['required', 'numeric', 'min:0'],
            'type' => ['required', Rule::in(['percent', 'fixed'])],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = $manager->id;
        $data['is_active'] = $data['is_active'] ?? true;

        $tax = Tax::create($data);

        return response()->json($tax, 201);
    }

    public function update(Request $request, int $id)
    {
        $manager = $this->managerOrFail($request);

        $tax = Tax::where('manager_id', $manager->id)->findOrFail($id);

        $data = $request->validate([
            'name' => [
                'sometimes',
                'string',
                'max:255',
                Rule::unique('taxes', 'name')->where('manager_id', $manager->id)->ignore($tax->id),
            ],
            'rate' => ['sometimes', 'numeric', 'min:0'],
            'type' => ['sometimes', Rule::in(['percent', 'fixed'])],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $tax->update($data);

        return response()->json($tax);
    }

    public function destroy(Request $request, int $id)
    {
        $manager = $this->managerOrFail($request);

        $tax = Tax::where('manager_id', $manager->id)->findOrFail($id);
        $tax->delete();

        return response()->json(['message' => 'Deleted']);
    }
}
