<?php

use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\DeviceController as AdminDeviceController;
use App\Http\Controllers\Admin\CategoryController as AdminCategoryController;
use App\Http\Controllers\Admin\IngredientCategoryController as AdminIngredientCategoryController;
use App\Http\Controllers\Admin\PaymentMethodController;
use App\Http\Controllers\Admin\PermissionController as AdminPermissionController;
use App\Http\Controllers\Admin\RoleController as AdminRoleController;
use App\Http\Controllers\Admin\ReportController as AdminReportController;
use App\Http\Controllers\Admin\PrintingController as AdminPrintingController;
use App\Http\Controllers\Admin\StoreController as AdminStoreController;
use App\Http\Controllers\Admin\PlanController as AdminPlanController;
use App\Http\Controllers\Admin\TenantController;
use App\Http\Controllers\Admin\ProductController as AdminProductController;
use App\Http\Controllers\Admin\CustomerController as AdminCustomerController;
use App\Http\Controllers\Admin\TaxController as AdminTaxController;
use App\Http\Controllers\Admin\DiscountController as AdminDiscountController;
use App\Http\Controllers\Admin\CurrencyController as AdminCurrencyController;
use App\Http\Controllers\Admin\IngredientController as AdminIngredientController;
use App\Http\Controllers\ProfileController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Tenant\DashboardController as TenantDashboardController;
use App\Http\Controllers\Tenant\CategoryController as TenantCategoryController;
use App\Http\Controllers\Tenant\ProductController as TenantProductController;
use App\Http\Controllers\Tenant\ProductVariantController as TenantProductVariantController;
use App\Http\Controllers\Tenant\CustomerController as TenantCustomerController;
use App\Http\Controllers\Tenant\SaleController as TenantSaleController;
use App\Http\Controllers\Tenant\StoreController as TenantStoreController;
use App\Http\Controllers\Tenant\StockController as TenantStockController;
use App\Http\Controllers\Tenant\UserController as TenantUserController;
use App\Http\Controllers\Tenant\IngredientController as TenantIngredientController;
use App\Http\Controllers\Tenant\IngredientCategoryController as TenantIngredientCategoryController;
use App\Http\Controllers\Tenant\TaxController as TenantTaxController;
use App\Http\Controllers\Tenant\DiscountController as TenantDiscountController;

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

    if ($user?->tenant_id) {
        return redirect()->route('tenant.dashboard');
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

    Route::get('/tenants', [TenantController::class, 'index'])->name('tenants.index');
    Route::get('/tenants/create', [TenantController::class, 'create'])->name('tenants.create');
    Route::post('/tenants', [TenantController::class, 'store'])->name('tenants.store');
    Route::get('/tenants/{tenant}/edit', [TenantController::class, 'edit'])->name('tenants.edit');
    Route::put('/tenants/{tenant}', [TenantController::class, 'update'])->name('tenants.update');

    Route::get('/plans', [AdminPlanController::class, 'index'])->name('plans.index');
    Route::get('/plans/create', [AdminPlanController::class, 'create'])->name('plans.create');
    Route::post('/plans', [AdminPlanController::class, 'store'])->name('plans.store');
    Route::get('/plans/{plan}/edit', [AdminPlanController::class, 'edit'])->name('plans.edit');
    Route::put('/plans/{plan}', [AdminPlanController::class, 'update'])->name('plans.update');
    Route::delete('/plans/{plan}', [AdminPlanController::class, 'destroy'])->name('plans.destroy');

    Route::get('/stores', [AdminStoreController::class, 'index'])->name('stores.index');
    Route::get('/stores/create', [AdminStoreController::class, 'create'])->name('stores.create');
    Route::post('/stores', [AdminStoreController::class, 'store'])->name('stores.store');

    Route::get('/devices', [AdminDeviceController::class, 'index'])->name('devices.index');
    Route::get('/devices/create', [AdminDeviceController::class, 'create'])->name('devices.create');
    Route::post('/devices', [AdminDeviceController::class, 'store'])->name('devices.store');

    Route::get('/payment-methods', [PaymentMethodController::class, 'index'])->name('payment_methods.index');
    Route::get('/payment-methods/create', [PaymentMethodController::class, 'create'])->name('payment_methods.create');
    Route::post('/payment-methods', [PaymentMethodController::class, 'store'])->name('payment_methods.store');

    Route::get('/currencies', [AdminCurrencyController::class, 'index'])->name('currencies.index');
    Route::get('/currencies/create', [AdminCurrencyController::class, 'create'])->name('currencies.create');
    Route::post('/currencies', [AdminCurrencyController::class, 'store'])->name('currencies.store');
    Route::get('/currencies/{currency}/edit', [AdminCurrencyController::class, 'edit'])->name('currencies.edit');
    Route::put('/currencies/{currency}', [AdminCurrencyController::class, 'update'])->name('currencies.update');

    Route::get('/categories', [AdminCategoryController::class, 'index'])->name('categories.index');
    Route::get('/categories/create', [AdminCategoryController::class, 'create'])->name('categories.create');
    Route::post('/categories', [AdminCategoryController::class, 'store'])->name('categories.store');
    Route::get('/categories/{category}/edit', [AdminCategoryController::class, 'edit'])->name('categories.edit');
    Route::put('/categories/{category}', [AdminCategoryController::class, 'update'])->name('categories.update');
    Route::delete('/categories/{category}', [AdminCategoryController::class, 'destroy'])->name('categories.destroy');

    Route::get('/ingredient-categories', [AdminIngredientCategoryController::class, 'index'])->name('ingredient_categories.index');
    Route::get('/ingredient-categories/create', [AdminIngredientCategoryController::class, 'create'])->name('ingredient_categories.create');
    Route::post('/ingredient-categories', [AdminIngredientCategoryController::class, 'store'])->name('ingredient_categories.store');
    Route::get('/ingredient-categories/{ingredientCategory}/edit', [AdminIngredientCategoryController::class, 'edit'])->name('ingredient_categories.edit');
    Route::put('/ingredient-categories/{ingredientCategory}', [AdminIngredientCategoryController::class, 'update'])->name('ingredient_categories.update');
    Route::delete('/ingredient-categories/{ingredientCategory}', [AdminIngredientCategoryController::class, 'destroy'])->name('ingredient_categories.destroy');

    Route::get('/ingredients', [AdminIngredientController::class, 'index'])->name('ingredients.index');
    Route::get('/ingredients/create', [AdminIngredientController::class, 'create'])->name('ingredients.create');
    Route::post('/ingredients', [AdminIngredientController::class, 'store'])->name('ingredients.store');
    Route::get('/ingredients/{ingredient}/edit', [AdminIngredientController::class, 'edit'])->name('ingredients.edit');
    Route::put('/ingredients/{ingredient}', [AdminIngredientController::class, 'update'])->name('ingredients.update');
    Route::delete('/ingredients/{ingredient}', [AdminIngredientController::class, 'destroy'])->name('ingredients.destroy');

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
});

Route::prefix('tenant')->name('tenant.')->middleware(['auth', 'tenant_user'])->group(function () {
    Route::get('/', [TenantDashboardController::class, 'index'])->name('dashboard');
    Route::get('/stores', [TenantStoreController::class, 'index'])->name('stores.index');
    Route::get('/stores/create', [TenantStoreController::class, 'create'])->name('stores.create');
    Route::post('/stores', [TenantStoreController::class, 'store'])->name('stores.store');
    Route::get('/stores/{store}/edit', [TenantStoreController::class, 'edit'])->name('stores.edit');
    Route::put('/stores/{store}', [TenantStoreController::class, 'update'])->name('stores.update');

    Route::get('/categories', [TenantCategoryController::class, 'index'])->name('categories.index');
    Route::get('/categories/create', [TenantCategoryController::class, 'create'])->name('categories.create');
    Route::post('/categories', [TenantCategoryController::class, 'store'])->name('categories.store');
    Route::get('/categories/{category}/edit', [TenantCategoryController::class, 'edit'])->name('categories.edit');
    Route::put('/categories/{category}', [TenantCategoryController::class, 'update'])->name('categories.update');
    Route::delete('/categories/{category}', [TenantCategoryController::class, 'destroy'])->name('categories.destroy');

    Route::get('/ingredient-categories', [TenantIngredientCategoryController::class, 'index'])->name('ingredient_categories.index');
    Route::get('/ingredient-categories/create', [TenantIngredientCategoryController::class, 'create'])->name('ingredient_categories.create');
    Route::post('/ingredient-categories', [TenantIngredientCategoryController::class, 'store'])->name('ingredient_categories.store');
    Route::get('/ingredient-categories/{ingredientCategory}/edit', [TenantIngredientCategoryController::class, 'edit'])->name('ingredient_categories.edit');
    Route::put('/ingredient-categories/{ingredientCategory}', [TenantIngredientCategoryController::class, 'update'])->name('ingredient_categories.update');
    Route::delete('/ingredient-categories/{ingredientCategory}', [TenantIngredientCategoryController::class, 'destroy'])->name('ingredient_categories.destroy');

    Route::get('/ingredients', [TenantIngredientController::class, 'index'])->name('ingredients.index');
    Route::get('/ingredients/create', [TenantIngredientController::class, 'create'])->name('ingredients.create');
    Route::post('/ingredients', [TenantIngredientController::class, 'store'])->name('ingredients.store');
    Route::get('/ingredients/{ingredient}/edit', [TenantIngredientController::class, 'edit'])->name('ingredients.edit');
    Route::put('/ingredients/{ingredient}', [TenantIngredientController::class, 'update'])->name('ingredients.update');
    Route::delete('/ingredients/{ingredient}', [TenantIngredientController::class, 'destroy'])->name('ingredients.destroy');

    Route::get('/products', [TenantProductController::class, 'index'])->name('products.index');
    Route::get('/products/import', [TenantProductController::class, 'importForm'])->name('products.import_form');
    Route::post('/products/import', [TenantProductController::class, 'import'])->name('products.import');
    Route::get('/products/create', [TenantProductController::class, 'create'])->name('products.create');
    Route::post('/products', [TenantProductController::class, 'store'])->name('products.store');
    Route::get('/products/{product}/edit', [TenantProductController::class, 'edit'])->name('products.edit');
    Route::put('/products/{product}', [TenantProductController::class, 'update'])->name('products.update');
    Route::delete('/products/{product}', [TenantProductController::class, 'destroy'])->name('products.destroy');
    Route::post('/products/{product}/variants', [TenantProductVariantController::class, 'store'])->name('products.variants.store');
    Route::put('/products/{product}/variants/{variant}', [TenantProductVariantController::class, 'update'])->name('products.variants.update');
    Route::delete('/products/{product}/variants/{variant}', [TenantProductVariantController::class, 'destroy'])->name('products.variants.destroy');

    Route::get('/stock', [TenantStockController::class, 'index'])->name('stock.index');
    Route::put('/stock/stores/{store}', [TenantStockController::class, 'updateStore'])->name('stock.stores.update');
    Route::put('/stock/products/{product}', [TenantStockController::class, 'updateProduct'])->name('stock.products.update');

    Route::get('/customers', [TenantCustomerController::class, 'index'])->name('customers.index');
    Route::get('/customers/create', [TenantCustomerController::class, 'create'])->name('customers.create');
    Route::post('/customers', [TenantCustomerController::class, 'store'])->name('customers.store');
    Route::get('/customers/{customer}/edit', [TenantCustomerController::class, 'edit'])->name('customers.edit');
    Route::put('/customers/{customer}', [TenantCustomerController::class, 'update'])->name('customers.update');
    Route::delete('/customers/{customer}', [TenantCustomerController::class, 'destroy'])->name('customers.destroy');

    Route::get('/taxes', [TenantTaxController::class, 'index'])->name('taxes.index');
    Route::get('/taxes/create', [TenantTaxController::class, 'create'])->name('taxes.create');
    Route::post('/taxes', [TenantTaxController::class, 'store'])->name('taxes.store');
    Route::get('/taxes/{tax}/edit', [TenantTaxController::class, 'edit'])->name('taxes.edit');
    Route::put('/taxes/{tax}', [TenantTaxController::class, 'update'])->name('taxes.update');
    Route::delete('/taxes/{tax}', [TenantTaxController::class, 'destroy'])->name('taxes.destroy');

    Route::get('/discounts', [TenantDiscountController::class, 'index'])->name('discounts.index');
    Route::get('/discounts/create', [TenantDiscountController::class, 'create'])->name('discounts.create');
    Route::post('/discounts', [TenantDiscountController::class, 'store'])->name('discounts.store');
    Route::get('/discounts/{discount}/edit', [TenantDiscountController::class, 'edit'])->name('discounts.edit');
    Route::put('/discounts/{discount}', [TenantDiscountController::class, 'update'])->name('discounts.update');
    Route::delete('/discounts/{discount}', [TenantDiscountController::class, 'destroy'])->name('discounts.destroy');

    Route::get('/sales', [TenantSaleController::class, 'index'])->name('sales.index');
    Route::get('/sales/{sale}', [TenantSaleController::class, 'show'])->name('sales.show');

    Route::get('/users', [TenantUserController::class, 'index'])->name('users.index');
    Route::get('/users/create', [TenantUserController::class, 'create'])->name('users.create');
    Route::post('/users', [TenantUserController::class, 'store'])->name('users.store');
    Route::get('/users/{user}/edit', [TenantUserController::class, 'edit'])->name('users.edit');
    Route::put('/users/{user}', [TenantUserController::class, 'update'])->name('users.update');
});

require __DIR__.'/auth.php';
