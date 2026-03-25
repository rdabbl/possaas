<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class ProductOption extends Model
{
    use SoftDeletes;

    protected $table = 'product_options';

    protected $fillable = [
        'manager_id',
        'product_option_category_id',
        'name',
        'image_path',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'product_option_category_id' => 'integer',
    ];

    public function manager()
    {
        return $this->belongsTo(Manager::class);
    }

    public function category()
    {
        return $this->belongsTo(ProductOptionCategory::class, 'product_option_category_id');
    }

    public function products()
    {
        return $this->belongsToMany(Product::class, 'product_option_product')
            ->withPivot('quantity')
            ->withTimestamps();
    }
}
