<?php

namespace App\Http\Controllers\Api;

use App\Models\Currency;
use App\Models\Store;
use App\Models\Manager;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends BaseApiController
{
    public function login(Request $request)
    {
        $data = $request->validate([
            'username' => ['required', 'string'],
            'pin' => ['nullable', 'digits:4', 'required_without:password'],
            'password' => ['nullable', 'string', 'required_without:pin'],
        ]);

        $user = User::where('username', $data['username'])->first();

        $pin = $data['pin'] ?? null;
        $password = $data['password'] ?? null;
        $isValid = false;

        if ($user && $pin) {
            $isValid = !empty($user->pin) && Hash::check($pin, $user->pin);
        } elseif ($user && $password) {
            // Backward compatibility for older POS clients.
            $isValid = Hash::check($password, $user->password);
        }

        if (!$user || !$isValid) {
            throw ValidationException::withMessages([
                'username' => ['The provided credentials are incorrect.'],
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
                'username' => $user->username,
                'email' => $user->email,
                'manager_id' => $user->manager_id,
                'store_id' => $user->store_id,
                'is_super_admin' => $user->is_super_admin,
            ],
        ]);
    }

    public function me(Request $request)
    {
        $user = $request->user();
        $store = null;
        $manager = null;

        if ($user->store_id) {
            $store = Store::with('currency')->find($user->store_id);
        }

        if ($user->manager_id) {
            $manager = Manager::find($user->manager_id);
        }

        $currency = $store?->currency;
        if (!$currency && $manager?->currency) {
            $currency = Currency::where('code', strtoupper($manager->currency))
                ->where('is_active', true)
                ->first();
        }

        $payload = $user->toArray();
        $payload['username'] = $user->username;
        $payload['currency'] = $currency?->id;
        $payload['currency_code'] = $currency?->code ?? $manager?->currency ?? 'USD';
        $payload['currency_symbol'] = $currency?->symbol ?? ($manager?->currency ?? 'USD');
        $payload['is_currency_right'] = $store?->is_currency_right ?? true;
        $payload['company_name'] = $manager?->name ?? $payload['company_name'] ?? '';
        $payload['address'] = $store?->address ?? $payload['address'] ?? null;
        $payload['email'] = $store?->email ?? $payload['email'] ?? $user->email;
        $payload['phone'] = $store?->phone ?? $payload['phone'] ?? null;
        $logoUrl = $store?->logo_path ? asset('storage/' . $store->logo_path) : null;
        $payload['logo_url'] = $logoUrl;
        $payload['logo'] = $payload['logo'] ?? $logoUrl;
        $payload['allow_loyalty_redeem'] = $user?->allow_loyalty_redeem
            ?? $store?->allow_loyalty_redeem
            ?? true;
        if ($manager) {
            $payload['loyalty_enabled'] = $manager->loyalty_enabled ?? false;
            $payload['loyalty_points_per_order'] = $manager->loyalty_points_per_order ?? 0;
            $payload['loyalty_points_per_item'] = $manager->loyalty_points_per_item ?? 0;
            $payload['loyalty_amount_per_point'] = $manager->loyalty_amount_per_point ?? 0;
            $payload['loyalty_point_value'] = $manager->loyalty_point_value ?? 0;
        }

        return response()->json($payload);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logged out']);
    }
}
