<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class ProductOptionCategory extends Model
{
    use SoftDeletes;

    protected $table = 'product_option_categories';

    protected $fillable = [
        'manager_id',
        'name',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function manager()
    {
        return $this->belongsTo(Manager::class);
    }

    public function options()
    {
        return $this->hasMany(ProductOption::class, 'product_option_category_id');
    }
}
