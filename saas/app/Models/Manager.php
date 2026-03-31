<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Manager extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'name',
        'username',
        'slug',
        'is_active',
        'max_stores',
        'max_devices',
        'currency',
        'timezone',
        'plan_name',
        'plan_id',
        'loyalty_enabled',
        'loyalty_points_per_order',
        'loyalty_points_per_item',
        'loyalty_amount_per_point',
        'loyalty_point_value',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'max_stores' => 'integer',
        'max_devices' => 'integer',
        'plan_id' => 'integer',
        'loyalty_enabled' => 'boolean',
        'loyalty_points_per_order' => 'integer',
        'loyalty_points_per_item' => 'integer',
        'loyalty_amount_per_point' => 'decimal:2',
        'loyalty_point_value' => 'decimal:2',
    ];

    public function plan()
    {
        return $this->belongsTo(Plan::class);
    }

    public function stores()
    {
        return $this->hasMany(Store::class);
    }

    public function devices()
    {
        return $this->hasMany(Device::class);
    }

    public function users()
    {
        return $this->hasMany(User::class);
    }

    public function products()
    {
        return $this->hasMany(Product::class);
    }

    public function customers()
    {
        return $this->hasMany(Customer::class);
    }

    public function sales()
    {
        return $this->hasMany(Sale::class);
    }

    public function paymentMethods()
    {
        return $this->hasMany(PaymentMethod::class);
    }

    public function taxes()
    {
        return $this->hasMany(Tax::class);
    }

    public function discounts()
    {
        return $this->hasMany(Discount::class);
    }

    public function subscriptions()
    {
        return $this->hasMany(Subscription::class);
    }

    public function latestSubscription()
    {
        return $this->hasOne(Subscription::class)->latestOfMany('ends_at');
    }
}
