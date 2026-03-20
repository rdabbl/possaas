<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DeviceSyncLog extends Model
{
    protected $fillable = [
        'device_id',
        'direction',
        'status',
        'payload_hash',
        'error_message',
        'synced_at',
    ];

    protected $casts = [
        'synced_at' => 'datetime',
    ];

    public function device()
    {
        return $this->belongsTo(Device::class);
    }
}
