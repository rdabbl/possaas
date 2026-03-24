<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\Currency;
use App\Models\Store;
use App\Models\Manager;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class StoreController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $stores = Store::where('manager_id', $managerId)
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('manager.stores.index', compact('stores'));
    }

    public function create()
    {
        $currencies = Currency::where('is_active', true)->orderBy('name')->get();

        return view('manager.stores.create', compact('currencies'));
    }

    public function store(Request $request)
    {
        $manager = Manager::findOrFail($request->user()->manager_id);

        if ($manager->max_stores !== null) {
            $count = Store::where('manager_id', $manager->id)->count();
            if ($count >= $manager->max_stores) {
                return back()->withErrors(['name' => 'Store limit reached for this manager.'])->withInput();
            }
        }

        $data = $request->validate([
            'currency_id' => [
                'required',
                Rule::exists('currencies', 'id')->where('is_active', true),
            ],
            'name' => ['required', 'string', 'max:255'],
            'code' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('stores', 'code')->where('manager_id', $manager->id),
            ],
            'phone' => ['nullable', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'logo' => ['nullable', 'image', 'max:4096'],
            'stock_enabled' => ['nullable', 'boolean'],
            'is_currency_right' => ['nullable', 'boolean'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['manager_id'] = $manager->id;
        $data['stock_enabled'] = $data['stock_enabled'] ?? true;
        $data['is_currency_right'] = $data['is_currency_right'] ?? true;
        $data['is_active'] = $data['is_active'] ?? true;
        if ($request->hasFile('logo')) {
            $data['logo_path'] = $request->file('logo')->store('stores', 'public');
        }

        Store::create($data);

        return redirect()->route('manager.stores.index')
            ->with('success', 'Store created.');
    }

    public function edit(Request $request, Store $store)
    {
        if ($store->manager_id !== $request->user()->manager_id) {
            abort(403);
        }

        $currencies = Currency::where('is_active', true)->orderBy('name')->get();

        return view('manager.stores.edit', compact('store', 'currencies'));
    }

    public function update(Request $request, Store $store)
    {
        $managerId = $request->user()->manager_id;

        if ($store->manager_id !== $managerId) {
            abort(403);
        }

        $data = $request->validate([
            'currency_id' => [
                'required',
                Rule::exists('currencies', 'id')->where('is_active', true),
            ],
            'name' => ['required', 'string', 'max:255'],
            'code' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('stores', 'code')->where('manager_id', $managerId)->ignore($store->id),
            ],
            'phone' => ['nullable', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'logo' => ['nullable', 'image', 'max:4096'],
            'stock_enabled' => ['nullable', 'boolean'],
            'is_currency_right' => ['nullable', 'boolean'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        if ($request->hasFile('logo')) {
            if ($store->logo_path) {
                Storage::disk('public')->delete($store->logo_path);
            }
            $data['logo_path'] = $request->file('logo')->store('stores', 'public');
        }

        $store->update($data);

        return redirect()->route('manager.stores.index')
            ->with('success', 'Store updated.');
    }
}
