<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Plan extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'name',
        'duration_days',
        'max_stores',
        'max_devices',
        'is_active',
    ];

    protected $casts = [
        'duration_days' => 'integer',
        'max_stores' => 'integer',
        'max_devices' => 'integer',
        'is_active' => 'boolean',
    ];

    public function managers()
    {
        return $this->hasMany(Manager::class);
    }
}
