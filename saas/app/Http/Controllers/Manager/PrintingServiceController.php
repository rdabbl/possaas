<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\PrintingService;
use App\Models\Store;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PrintingServiceController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->user()->manager_id;
        $storeId = $request->user()->store_id;

        $services = PrintingService::where('manager_id', $managerId)
            ->when($storeId, function ($query) use ($storeId) {
                $query->where('store_id', $storeId);
            })
            ->orderBy('sort_order')
            ->orderBy('id')
            ->paginate(20);

        $store = $storeId
            ? Store::where('manager_id', $managerId)->find($storeId)
            : null;

        return view('manager.printing_services.index', [
            'services' => $services,
            'store' => $store,
            'templates' => $this->templates(),
        ]);
    }

    public function create(Request $request)
    {
        $managerId = $request->user()->manager_id;
        $storeId = $request->user()->store_id;
        $store = $storeId
            ? Store::where('manager_id', $managerId)->find($storeId)
            : null;

        return view('manager.printing_services.create', [
            'store' => $store,
            'templates' => $this->templates(),
        ]);
    }

    public function store(Request $request)
    {
        $managerId = $request->user()->manager_id;
        $storeId = $request->user()->store_id;

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'type' => ['nullable', 'string', 'max:50'],
            'template' => ['required', Rule::in(array_keys($this->templates()))],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        if (!$storeId) {
            return redirect()->route('manager.no_store');
        }

        $data['manager_id'] = $managerId;
        $data['store_id'] = $storeId;
        $data['is_active'] = $data['is_active'] ?? true;
        $data['sort_order'] = $data['sort_order'] ?? 0;

        PrintingService::create($data);

        return redirect()->route('manager.printing_services.index')
            ->with('success', 'Service dimpression cree.');
    }

    public function edit(Request $request, PrintingService $printingService)
    {
        $managerId = $request->user()->manager_id;
        $storeId = $request->user()->store_id;

        if ($printingService->manager_id !== $managerId
            || ($storeId && $printingService->store_id !== $storeId)) {
            abort(403);
        }

        return view('manager.printing_services.edit', [
            'service' => $printingService,
            'templates' => $this->templates(),
        ]);
    }

    public function update(Request $request, PrintingService $printingService)
    {
        $managerId = $request->user()->manager_id;
        $storeId = $request->user()->store_id;

        if ($printingService->manager_id !== $managerId
            || ($storeId && $printingService->store_id !== $storeId)) {
            abort(403);
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'type' => ['nullable', 'string', 'max:50'],
            'template' => ['required', Rule::in(array_keys($this->templates()))],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['sort_order'] = $data['sort_order'] ?? 0;
        $data['is_active'] = $data['is_active'] ?? false;

        $printingService->update($data);

        return redirect()->route('manager.printing_services.index')
            ->with('success', 'Service dimpression mis a jour.');
    }

    public function destroy(Request $request, PrintingService $printingService)
    {
        $managerId = $request->user()->manager_id;
        $storeId = $request->user()->store_id;

        if ($printingService->manager_id !== $managerId
            || ($storeId && $printingService->store_id !== $storeId)) {
            abort(403);
        }

        $printingService->delete();

        return redirect()->route('manager.printing_services.index')
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
