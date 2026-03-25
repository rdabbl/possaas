<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class MediaController extends BaseApiController
{
    public function show(Request $request, string $path)
    {
        if (str_contains($path, '..')) {
            abort(400);
        }

        $disk = Storage::disk('public');
        if (!$disk->exists($path)) {
            abort(404);
        }

        $response = $disk->response($path);
        $response->headers->set('Access-Control-Allow-Origin', '*');
        $response->headers->set('Access-Control-Allow-Methods', 'GET,HEAD,OPTIONS');
        $response->headers->set('Access-Control-Allow-Headers', '*');

        return $response;
    }
}
