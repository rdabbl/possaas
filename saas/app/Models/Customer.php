<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Customer extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'manager_id',
        'name',
        'email',
        'phone',
        'address',
        'note',
        'loyalty_points_balance',
        'loyalty_points_earned_total',
        'loyalty_points_redeemed_total',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'loyalty_points_balance' => 'integer',
        'loyalty_points_earned_total' => 'integer',
        'loyalty_points_redeemed_total' => 'integer',
    ];

    public function manager()
    {
        return $this->belongsTo(Manager::class);
    }

    public function sales()
    {
        return $this->hasMany(Sale::class);
    }
}
