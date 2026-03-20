<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Store extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'tenant_id',
        'currency_id',
        'name',
        'code',
        'phone',
        'email',
        'address',
        'logo_path',
        'stock_enabled',
        'is_currency_right',
        'is_active',
    ];

    protected $casts = [
        'stock_enabled' => 'boolean',
        'is_currency_right' => 'boolean',
        'is_active' => 'boolean',
    ];

    public function tenant()
    {
        return $this->belongsTo(Tenant::class);
    }

    public function currency()
    {
        return $this->belongsTo(Currency::class);
    }

    public function devices()
    {
        return $this->hasMany(Device::class);
    }

    public function sales()
    {
        return $this->hasMany(Sale::class);
    }
}
