<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Device extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'manager_id',
        'store_id',
        'uuid',
        'name',
        'type',
        'platform',
        'secret',
        'last_seen_at',
        'last_sync_at',
        'is_active',
    ];

    protected $casts = [
        'last_seen_at' => 'datetime',
        'last_sync_at' => 'datetime',
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

    public function syncLogs()
    {
        return $this->hasMany(DeviceSyncLog::class);
    }
}
