<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Device;
use App\Models\Discount;
use App\Models\Language;
use App\Models\PaymentMethod;
use App\Models\Plan;
use App\Models\Product;
use App\Models\ProductOption;
use App\Models\ProductOptionCategory;
use App\Models\Tax;
use App\Models\Translation;
use App\Models\Store;
use App\Models\Manager;
use App\Models\Category;
use App\Models\Currency;
use App\Models\Customer;
use App\Models\Permission;
use App\Models\Role;
use App\Models\Subscription;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $stats = [
            'managers' => Manager::count(),
            'plans' => Plan::count(),
            'subscriptions' => Subscription::count(),
            'stores' => Store::count(),
            'devices' => Device::count(),
            'payment_methods' => PaymentMethod::count(),
            'currencies' => Currency::count(),
            'categories' => Category::count(),
            'product_option_categories' => ProductOptionCategory::count(),
            'product_options' => ProductOption::count(),
            'products' => Product::count(),
            'customers' => Customer::count(),
            'taxes' => Tax::count(),
            'discounts' => Discount::count(),
            'roles' => Role::count(),
            'permissions' => Permission::count(),
            'languages' => Language::count(),
            'translations' => Translation::count(),
        ];

        $cards = [
            ['label' => 'Managers', 'route' => route('admin.managers.index'), 'count' => $stats['managers']],
            ['label' => 'Plans', 'route' => route('admin.plans.index'), 'count' => $stats['plans']],
            ['label' => 'Subscriptions', 'route' => route('admin.subscriptions.index'), 'count' => $stats['subscriptions']],
            ['label' => 'Stores', 'route' => route('admin.stores.index'), 'count' => $stats['stores']],
            ['label' => 'Devices', 'route' => route('admin.devices.index'), 'count' => $stats['devices']],
            ['label' => 'Payment Methods', 'route' => route('admin.payment_methods.index'), 'count' => $stats['payment_methods']],
            ['label' => 'Currencies', 'route' => route('admin.currencies.index'), 'count' => $stats['currencies']],
            ['label' => 'Categories', 'route' => route('admin.categories.index'), 'count' => $stats['categories']],
            ['label' => 'Product Option Categories', 'route' => route('admin.product_option_categories.index'), 'count' => $stats['product_option_categories']],
            ['label' => 'Product Options', 'route' => route('admin.product_options.index'), 'count' => $stats['product_options']],
            ['label' => 'Products', 'route' => route('admin.products.index'), 'count' => $stats['products']],
            ['label' => 'Customers', 'route' => route('admin.customers.index'), 'count' => $stats['customers']],
            ['label' => 'Taxes', 'route' => route('admin.taxes.index'), 'count' => $stats['taxes']],
            ['label' => 'Discounts', 'route' => route('admin.discounts.index'), 'count' => $stats['discounts']],
            ['label' => 'Roles', 'route' => route('admin.roles.index'), 'count' => $stats['roles']],
            ['label' => 'Permissions', 'route' => route('admin.permissions.index'), 'count' => $stats['permissions']],
            ['label' => 'Printing', 'route' => route('admin.printing.index'), 'count' => null],
            ['label' => 'Reports', 'route' => route('admin.reports.index'), 'count' => null],
            ['label' => 'Languages', 'route' => route('admin.languages.index'), 'count' => $stats['languages']],
            ['label' => 'Translations', 'route' => route('admin.translations.index'), 'count' => $stats['translations']],
            ['label' => 'Shipping', 'route' => route('admin.shipping.index'), 'count' => null],
            ['label' => 'Data Transfer', 'route' => route('admin.data_transfer.index'), 'count' => null],
        ];

        return view('admin.dashboard', compact('cards'));
    }
}
