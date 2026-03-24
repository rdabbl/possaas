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
        if (!$user->store_id && $routeName !== 'manager.no_store') {
            return redirect()->route('manager.no_store');
        }

        return $next($request);
    }
}
