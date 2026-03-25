<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureManagerStoreAssigned
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user || !$user->manager_id) {
            abort(403);
        }

        $routeName = $request->route()?->getName();
        $allowedWithoutStore = [
            'manager.no_store',
            'manager.stores.index',
            'manager.stores.create',
            'manager.stores.store',
        ];
        if (!$user->store_id && !in_array($routeName, $allowedWithoutStore, true)) {
            return redirect()->route('manager.no_store');
        }

        return $next($request);
    }
}
