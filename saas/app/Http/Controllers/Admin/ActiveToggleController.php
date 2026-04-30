<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Currency;
use App\Models\Customer;
use App\Models\Discount;
use App\Models\Language;
use App\Models\Manager;
use App\Models\PaymentMethod;
use App\Models\Plan;
use App\Models\Product;
use App\Models\ProductOption;
use App\Models\ProductOptionCategory;
use App\Models\ShippingMethod;
use App\Models\Store;
use App\Models\Tax;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class ActiveToggleController extends Controller
{
    public function update(Request $request, string $type, int $id): RedirectResponse
    {
        $map = [
            'managers' => Manager::class,
            'plans' => Plan::class,
            'stores' => Store::class,
            'payment_methods' => PaymentMethod::class,
            'currencies' => Currency::class,
            'categories' => Category::class,
            'product_option_categories' => ProductOptionCategory::class,
            'product_options' => ProductOption::class,
            'products' => Product::class,
            'customers' => Customer::class,
            'taxes' => Tax::class,
            'discounts' => Discount::class,
            'shipping_methods' => ShippingMethod::class,
            'languages' => Language::class,
        ];

        if (!array_key_exists($type, $map)) {
            abort(404);
        }

        $modelClass = $map[$type];
        $record = $modelClass::findOrFail($id);
        $record->is_active = $request->boolean('is_active');
        $record->save();

        return back()->with('success', 'Status updated.');
    }
}
