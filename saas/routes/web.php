<?php

use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\ActiveToggleController;
use App\Http\Controllers\Admin\DeviceController as AdminDeviceController;
use App\Http\Controllers\Admin\CategoryController as AdminCategoryController;
use App\Http\Controllers\Admin\ProductOptionCategoryController as AdminProductOptionCategoryController;
use App\Http\Controllers\Admin\PaymentMethodController;
use App\Http\Controllers\Admin\PermissionController as AdminPermissionController;
use App\Http\Controllers\Admin\RoleController as AdminRoleController;
use App\Http\Controllers\Admin\ReportController as AdminReportController;
use App\Http\Controllers\Admin\PrintingController as AdminPrintingController;
use App\Http\Controllers\Admin\StoreController as AdminStoreController;
use App\Http\Controllers\Admin\PlanController as AdminPlanController;
use App\Http\Controllers\Admin\ManagerController;
use App\Http\Controllers\Admin\ProductController as AdminProductController;
use App\Http\Controllers\Admin\CustomerController as AdminCustomerController;
use App\Http\Controllers\Admin\TaxController as AdminTaxController;
use App\Http\Controllers\Admin\DiscountController as AdminDiscountController;
use App\Http\Controllers\Admin\CurrencyController as AdminCurrencyController;
use App\Http\Controllers\Admin\ProductOptionController as AdminProductOptionController;
use App\Http\Controllers\Admin\LanguageController as AdminLanguageController;
use App\Http\Controllers\Admin\ShippingController as AdminShippingController;
use App\Http\Controllers\Admin\SubscriptionController as AdminSubscriptionController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\Admin\TranslationController as AdminTranslationController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Manager\DashboardController as ManagerDashboardController;
use App\Http\Controllers\Manager\CategoryController as ManagerCategoryController;
use App\Http\Controllers\Manager\ProductController as ManagerProductController;
use App\Http\Controllers\Manager\ProductVariantController as ManagerProductVariantController;
use App\Http\Controllers\Manager\CustomerController as ManagerCustomerController;
use App\Http\Controllers\Manager\SaleController as ManagerSaleController;
use App\Http\Controllers\Manager\StoreController as ManagerStoreController;
use App\Http\Controllers\Manager\StockController as ManagerStockController;
use App\Http\Controllers\Manager\UserController as ManagerUserController;
use App\Http\Controllers\Manager\ProductOptionController as ManagerProductOptionController;
use App\Http\Controllers\Manager\ProductOptionCategoryController as ManagerProductOptionCategoryController;
use App\Http\Controllers\Manager\TaxController as ManagerTaxController;
use App\Http\Controllers\Manager\DiscountController as ManagerDiscountController;

Route::get('/', function () {
    return redirect()->route('admin.dashboard');
});

// Local dev escape hatch if you get stuck in a bad session.
Route::get('/logout', function (Request $request) {
    if (!app()->isLocal()) {
        abort(404);
    }

    Auth::guard('web')->logout();
    $request->session()->invalidate();
    $request->session()->regenerateToken();

    return redirect('/login');
})->name('logout.get');

Route::get('/dashboard', function () {
    $user = auth()->user();

    if ($user?->is_super_admin) {
        return redirect()->route('admin.dashboard');
    }

    if ($user?->manager_id) {
        return redirect()->route('manager.dashboard');
    }

    return view('dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

Route::prefix('admin')->name('admin.')->middleware(['auth', 'super_admin'])->group(function () {
    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');
    Route::patch('/toggle-active/{type}/{id}', [ActiveToggleController::class, 'update'])->name('toggle_active');

    Route::get('/managers', [ManagerController::class, 'index'])->name('managers.index');
    Route::get('/managers/create', [ManagerController::class, 'create'])->name('managers.create');
    Route::post('/managers', [ManagerController::class, 'store'])->name('managers.store');
    Route::get('/managers/{manager}/edit', [ManagerController::class, 'edit'])->name('managers.edit');
    Route::put('/managers/{manager}', [ManagerController::class, 'update'])->name('managers.update');
    Route::delete('/managers/{manager}', [ManagerController::class, 'destroy'])->name('managers.destroy');

    Route::get('/plans', [AdminPlanController::class, 'index'])->name('plans.index');
    Route::get('/plans/create', [AdminPlanController::class, 'create'])->name('plans.create');
    Route::post('/plans', [AdminPlanController::class, 'store'])->name('plans.store');
    Route::get('/plans/{plan}/edit', [AdminPlanController::class, 'edit'])->name('plans.edit');
    Route::put('/plans/{plan}', [AdminPlanController::class, 'update'])->name('plans.update');
    Route::delete('/plans/{plan}', [AdminPlanController::class, 'destroy'])->name('plans.destroy');

    Route::get('/stores', [AdminStoreController::class, 'index'])->name('stores.index');
    Route::get('/stores/create', [AdminStoreController::class, 'create'])->name('stores.create');
    Route::post('/stores', [AdminStoreController::class, 'store'])->name('stores.store');
    Route::delete('/stores/{store}', [AdminStoreController::class, 'destroy'])->name('stores.destroy');

    Route::get('/devices', [AdminDeviceController::class, 'index'])->name('devices.index');
    Route::get('/devices/create', [AdminDeviceController::class, 'create'])->name('devices.create');
    Route::post('/devices', [AdminDeviceController::class, 'store'])->name('devices.store');

    Route::get('/payment-methods', [PaymentMethodController::class, 'index'])->name('payment_methods.index');
    Route::get('/payment-methods/create', [PaymentMethodController::class, 'create'])->name('payment_methods.create');
    Route::post('/payment-methods', [PaymentMethodController::class, 'store'])->name('payment_methods.store');
    Route::delete('/payment-methods/{paymentMethod}', [PaymentMethodController::class, 'destroy'])->name('payment_methods.destroy');

    Route::get('/currencies', [AdminCurrencyController::class, 'index'])->name('currencies.index');
    Route::get('/currencies/create', [AdminCurrencyController::class, 'create'])->name('currencies.create');
    Route::post('/currencies', [AdminCurrencyController::class, 'store'])->name('currencies.store');
    Route::get('/currencies/{currency}/edit', [AdminCurrencyController::class, 'edit'])->name('currencies.edit');
    Route::put('/currencies/{currency}', [AdminCurrencyController::class, 'update'])->name('currencies.update');
    Route::delete('/currencies/{currency}', [AdminCurrencyController::class, 'destroy'])->name('currencies.destroy');

    Route::get('/categories', [AdminCategoryController::class, 'index'])->name('categories.index');
    Route::get('/categories/create', [AdminCategoryController::class, 'create'])->name('categories.create');
    Route::post('/categories', [AdminCategoryController::class, 'store'])->name('categories.store');
    Route::get('/categories/{category}/edit', [AdminCategoryController::class, 'edit'])->name('categories.edit');
    Route::put('/categories/{category}', [AdminCategoryController::class, 'update'])->name('categories.update');
    Route::delete('/categories/{category}', [AdminCategoryController::class, 'destroy'])->name('categories.destroy');

    Route::get('/product-option-categories', [AdminProductOptionCategoryController::class, 'index'])->name('product_option_categories.index');
    Route::get('/product-option-categories/create', [AdminProductOptionCategoryController::class, 'create'])->name('product_option_categories.create');
    Route::post('/product-option-categories', [AdminProductOptionCategoryController::class, 'store'])->name('product_option_categories.store');
    Route::get('/product-option-categories/{productOptionCategory}/edit', [AdminProductOptionCategoryController::class, 'edit'])->name('product_option_categories.edit');
    Route::put('/product-option-categories/{productOptionCategory}', [AdminProductOptionCategoryController::class, 'update'])->name('product_option_categories.update');
    Route::delete('/product-option-categories/{productOptionCategory}', [AdminProductOptionCategoryController::class, 'destroy'])->name('product_option_categories.destroy');

    Route::get('/product-options', [AdminProductOptionController::class, 'index'])->name('product_options.index');
    Route::get('/product-options/create', [AdminProductOptionController::class, 'create'])->name('product_options.create');
    Route::post('/product-options', [AdminProductOptionController::class, 'store'])->name('product_options.store');
    Route::get('/product-options/{productOption}/edit', [AdminProductOptionController::class, 'edit'])->name('product_options.edit');
    Route::put('/product-options/{productOption}', [AdminProductOptionController::class, 'update'])->name('product_options.update');
    Route::delete('/product-options/{productOption}', [AdminProductOptionController::class, 'destroy'])->name('product_options.destroy');

    Route::get('/products', [AdminProductController::class, 'index'])->name('products.index');
    Route::get('/products/import', [AdminProductController::class, 'importForm'])->name('products.import_form');
    Route::post('/products/import', [AdminProductController::class, 'import'])->name('products.import');
    Route::get('/products/create', [AdminProductController::class, 'create'])->name('products.create');
    Route::post('/products', [AdminProductController::class, 'store'])->name('products.store');
    Route::get('/products/{product}/edit', [AdminProductController::class, 'edit'])->name('products.edit');
    Route::put('/products/{product}', [AdminProductController::class, 'update'])->name('products.update');
    Route::delete('/products/{product}', [AdminProductController::class, 'destroy'])->name('products.destroy');

    Route::get('/customers', [AdminCustomerController::class, 'index'])->name('customers.index');
    Route::get('/customers/create', [AdminCustomerController::class, 'create'])->name('customers.create');
    Route::post('/customers', [AdminCustomerController::class, 'store'])->name('customers.store');
    Route::get('/customers/{customer}/edit', [AdminCustomerController::class, 'edit'])->name('customers.edit');
    Route::put('/customers/{customer}', [AdminCustomerController::class, 'update'])->name('customers.update');
    Route::delete('/customers/{customer}', [AdminCustomerController::class, 'destroy'])->name('customers.destroy');

    Route::get('/taxes', [AdminTaxController::class, 'index'])->name('taxes.index');
    Route::get('/taxes/create', [AdminTaxController::class, 'create'])->name('taxes.create');
    Route::post('/taxes', [AdminTaxController::class, 'store'])->name('taxes.store');
    Route::get('/taxes/{tax}/edit', [AdminTaxController::class, 'edit'])->name('taxes.edit');
    Route::put('/taxes/{tax}', [AdminTaxController::class, 'update'])->name('taxes.update');
    Route::delete('/taxes/{tax}', [AdminTaxController::class, 'destroy'])->name('taxes.destroy');

    Route::get('/discounts', [AdminDiscountController::class, 'index'])->name('discounts.index');
    Route::get('/discounts/create', [AdminDiscountController::class, 'create'])->name('discounts.create');
    Route::post('/discounts', [AdminDiscountController::class, 'store'])->name('discounts.store');
    Route::get('/discounts/{discount}/edit', [AdminDiscountController::class, 'edit'])->name('discounts.edit');
    Route::put('/discounts/{discount}', [AdminDiscountController::class, 'update'])->name('discounts.update');
    Route::delete('/discounts/{discount}', [AdminDiscountController::class, 'destroy'])->name('discounts.destroy');

    Route::get('/roles', [AdminRoleController::class, 'index'])->name('roles.index');
    Route::get('/roles/create', [AdminRoleController::class, 'create'])->name('roles.create');
    Route::post('/roles', [AdminRoleController::class, 'store'])->name('roles.store');
    Route::get('/roles/{role}/edit', [AdminRoleController::class, 'edit'])->name('roles.edit');
    Route::put('/roles/{role}', [AdminRoleController::class, 'update'])->name('roles.update');

    Route::get('/permissions', [AdminPermissionController::class, 'index'])->name('permissions.index');
    Route::get('/permissions/create', [AdminPermissionController::class, 'create'])->name('permissions.create');
    Route::post('/permissions', [AdminPermissionController::class, 'store'])->name('permissions.store');
    Route::get('/permissions/{permission}/edit', [AdminPermissionController::class, 'edit'])->name('permissions.edit');
    Route::put('/permissions/{permission}', [AdminPermissionController::class, 'update'])->name('permissions.update');

    Route::get('/printing', [AdminPrintingController::class, 'index'])->name('printing.index');

    Route::get('/reports', [AdminReportController::class, 'index'])->name('reports.index');

    Route::get('/languages', [AdminLanguageController::class, 'index'])->name('languages.index');
    Route::get('/languages/create', [AdminLanguageController::class, 'create'])->name('languages.create');
    Route::post('/languages', [AdminLanguageController::class, 'store'])->name('languages.store');
    Route::get('/languages/{language}/edit', [AdminLanguageController::class, 'edit'])->name('languages.edit');
    Route::put('/languages/{language}', [AdminLanguageController::class, 'update'])->name('languages.update');

    Route::get('/translations', [AdminTranslationController::class, 'index'])->name('translations.index');
    Route::get('/translations/create', [AdminTranslationController::class, 'create'])->name('translations.create');
    Route::post('/translations', [AdminTranslationController::class, 'store'])->name('translations.store');
    Route::get('/translations/{translation}/edit', [AdminTranslationController::class, 'edit'])->name('translations.edit');
    Route::put('/translations/{translation}', [AdminTranslationController::class, 'update'])->name('translations.update');

    Route::get('/shipping', [AdminShippingController::class, 'index'])->name('shipping.index');

    Route::get('/subscriptions', [AdminSubscriptionController::class, 'index'])->name('subscriptions.index');
    Route::get('/subscriptions/create', [AdminSubscriptionController::class, 'create'])->name('subscriptions.create');
    Route::post('/subscriptions', [AdminSubscriptionController::class, 'store'])->name('subscriptions.store');
    Route::get('/subscriptions/{subscription}/edit', [AdminSubscriptionController::class, 'edit'])->name('subscriptions.edit');
    Route::put('/subscriptions/{subscription}', [AdminSubscriptionController::class, 'update'])->name('subscriptions.update');
});

Route::prefix('manager')->name('manager.')->middleware(['auth', 'manager_user'])->group(function () {
    Route::view('/no-store', 'manager.no_store')->name('no_store');

    Route::middleware(['manager_store'])->group(function () {
        Route::get('/', [ManagerDashboardController::class, 'index'])->name('dashboard');
        Route::get('/stores', [ManagerStoreController::class, 'index'])->name('stores.index');
        Route::get('/stores/create', [ManagerStoreController::class, 'create'])->name('stores.create');
        Route::post('/stores', [ManagerStoreController::class, 'store'])->name('stores.store');
        Route::get('/stores/{store}/edit', [ManagerStoreController::class, 'edit'])->name('stores.edit');
        Route::put('/stores/{store}', [ManagerStoreController::class, 'update'])->name('stores.update');

        Route::get('/categories', [ManagerCategoryController::class, 'index'])->name('categories.index');
        Route::get('/categories/create', [ManagerCategoryController::class, 'create'])->name('categories.create');
        Route::post('/categories', [ManagerCategoryController::class, 'store'])->name('categories.store');
        Route::get('/categories/{category}/edit', [ManagerCategoryController::class, 'edit'])->name('categories.edit');
        Route::put('/categories/{category}', [ManagerCategoryController::class, 'update'])->name('categories.update');
        Route::post('/categories/{category}/duplicate', [ManagerCategoryController::class, 'duplicate'])->name('categories.duplicate');
        Route::delete('/categories/{category}', [ManagerCategoryController::class, 'destroy'])->name('categories.destroy');

        Route::get('/product-option-categories', [ManagerProductOptionCategoryController::class, 'index'])->name('product_option_categories.index');
        Route::get('/product-option-categories/create', [ManagerProductOptionCategoryController::class, 'create'])->name('product_option_categories.create');
        Route::post('/product-option-categories', [ManagerProductOptionCategoryController::class, 'store'])->name('product_option_categories.store');
        Route::get('/product-option-categories/{productOptionCategory}/edit', [ManagerProductOptionCategoryController::class, 'edit'])->name('product_option_categories.edit');
        Route::put('/product-option-categories/{productOptionCategory}', [ManagerProductOptionCategoryController::class, 'update'])->name('product_option_categories.update');
        Route::post('/product-option-categories/{productOptionCategory}/duplicate', [ManagerProductOptionCategoryController::class, 'duplicate'])->name('product_option_categories.duplicate');
        Route::delete('/product-option-categories/{productOptionCategory}', [ManagerProductOptionCategoryController::class, 'destroy'])->name('product_option_categories.destroy');

        Route::get('/product-options', [ManagerProductOptionController::class, 'index'])->name('product_options.index');
        Route::get('/product-options/create', [ManagerProductOptionController::class, 'create'])->name('product_options.create');
        Route::post('/product-options', [ManagerProductOptionController::class, 'store'])->name('product_options.store');
        Route::get('/product-options/{productOption}/edit', [ManagerProductOptionController::class, 'edit'])->name('product_options.edit');
        Route::put('/product-options/{productOption}', [ManagerProductOptionController::class, 'update'])->name('product_options.update');
        Route::post('/product-options/{productOption}/duplicate', [ManagerProductOptionController::class, 'duplicate'])->name('product_options.duplicate');
        Route::delete('/product-options/{productOption}', [ManagerProductOptionController::class, 'destroy'])->name('product_options.destroy');

        Route::get('/products', [ManagerProductController::class, 'index'])->name('products.index');
        Route::get('/products/import', [ManagerProductController::class, 'importForm'])->name('products.import_form');
        Route::post('/products/import', [ManagerProductController::class, 'import'])->name('products.import');
        Route::get('/products/create', [ManagerProductController::class, 'create'])->name('products.create');
        Route::post('/products', [ManagerProductController::class, 'store'])->name('products.store');
        Route::get('/products/{product}/edit', [ManagerProductController::class, 'edit'])->name('products.edit');
        Route::put('/products/{product}', [ManagerProductController::class, 'update'])->name('products.update');
        Route::post('/products/{product}/duplicate', [ManagerProductController::class, 'duplicate'])->name('products.duplicate');
        Route::delete('/products/{product}', [ManagerProductController::class, 'destroy'])->name('products.destroy');
        Route::post('/products/{product}/variants', [ManagerProductVariantController::class, 'store'])->name('products.variants.store');
        Route::put('/products/{product}/variants/{variant}', [ManagerProductVariantController::class, 'update'])->name('products.variants.update');
        Route::delete('/products/{product}/variants/{variant}', [ManagerProductVariantController::class, 'destroy'])->name('products.variants.destroy');

        Route::get('/stock', [ManagerStockController::class, 'index'])->name('stock.index');
        Route::put('/stock/stores/{store}', [ManagerStockController::class, 'updateStore'])->name('stock.stores.update');
        Route::put('/stock/products/{product}', [ManagerStockController::class, 'updateProduct'])->name('stock.products.update');

        Route::get('/customers', [ManagerCustomerController::class, 'index'])->name('customers.index');
        Route::get('/customers/create', [ManagerCustomerController::class, 'create'])->name('customers.create');
        Route::post('/customers', [ManagerCustomerController::class, 'store'])->name('customers.store');
        Route::get('/customers/{customer}/edit', [ManagerCustomerController::class, 'edit'])->name('customers.edit');
        Route::put('/customers/{customer}', [ManagerCustomerController::class, 'update'])->name('customers.update');
        Route::post('/customers/{customer}/duplicate', [ManagerCustomerController::class, 'duplicate'])->name('customers.duplicate');
        Route::delete('/customers/{customer}', [ManagerCustomerController::class, 'destroy'])->name('customers.destroy');

        Route::get('/taxes', [ManagerTaxController::class, 'index'])->name('taxes.index');
        Route::get('/taxes/create', [ManagerTaxController::class, 'create'])->name('taxes.create');
        Route::post('/taxes', [ManagerTaxController::class, 'store'])->name('taxes.store');
        Route::get('/taxes/{tax}/edit', [ManagerTaxController::class, 'edit'])->name('taxes.edit');
        Route::put('/taxes/{tax}', [ManagerTaxController::class, 'update'])->name('taxes.update');
        Route::delete('/taxes/{tax}', [ManagerTaxController::class, 'destroy'])->name('taxes.destroy');

        Route::get('/discounts', [ManagerDiscountController::class, 'index'])->name('discounts.index');
        Route::get('/discounts/create', [ManagerDiscountController::class, 'create'])->name('discounts.create');
        Route::post('/discounts', [ManagerDiscountController::class, 'store'])->name('discounts.store');
        Route::get('/discounts/{discount}/edit', [ManagerDiscountController::class, 'edit'])->name('discounts.edit');
        Route::put('/discounts/{discount}', [ManagerDiscountController::class, 'update'])->name('discounts.update');
        Route::delete('/discounts/{discount}', [ManagerDiscountController::class, 'destroy'])->name('discounts.destroy');

        Route::get('/sales', [ManagerSaleController::class, 'index'])->name('sales.index');
        Route::get('/sales/{sale}', [ManagerSaleController::class, 'show'])->name('sales.show');

        Route::get('/users', [ManagerUserController::class, 'index'])->name('users.index');
        Route::get('/users/create', [ManagerUserController::class, 'create'])->name('users.create');
        Route::post('/users', [ManagerUserController::class, 'store'])->name('users.store');
        Route::get('/users/{user}/edit', [ManagerUserController::class, 'edit'])->name('users.edit');
        Route::put('/users/{user}', [ManagerUserController::class, 'update'])->name('users.update');
        Route::post('/users/{user}/duplicate', [ManagerUserController::class, 'duplicate'])->name('users.duplicate');
        Route::delete('/users/{user}', [ManagerUserController::class, 'destroy'])->name('users.destroy');
    });
});

require __DIR__.'/auth.php';
