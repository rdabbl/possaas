<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Manager;
use App\Models\PrintingService;
use App\Models\Store;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PrintingServiceController extends Controller
{
    public function index(Request $request)
    {
        $query = PrintingService::query()
            ->with(['manager', 'store'])
            ->orderBy('sort_order')
            ->orderBy('id');

        if ($request->filled('manager_id')) {
            $query->where('manager_id', (int) $request->integer('manager_id'));
        }

        if ($request->filled('store_id')) {
            $query->where('store_id', (int) $request->integer('store_id'));
        }

        return view('admin.printing_services.index', [
            'services' => $query->paginate(30)->withQueryString(),
            'managers' => Manager::orderBy('name')->get(['id', 'name']),
            'stores' => Store::orderBy('name')->get(['id', 'name', 'manager_id']),
            'templates' => $this->templates(),
        ]);
    }

    public function create()
    {
        return view('admin.printing_services.create', [
            'managers' => Manager::orderBy('name')->get(['id', 'name']),
            'stores' => Store::orderBy('name')->get(['id', 'name', 'manager_id']),
            'templates' => $this->templates(),
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'manager_id' => ['required', 'integer', 'exists:managers,id'],
            'store_id' => ['required', 'integer', 'exists:stores,id'],
            'name' => ['required', 'string', 'max:255'],
            'type' => ['nullable', 'string', 'max:50'],
            'template' => ['required', Rule::in(array_keys($this->templates()))],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['sort_order'] = $data['sort_order'] ?? 0;
        $data['is_active'] = $data['is_active'] ?? true;

        PrintingService::create($data);

        return redirect()->route('admin.printing_services.index')
            ->with('success', 'Service dimpression cree.');
    }

    public function edit(PrintingService $printingService)
    {
        return view('admin.printing_services.edit', [
            'service' => $printingService,
            'managers' => Manager::orderBy('name')->get(['id', 'name']),
            'stores' => Store::orderBy('name')->get(['id', 'name', 'manager_id']),
            'templates' => $this->templates(),
        ]);
    }

    public function update(Request $request, PrintingService $printingService)
    {
        $data = $request->validate([
            'manager_id' => ['required', 'integer', 'exists:managers,id'],
            'store_id' => ['required', 'integer', 'exists:stores,id'],
            'name' => ['required', 'string', 'max:255'],
            'type' => ['nullable', 'string', 'max:50'],
            'template' => ['required', Rule::in(array_keys($this->templates()))],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['sort_order'] = $data['sort_order'] ?? 0;
        $data['is_active'] = $data['is_active'] ?? false;

        $printingService->update($data);

        return redirect()->route('admin.printing_services.index')
            ->with('success', 'Service dimpression mis a jour.');
    }

    public function destroy(PrintingService $printingService)
    {
        $printingService->delete();

        return redirect()->route('admin.printing_services.index')
            ->with('success', 'Service dimpression supprime.');
    }

    private function templates(): array
    {
        return [
            'receipt' => 'Ticket de vente',
            'kitchen' => 'Ticket cuisine',
            'kiosk' => 'Ticket borne',
        ];
    }
}
