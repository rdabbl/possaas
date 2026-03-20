<?php

namespace App\Http\Controllers\Api;

use App\Models\Currency;
use App\Models\Store;
use App\Models\Tenant;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends BaseApiController
{
    public function login(Request $request)
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = User::where('email', $data['email'])->first();

        if (!$user || !Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        if (!$user->is_active) {
            return response()->json(['message' => 'User is inactive.'], 403);
        }

        $token = $user->createToken('flutter')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'tenant_id' => $user->tenant_id,
                'store_id' => $user->store_id,
                'is_super_admin' => $user->is_super_admin,
            ],
        ]);
    }

    public function me(Request $request)
    {
        $user = $request->user();
        $store = null;
        $tenant = null;

        if ($user->store_id) {
            $store = Store::with('currency')->find($user->store_id);
        }

        if ($user->tenant_id) {
            $tenant = Tenant::find($user->tenant_id);
        }

        $currency = $store?->currency;
        if (!$currency && $tenant?->currency) {
            $currency = Currency::where('code', strtoupper($tenant->currency))
                ->where('is_active', true)
                ->first();
        }

        $payload = $user->toArray();
        $payload['currency'] = $currency?->id;
        $payload['currency_code'] = $currency?->code ?? $tenant?->currency ?? 'USD';
        $payload['currency_symbol'] = $currency?->symbol ?? ($tenant?->currency ?? 'USD');
        $payload['is_currency_right'] = $store?->is_currency_right ?? true;
        $payload['company_name'] = $tenant?->name ?? $payload['company_name'] ?? '';
        $payload['address'] = $store?->address ?? $payload['address'] ?? null;
        $payload['email'] = $store?->email ?? $payload['email'] ?? $user->email;
        $payload['phone'] = $store?->phone ?? $payload['phone'] ?? null;
        $logoUrl = $store?->logo_path ? asset('storage/' . $store->logo_path) : null;
        $payload['logo_url'] = $logoUrl;
        $payload['logo'] = $payload['logo'] ?? $logoUrl;

        return response()->json($payload);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logged out']);
    }
}
