<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Manager;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\Request;

class BaseApiController extends Controller
{
    protected function managerOrFail(Request $request): Manager
    {
        $user = $request->user();
        $managerId = $request->header('X-Manager-ID') ?? $request->input('manager_id');

        if ($user && !$user->is_super_admin) {
            if (!$user->manager_id) {
                throw new HttpResponseException(
                    response()->json(['message' => 'User has no manager assigned.'], 403)
                );
            }

            if ($managerId && (int) $managerId !== (int) $user->manager_id) {
                throw new HttpResponseException(
                    response()->json(['message' => 'Manager mismatch.'], 403)
                );
            }

            $managerId = $user->manager_id;
        }

        if (!$managerId) {
            throw new HttpResponseException(
                response()->json(['message' => 'X-Manager-ID header is required.'], 422)
            );
        }

        $manager = Manager::where('id', $managerId)
            ->where('is_active', true)
            ->first();

        if (!$manager) {
            throw new HttpResponseException(
                response()->json(['message' => 'Manager not found or inactive.'], 404)
            );
        }

        return $manager;
    }
}
