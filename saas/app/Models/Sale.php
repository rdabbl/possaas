<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Sale extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'manager_id',
        'store_id',
        'device_id',
        'user_id',
        'customer_id',
        'number',
        'status',
        'subtotal',
        'discount_total',
        'tax_total',
        'grand_total',
        'currency',
        'note',
        'ordered_at',
    ];

    protected $casts = [
        'subtotal' => 'decimal:2',
        'discount_total' => 'decimal:2',
        'tax_total' => 'decimal:2',
        'grand_total' => 'decimal:2',
        'ordered_at' => 'datetime',
    ];

    public function manager()
    {
        return $this->belongsTo(Manager::class);
    }

    public function store()
    {
        return $this->belongsTo(Store::class);
    }

    public function device()
    {
        return $this->belongsTo(Device::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }

    public function items()
    {
        return $this->hasMany(SaleItem::class);
    }

    public function payments()
    {
        return $this->hasMany(Payment::class);
    }
}
