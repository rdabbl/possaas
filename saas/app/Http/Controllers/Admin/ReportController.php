<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Sale;
use App\Models\SaleItem;
use App\Models\Manager;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->query('manager_id');
        $from = $request->query('from', now()->subDays(30)->toDateString());
        $to = $request->query('to', now()->toDateString());

        $salesQuery = Sale::query()
            ->whereBetween('ordered_at', [
                $from . ' 00:00:00',
                $to . ' 23:59:59',
            ])
            ->whereIn('status', ['paid', 'partial']);

        if ($managerId) {
            $salesQuery->where('manager_id', $managerId);
        }

        $daily = (clone $salesQuery)
            ->select(DB::raw('DATE(ordered_at) as day'), DB::raw('COUNT(*) as count'), DB::raw('SUM(grand_total) as total'))
            ->groupBy(DB::raw('DATE(ordered_at)'))
            ->orderBy('day')
            ->get();

        $monthly = (clone $salesQuery)
            ->select(DB::raw('DATE_FORMAT(ordered_at, "%Y-%m") as month'), DB::raw('COUNT(*) as count'), DB::raw('SUM(grand_total) as total'))
            ->groupBy(DB::raw('DATE_FORMAT(ordered_at, "%Y-%m")'))
            ->orderBy('month')
            ->get();

        $saleIds = (clone $salesQuery)->pluck('id');

        $topProducts = SaleItem::query()
            ->select('name', DB::raw('SUM(quantity) as qty'), DB::raw('SUM(total) as total'))
            ->whereIn('sale_id', $saleIds)
            ->groupBy('name')
            ->orderByDesc('total')
            ->limit(10)
            ->get();

        $managers = Manager::orderBy('name')->get();

        return view('admin.reports.index', compact('daily', 'monthly', 'topProducts', 'managers', 'managerId', 'from', 'to'));
    }
}
