<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Currency;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class CurrencyController extends Controller
{
    public function index()
    {
        $currencies = Currency::orderBy('name')->paginate(20);

        return view('admin.currencies.index', compact('currencies'));
    }

    public function create()
    {
        return view('admin.currencies.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'code' => ['required', 'string', 'size:3', 'unique:currencies,code'],
            'symbol' => ['required', 'string', 'max:16'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['code'] = strtoupper($data['code']);
        $data['is_active'] = $data['is_active'] ?? true;

        Currency::create($data);

        return redirect()->route('admin.currencies.index')
            ->with('success', 'Currency created.');
    }

    public function edit(Currency $currency)
    {
        return view('admin.currencies.edit', compact('currency'));
    }

    public function update(Request $request, Currency $currency)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'code' => [
                'required',
                'string',
                'size:3',
                Rule::unique('currencies', 'code')->ignore($currency->id),
            ],
            'symbol' => ['required', 'string', 'max:16'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['code'] = strtoupper($data['code']);
        $data['is_active'] = $data['is_active'] ?? $currency->is_active;

        $currency->update($data);

        return redirect()->route('admin.currencies.index')
            ->with('success', 'Currency updated.');
    }
}
