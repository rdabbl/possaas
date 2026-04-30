<?php

namespace App\Http\Controllers\Api;

use App\Models\PrintingService;
use App\Models\Store;
use Illuminate\Http\Request;

class PrintingServiceController extends BaseApiController
{
    public function index(Request $request)
    {
        $manager = $this->managerOrFail($request);
        $storeId = $request->query('store_id');

        $query = PrintingService::where('manager_id', $manager->id);

        if ($storeId) {
            $store = Store::where('manager_id', $manager->id)->find($storeId);
            if (!$store) {
                return response()->json(['message' => 'Store not found.'], 404);
            }
            $query->where('store_id', $store->id);
        }

        $services = $query
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

        return response()->json($services);
    }
}
