<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\PaymentMethod;
use Illuminate\Http\Request;

class PaymentMethodController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $globalMethods = PaymentMethod::whereNull('manager_id')
            ->orderBy('name')
            ->get();

        $overrides = PaymentMethod::where('manager_id', $managerId)
            ->get()
            ->keyBy(function (PaymentMethod $method) {
                return mb_strtolower(trim($method->name)) . '|' . ($method->type ?? '');
            });

        return view('manager.payment_methods.index', compact('globalMethods', 'overrides'));
    }

    public function update(Request $request, int $paymentMethod)
    {
        $managerId = $request->user()->manager_id;
        $global = PaymentMethod::whereNull('manager_id')->findOrFail($paymentMethod);

        $data = $request->validate([
            'is_active' => ['required', 'boolean'],
            'is_default' => ['required', 'boolean'],
        ]);

        $keyName = trim($global->name);
        $keyType = $global->type;

        $override = PaymentMethod::where('manager_id', $managerId)
            ->whereRaw('LOWER(name) = ?', [mb_strtolower($keyName)])
            ->where('type', $keyType)
            ->first();

        if (!$override) {
            $override = new PaymentMethod();
            $override->manager_id = $managerId;
            $override->name = $global->name;
            $override->type = $global->type;
        }

        $override->is_active = (bool) $data['is_active'];
        $override->is_default = (bool) $data['is_default'] && (bool) $data['is_active'];
        $override->save();

        if ($override->is_default) {
            PaymentMethod::where('manager_id', $managerId)
                ->where('id', '!=', $override->id)
                ->update(['is_default' => false]);
        }

        return redirect()
            ->route('manager.payment_methods.index')
            ->with('success', t('Payment methods updated.'));
    }
}
