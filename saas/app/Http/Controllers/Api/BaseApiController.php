<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Tenant;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\Request;

class BaseApiController extends Controller
{
    protected function tenantOrFail(Request $request): Tenant
    {
        $user = $request->user();
        $tenantId = $request->header('X-Tenant-ID') ?? $request->input('tenant_id');

        if ($user && !$user->is_super_admin) {
            if (!$user->tenant_id) {
                throw new HttpResponseException(
                    response()->json(['message' => 'User has no tenant assigned.'], 403)
                );
            }

            if ($tenantId && (int) $tenantId !== (int) $user->tenant_id) {
                throw new HttpResponseException(
                    response()->json(['message' => 'Tenant mismatch.'], 403)
                );
            }

            $tenantId = $user->tenant_id;
        }

        if (!$tenantId) {
            throw new HttpResponseException(
                response()->json(['message' => 'X-Tenant-ID header is required.'], 422)
            );
        }

        $tenant = Tenant::where('id', $tenantId)
            ->where('is_active', true)
            ->first();

        if (!$tenant) {
            throw new HttpResponseException(
                response()->json(['message' => 'Tenant not found or inactive.'], 404)
            );
        }

        return $tenant;
    }
}
