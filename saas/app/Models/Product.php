<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Product extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'tenant_id',
        'category_id',
        'tax_id',
        'uuid',
        'name',
        'sku',
        'barcode',
        'description',
        'ingredients',
        'image_path',
        'image_url',
        'price',
        'cost',
        'track_stock',
        'is_active',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'cost' => 'decimal:2',
        'track_stock' => 'boolean',
        'is_active' => 'boolean',
    ];

    public function tenant()
    {
        return $this->belongsTo(Tenant::class);
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function tax()
    {
        return $this->belongsTo(Tax::class);
    }

    public function variants()
    {
        return $this->hasMany(ProductVariant::class);
    }

    public function stockMovements()
    {
        return $this->hasMany(StockMovement::class);
    }

    public function ingredientLinks()
    {
        return $this->belongsToMany(Ingredient::class)
            ->withPivot('quantity')
            ->withTimestamps();
    }

    public function getImageUrlAttribute($value)
    {
        $raw = $value ?: ($this->attributes['image_url'] ?? null);
        if ($raw) {
            if (Str::startsWith($raw, ['http://', 'https://'])) {
                return $raw;
            }
            if (Str::startsWith($raw, '/')) {
                return url($raw);
            }
            return url('storage/' . ltrim($raw, '/'));
        }

        if ($this->image_path) {
            return asset('storage/' . $this->image_path);
        }

        return null;
    }
}
