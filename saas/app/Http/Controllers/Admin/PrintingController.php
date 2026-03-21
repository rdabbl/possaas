<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;

class PrintingController extends Controller
{
    public function index()
    {
        return view('admin.printing.index');
    }
}
