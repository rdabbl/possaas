<?php

namespace App\Http\Controllers\Api;

use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends BaseApiController
{
    public function index(Request $request)
    {
        $tenant = $this->tenantOrFail($request);
        $perPage = (int) $request->query('per_page', 50);

        $categories = Category::where('tenant_id', $tenant->id)
            ->orderBy('id', 'desc')
            ->paginate($perPage);

        return response()->json($categories);
    }

    public function show(Request $request, int $id)
    {
        $tenant = $this->tenantOrFail($request);

        $category = Category::where('tenant_id', $tenant->id)->findOrFail($id);

        return response()->json($category);
    }
}
