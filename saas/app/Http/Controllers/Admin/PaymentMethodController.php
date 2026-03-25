<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\PaymentMethod;
use App\Models\Manager;
use Illuminate\Http\Request;
use Illuminate\Database\QueryException;
use Illuminate\Validation\Rule;

class PaymentMethodController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->query('manager_id');

        $query = PaymentMethod::query()->with('manager')->orderBy('id', 'desc');
        if ($managerId) {
            $query->where('manager_id', $managerId);
        }

        $methods = $query->paginate(20)->withQueryString();
        $managers = Manager::orderBy('name')->get();

        return view('admin.payment_methods.index', compact('methods', 'managers', 'managerId'));
    }

    public function create()
    {
        return view('admin.payment_methods.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('payment_methods', 'name')->whereNull('manager_id'),
            ],
            'type' => ['nullable', Rule::in(['cash', 'card', 'bank', 'other'])],
            'is_active' => ['nullable', 'boolean'],
            'is_default' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = null;
        $data['type'] = $data['type'] ?? 'cash';
        $data['is_active'] = $data['is_active'] ?? true;
        $data['is_default'] = $data['is_default'] ?? false;

        PaymentMethod::create($data);

        return redirect()->route('admin.payment_methods.index')
            ->with('success', 'Payment method created.');
    }

    public function destroy(PaymentMethod $paymentMethod)
    {
        try {
            $paymentMethod->delete();
            return redirect()->route('admin.payment_methods.index')
                ->with('success', 'Payment method deleted.');
        } catch (QueryException $e) {
            return redirect()->route('admin.payment_methods.index')
                ->with('error', 'Unable to delete payment method. Remove dependent records first.');
        }
    }
}
