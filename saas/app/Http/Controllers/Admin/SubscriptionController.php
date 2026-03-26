<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Manager;
use App\Models\Plan;
use App\Models\Subscription;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class SubscriptionController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->query('manager_id');
        $status = $request->query('status');

        $query = Subscription::query()
            ->with(['manager' => function ($query) {
                $query->withCount('devices');
            }, 'plan'])
            ->orderBy('id', 'desc');

        if ($managerId) {
            $query->where('manager_id', $managerId);
        }
        if ($status) {
            $query->where('status', $status);
        }

        $subscriptions = $query->paginate(20)->withQueryString();
        $managers = Manager::orderBy('name')->get();

        return view('admin.subscriptions.index', compact('subscriptions', 'managers', 'managerId', 'status'));
    }

    public function create()
    {
        $managers = Manager::orderBy('name')->get();
        $plans = Plan::orderBy('name')->get();

        return view('admin.subscriptions.create', compact('managers', 'plans'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'manager_id' => ['required', 'exists:managers,id'],
            'plan_id' => ['nullable', 'exists:plans,id'],
            'starts_at' => ['nullable', 'date'],
            'ends_at' => ['nullable', 'date', 'after_or_equal:starts_at'],
            'status' => ['required', 'string', 'max:20'],
            'device_limit' => ['nullable', 'integer', 'min:0'],
            'notes' => ['nullable', 'string'],
        ]);

        $plan = null;
        if (!empty($data['plan_id'])) {
            $plan = Plan::find($data['plan_id']);
        }

        if (empty($data['starts_at'])) {
            $data['starts_at'] = now();
        } else {
            $data['starts_at'] = Carbon::parse($data['starts_at']);
        }

        if (empty($data['ends_at']) && $plan && $plan->duration_days) {
            $data['ends_at'] = Carbon::parse($data['starts_at'])->copy()->addDays($plan->duration_days);
        }

        if (!array_key_exists('device_limit', $data) || is_null($data['device_limit'])) {
            $data['device_limit'] = $plan?->max_devices;
        }

        $subscription = Subscription::create($data);

        $this->syncManagerPlan($subscription);

        return redirect()->route('admin.subscriptions.index')
            ->with('success', 'Subscription created.');
    }

    public function edit(Subscription $subscription)
    {
        $managers = Manager::orderBy('name')->get();
        $plans = Plan::orderBy('name')->get();

        return view('admin.subscriptions.edit', compact('subscription', 'managers', 'plans'));
    }

    public function update(Request $request, Subscription $subscription)
    {
        $data = $request->validate([
            'manager_id' => ['required', 'exists:managers,id'],
            'plan_id' => ['nullable', 'exists:plans,id'],
            'starts_at' => ['nullable', 'date'],
            'ends_at' => ['nullable', 'date', 'after_or_equal:starts_at'],
            'status' => ['required', 'string', 'max:20'],
            'device_limit' => ['nullable', 'integer', 'min:0'],
            'notes' => ['nullable', 'string'],
        ]);

        $plan = null;
        if (!empty($data['plan_id'])) {
            $plan = Plan::find($data['plan_id']);
        }

        if (empty($data['starts_at'])) {
            $data['starts_at'] = $subscription->starts_at ?? now();
        } else {
            $data['starts_at'] = Carbon::parse($data['starts_at']);
        }

        if (empty($data['ends_at']) && $plan && $plan->duration_days) {
            $data['ends_at'] = Carbon::parse($data['starts_at'])->copy()->addDays($plan->duration_days);
        }

        if (!array_key_exists('device_limit', $data) || is_null($data['device_limit'])) {
            $data['device_limit'] = $plan?->max_devices;
        }

        $subscription->update($data);

        $this->syncManagerPlan($subscription->fresh());

        return redirect()->route('admin.subscriptions.index')
            ->with('success', 'Subscription updated.');
    }

    private function syncManagerPlan(Subscription $subscription): void
    {
        $manager = $subscription->manager;
        if (!$manager) {
            return;
        }

        if ($subscription->plan) {
            $manager->plan_id = $subscription->plan->id;
            $manager->plan_name = $subscription->plan->name;
            $manager->max_stores = $subscription->plan->max_stores;
            $manager->max_devices = $subscription->plan->max_devices;
        } else {
            $manager->plan_id = null;
            $manager->plan_name = null;
            $manager->max_stores = null;
            $manager->max_devices = null;
        }

        $manager->save();
    }
}
