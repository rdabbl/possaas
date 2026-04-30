<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class PrintingService extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'manager_id',
        'store_id',
        'name',
        'type',
        'template',
        'settings',
        'sort_order',
        'is_active',
    ];

    protected $casts = [
        'settings' => 'array',
        'sort_order' => 'integer',
        'is_active' => 'boolean',
    ];

    public function manager()
    {
        return $this->belongsTo(Manager::class);
    }

    public function store()
    {
        return $this->belongsTo(Store::class);
    }
}
