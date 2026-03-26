<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Subscription extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'manager_id',
        'plan_id',
        'starts_at',
        'ends_at',
        'status',
        'device_limit',
        'notes',
    ];

    protected $casts = [
        'starts_at' => 'datetime',
        'ends_at' => 'datetime',
        'device_limit' => 'integer',
    ];

    public function manager()
    {
        return $this->belongsTo(Manager::class);
    }

    public function plan()
    {
        return $this->belongsTo(Plan::class);
    }
}
