<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class StockMovement extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'tenant_id',
        'product_id',
        'store_id',
        'user_id',
        'quantity',
        'type',
        'reason',
        'ref_type',
        'ref_id',
        'occurred_at',
    ];

    protected $casts = [
        'quantity' => 'decimal:3',
        'occurred_at' => 'datetime',
    ];

    public function tenant()
    {
        return $this->belongsTo(Tenant::class);
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function store()
    {
        return $this->belongsTo(Store::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
