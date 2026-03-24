<?php

namespace App\Http\Controllers\Api;

use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends BaseApiController
{
    public function index(Request $request)
    {
        $manager = $this->managerOrFail($request);
        $perPage = (int) $request->query('per_page', 50);

        $categories = Category::where(function ($query) use ($manager) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $manager->id);
        })
            ->orderBy('id', 'desc')
            ->paginate($perPage);

        return response()->json($categories);
    }

    public function show(Request $request, int $id)
    {
        $manager = $this->managerOrFail($request);

        $category = Category::where(function ($query) use ($manager) {
            $query->whereNull('manager_id')
                ->orWhere('manager_id', $manager->id);
        })->findOrFail($id);

        return response()->json($category);
    }
}
