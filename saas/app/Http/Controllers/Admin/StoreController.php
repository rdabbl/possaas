<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\Currency;
use App\Models\Store;
use App\Models\Manager;
use Illuminate\Http\Request;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class StoreController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->query('manager_id');

        $query = Store::query()->with('manager')->orderBy('id', 'desc');
        if ($managerId) {
            $query->where('manager_id', $managerId);
        }

        $stores = $query->paginate(20)->withQueryString();
        $managers = Manager::orderBy('name')->get();

        return view('admin.stores.index', compact('stores', 'managers', 'managerId'));
    }

    public function create()
    {
        $managers = Manager::orderBy('name')->get();
        $currencies = Currency::where('is_active', true)->orderBy('name')->get();

        return view('admin.stores.create', compact('managers', 'currencies'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'manager_id' => ['required', 'exists:managers,id'],
            'currency_id' => [
                'required',
                Rule::exists('currencies', 'id')->where('is_active', true),
            ],
            'name' => ['required', 'string', 'max:255'],
            'code' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('stores', 'code')->where('manager_id', $request->input('manager_id')),
            ],
            'phone' => ['nullable', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'logo' => ['nullable', 'image', 'max:4096'],
            'stock_enabled' => ['nullable', 'boolean'],
            'is_currency_right' => ['nullable', 'boolean'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $manager = Manager::findOrFail($data['manager_id']);
        if ($manager->max_stores !== null) {
            $count = Store::where('manager_id', $manager->id)->count();
            if ($count >= $manager->max_stores) {
                return back()->withErrors(['manager_id' => 'Store limit reached for this manager.'])->withInput();
            }
        }

        $data['stock_enabled'] = $data['stock_enabled'] ?? true;
        $data['is_currency_right'] = $data['is_currency_right'] ?? true;
        $data['is_active'] = $data['is_active'] ?? true;
        if ($request->hasFile('logo')) {
            $data['logo_path'] = $request->file('logo')->store('stores', 'public');
        }

        $store = Store::create($data);
        Customer::create([
            'manager_id' => $store->manager_id,
            'name' => $store->name . ' - CLIENT',
            'is_active' => true,
        ]);

        return redirect()->route('admin.stores.index')
            ->with('success', 'Store created.');
    }

    public function destroy(Store $store)
    {
        try {
            if ($store->logo_path) {
                Storage::disk('public')->delete($store->logo_path);
            }
            $store->delete();
            return redirect()->route('admin.stores.index')
                ->with('success', 'Store deleted.');
        } catch (QueryException $e) {
            return redirect()->route('admin.stores.index')
                ->with('error', 'Unable to delete store. Remove dependent records first.');
        }
    }
}
