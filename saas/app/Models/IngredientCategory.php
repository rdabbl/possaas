<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class IngredientCategory extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'tenant_id',
        'name',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function tenant()
    {
        return $this->belongsTo(Tenant::class);
    }

    public function ingredients()
    {
        return $this->hasMany(Ingredient::class);
    }
}
