<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\Manager;
use Illuminate\Http\Request;

class LoyaltyController extends Controller
{
    public function edit(Request $request)
    {
        $managerId = $request->user()->manager_id;
        $manager = Manager::findOrFail($managerId);

        return view('manager.loyalty.edit', compact('manager'));
    }

    public function update(Request $request)
    {
        $managerId = $request->user()->manager_id;
        $manager = Manager::findOrFail($managerId);

        $data = $request->validate([
            'loyalty_enabled' => ['nullable', 'boolean'],
            'loyalty_points_per_order' => ['nullable', 'integer', 'min:0'],
            'loyalty_points_per_item' => ['nullable', 'integer', 'min:0'],
            'loyalty_amount_per_point' => ['nullable', 'numeric', 'min:0'],
            'loyalty_point_value' => ['nullable', 'numeric', 'min:0'],
        ]);

        $data['loyalty_enabled'] = $data['loyalty_enabled'] ?? false;
        $data['loyalty_points_per_order'] = $data['loyalty_points_per_order'] ?? 0;
        $data['loyalty_points_per_item'] = $data['loyalty_points_per_item'] ?? 0;
        $data['loyalty_amount_per_point'] = $data['loyalty_amount_per_point'] ?? 0;
        $data['loyalty_point_value'] = $data['loyalty_point_value'] ?? 0;

        $manager->update($data);

        return redirect()->route('manager.loyalty.edit')
            ->with('success', 'Loyalty settings updated.');
    }
}
