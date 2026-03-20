import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../core/api/api_client.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/models/order_summary.dart';
import '../../../core/models/product_category.dart';
import '../../../core/models/customer.dart';
import '../../../core/models/product.dart';
import '../../../core/models/product_ingredient.dart';
import '../../../core/models/currency.dart';
import '../../../core/models/payment_method.dart';
import '../../../core/models/register_details.dart';
import '../../../core/models/warehouse.dart';
import '../../../core/models/offline_sale.dart';
import '../data/pos_repository.dart';
import '../data/offline_sales_storage.dart';
import '../models/user_summary.dart';

enum DiscountMode { fixed, percentage }

class PosController extends ChangeNotifier {
  PosController({required this.repository});

  final PosRepository repository;
  final OfflineSalesStorage _offlineSalesStorage = OfflineSalesStorage();
  static const _cachedProductsKey = 'pos_cached_products';
  static const _cachedHistoryKeyPrefix = 'pos_cached_history_';
  static const _cachedCustomersKey = 'pos_cached_customers';
  static const _cachedWarehousesKey = 'pos_cached_warehouses';
  static const _cachedFrontSettingsKey = 'pos_cached_front_settings';
  static const _selectedCustomerKey = 'pos_selected_customer';
  static const _selectedWarehouseKey = 'pos_selected_warehouse';

  bool _isLoading = true;
  bool _isProcessingSale = false;
  List<Product> _products = [];
  List<Customer> _customers = [];
  List<Warehouse> _warehouses = [];
  List<ProductCategory> _categories = [];
  List<PaymentMethod> _paymentMethods = [];
  final List<CartItem> _cart = [];
  Customer? _selectedCustomer;
  Warehouse? _selectedWarehouse;
  int? _selectedWarehouseId;
  int? _selectedCategoryId;
  double _shipping = 0;
  double _discountInput = 0;
  DiscountMode _discountMode = DiscountMode.fixed;
  double _taxRate = 0;
  String _currencySymbol = 'DH';
  int? _currencyId;
  String _searchQuery = '';
  String _companyName = '';
  String _companyAddress = '';
  String _companyEmail = '';
  String _companyPhone = '';
  String _companyLogo = '';
  double _cashInHand = 0;
  String? _errorMessage;
  String? _successMessage;
  List<OrderSummary> _recentOrders = [];
  int _historyHours = 24;
  int? _historyUserFilter;
  List<OfflineSale> _offlineSales = [];
  RegisterDetails _registerDetails = RegisterDetails.empty();
  bool _isHistoryLoading = false;
  bool _historyLoadedOnce = false;
  bool _isCurrencySymbolRight = true;
  List<Currency> _currencies = [];
  List<UserSummary> _historyUsers = [];
  String? _activeUserLabel;
  DateTime? _historyResetAfter;
  bool _offlineMode = false;
  DateTime? _lastSyncAt;
  bool _isSyncingOfflineSales = false;
  Timer? _autoSyncTimer;
  bool _autoSyncInProgress = false;

  bool get isLoading => _isLoading;
  bool get isProcessingSale => _isProcessingSale;
  List<Customer> get customers => _customers;
  List<Warehouse> get warehouses => _warehouses;
  List<ProductCategory> get categories => _categories;
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  Customer? get selectedCustomer => _selectedCustomer;
  Warehouse? get selectedWarehouse => _selectedWarehouse;
  int? get selectedCategoryId => _selectedCategoryId;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  double get shipping => _shipping;
  double get discountInput => _discountInput;
  double get taxRate => _taxRate;
  DiscountMode get discountMode => _discountMode;

  String get currencySymbol => _currencySymbol;
  int? get currencyId => _currencyId;
  String get companyName => _companyName;
  String get companyAddress => _companyAddress;
  String get companyEmail => _companyEmail;
  String get companyPhone => _companyPhone;
  String get companyLogo => _companyLogo;
  double get cashInHand => _cashInHand;
  List<OrderSummary> get recentOrders => List.unmodifiable(_recentOrders);
  List<OrderSummary> get filteredRecentOrders {
    if (_historyUserFilter == null) {
      return List.unmodifiable(_recentOrders);
    }
    final needle = _historyUserFilter!;
    return List.unmodifiable(_recentOrders.where((order) {
      return order.userId == needle;
    }).toList());
  }
  int? get historyUserIdFilter => _historyUserFilter;
  int get historyHours => _historyHours;
  List<UserSummary> get historyUsers => List.unmodifiable(_historyUsers);
  List<OfflineSale> get offlineSales => List.unmodifiable(_offlineSales);
  bool get offlineMode => _offlineMode;
  DateTime? get lastSyncAt => _lastSyncAt;
  RegisterDetails get registerDetails => _registerDetails;
  RegisterDetails get displayRegisterDetails {
    final hasUserFilterOptions = _historyUsers.isNotEmpty;
    if (!hasUserFilterOptions && _historyUserFilter == null) {
      return _registerDetails;
    }
    if (_historyUserFilter == null) {
      return _buildRegisterDetailsFromOrders(_recentOrders);
    }
    return _buildRegisterDetailsFromOrders(filteredRecentOrders);
  }
  bool get isHistoryLoading => _isHistoryLoading;
  bool get isCurrencySymbolRight => _isCurrencySymbolRight;
  List<Currency> get currencies => List.unmodifiable(_currencies);
  int get ordersCount =>
      _registerDetails.salesCount > 0 ? _registerDetails.salesCount : _recentOrders.length;
  int get itemsSold => _registerDetails.itemsCount > 0
      ? _registerDetails.itemsCount
      : _recentOrders.fold(0, (sum, order) => sum + (order.itemCount));

  List<Product> get products {
    if (_searchQuery.isEmpty) {
      return _products;
    }
    final query = _searchQuery.toLowerCase();
    return _products
        .where((product) =>
            product.name.toLowerCase().contains(query) ||
            product.code.toLowerCase().contains(query))
        .toList();
  }

  List<CartItem> get cartItems => List.unmodifiable(_cart);

  int get totalQuantity => _cart.fold(0, (sum, item) => sum + item.quantity);

  double get itemsSubTotal =>
      _cart.fold<double>(0, (sum, item) => sum + item.subTotal);

  double get discountAmount {
    if (_discountMode == DiscountMode.percentage) {
      return itemsSubTotal * (_discountInput / 100);
    }
    return _discountInput;
  }

  double get subTotal {
    final value = itemsSubTotal - discountAmount;
    return value < 0 ? 0 : value;
  }

  double get taxTotal => subTotal * (_taxRate / 100);

  double get grandTotal => subTotal + taxTotal + _shipping;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> bootstrap() async {
    _setLoading(true);
    try {
      await _loadOfflineSales();
      await _loadCachedProducts();
      await _loadCachedHistory();
      await _loadCachedCustomers();
      await _loadCachedWarehouses();
      await _loadCachedFrontSettings();
      if (_offlineMode) {
        await _restoreSavedSelections();
        _setLoading(false);
        return;
      }
      final results = await Future.wait<dynamic>([
        repository.fetchCustomers(),
        repository.fetchFrontSetting(),
        repository.fetchCategories(),
        repository.fetchWarehouses(),
        repository.fetchPaymentMethods(),
        repository.fetchConfig(),
      ]);
      _customers = List<Customer>.from(results[0] as List<Customer>);
      if (_customers.isEmpty) {
        _customers = [Customer(id: 0, name: 'Client')];
      }
      final frontSettings = results[1] as Map<String, dynamic>;
      _applyFrontSetting(frontSettings);
      await _cacheFrontSetting(frontSettings);
      _categories =
          List<ProductCategory>.from(results[2] as List<ProductCategory>);
      _warehouses = List<Warehouse>.from(results[3] as List<Warehouse>);
      _paymentMethods =
          List<PaymentMethod>.from(results[4] as List<PaymentMethod>);
      _paymentMethods.sort((a, b) {
        if (a.isDefault == b.isDefault) return a.name.compareTo(b.name);
        return a.isDefault ? -1 : 1;
      });
      if (_paymentMethods.isEmpty) {
        _paymentMethods = [PaymentMethod.fallback()];
      }
      _applyConfig(results[5] as Map<String, dynamic>);
      await _cacheCustomers(_customers);
      await _cacheWarehouses(_warehouses);
      _assignDefaultWarehouse();
      await _restoreSavedSelections();
      await _loadProducts();
      _selectedCustomer = _customers.first;
      _errorMessage = null;
    } on ApiException catch (error) {
      await _loadCachedProducts();
      await _loadCachedHistory();
      _errorMessage = error.message;
      _forceOffline('Mode hors ligne: ${error.message}');
    } catch (error) {
      await _loadCachedProducts();
      await _loadCachedHistory();
      _errorMessage = error.toString();
      _forceOffline('Mode hors ligne: $error');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshProducts({bool skipSyncOffline = true}) async {
    // Tente de repasser en ligne si possible
    if (_offlineMode) {
      _offlineMode = false;
      notifyListeners();
    }
    if (!skipSyncOffline) {
      try {
        await _syncOfflineSales();
      } on ApiException catch (error) {
        final lower = error.message.toLowerCase();
        if (lower.contains('unauth')) {
          _forceOffline('Mode hors ligne: authentification requise (${error.message}). Cache conserve.');
          return;
        }
        rethrow;
      }
    }
    try {
      await _loadProducts();
      await loadOrderHistory();
      await _refreshFrontSetting();
      _lastSyncAt = DateTime.now();
      notifyListeners();
    } on ApiException catch (error) {
      final lower = error.message.toLowerCase();
      if (lower.contains('unauth')) {
        _forceOffline('Authentification requise (${error.message}). Passage en mode hors ligne (cache).');
        return;
      }
      _forceOffline('Impossible de rafraichir (${error.message}). Cache utilise.');
    } catch (_) {
      _forceOffline('Impossible de rafraichir. Cache utilise en mode hors ligne.');
    }
  }

  Future<void> loadCurrencies({bool force = false}) async {
    if (_currencies.isNotEmpty && !force) {
      return;
    }
    try {
      _currencies = await repository.fetchCurrencies();
      _currencies.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> updateCurrencySetting({
    required int currencyId,
    required bool symbolOnRight,
    String? currencySymbol,
  }) async {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      final storeId = _selectedWarehouseId;
      if (storeId == null) {
        _errorMessage = 'Veuillez sélectionner un magasin.';
        notifyListeners();
        return false;
      }
      await repository.updateSettings(storeId, {
        'currency_id': currencyId,
        'is_currency_right': symbolOnRight,
      });
      _currencyId = currencyId;
      if (currencySymbol != null && currencySymbol.isNotEmpty) {
        _currencySymbol = currencySymbol;
      }
      _isCurrencySymbolRight = symbolOnRight;
      await _refreshFrontSetting();
      _successMessage = 'Devise mise a jour.';
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  void startAutoSync({
    Duration interval = const Duration(minutes: 2),
    bool immediate = false,
  }) {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(interval, (_) {
      _runAutoSync();
    });
    if (immediate) {
      _runAutoSync();
    }
  }

  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  Future<void> syncNow() async {
    await _runAutoSync();
  }

  Future<void> _runAutoSync() async {
    if (_autoSyncInProgress) return;
    if (_offlineMode || _isLoading || _isProcessingSale || _isSyncingOfflineSales) {
      return;
    }
    _autoSyncInProgress = true;
    try {
      await refreshProducts();
    } catch (_) {
      // Silent sync: errors are handled in refreshProducts.
    } finally {
      _autoSyncInProgress = false;
    }
  }

  Future<void> _refreshFrontSetting() async {
    try {
      final frontSettings = await repository.fetchFrontSetting();
      _applyFrontSetting(frontSettings);
      await _cacheFrontSetting(frontSettings);
    } catch (_) {
      // Ignore front setting refresh errors to keep POS usable.
    }
  }

  void setOfflineMode(bool value) {
    if (_offlineMode == value) return;
    _offlineMode = value;
    notifyListeners();
  }

  Future<void> syncOfflineQueue() async {
    if (_offlineSales.isEmpty) {
      _successMessage = 'Aucune commande locale en attente.';
      notifyListeners();
      return;
    }
    _isProcessingSale = true;
    notifyListeners();
    final pendingBefore = _offlineSales.length;
    try {
      await _syncOfflineSales();
      await loadOrderHistory();
      final remaining = _offlineSales.length;
      if (remaining == 0) {
        _successMessage = 'Toutes les commandes locales ont été envoyées.';
        _errorMessage = null;
      } else if (remaining < pendingBefore) {
        final sent = pendingBefore - remaining;
        _successMessage = '$sent commande(s) ont été envoyées. $remaining en attente (consultez les erreurs).';
      } else {
        _errorMessage = 'Synchronisation impossible. Vérifiez les commandes locales.';
      }
    } catch (error) {
      _errorMessage = 'Échec de synchronisation: $error';
    } finally {
      _isProcessingSale = false;
      notifyListeners();
    }
  }

  void _forceOffline(String reason) {
    if (_offlineMode) {
      _errorMessage ??= reason;
      notifyListeners();
      return;
    }
    _offlineMode = true;
    _errorMessage = reason;
    notifyListeners();
  }

  Future<void> updateActiveUserLabel(String? label) async {
    if (_activeUserLabel == label) {
      return;
    }
    _activeUserLabel = label;
    await _loadHistoryResetPreference();
    // Reload cached history for this user if available.
    await _loadCachedHistory();
  }

  Future<void> loadOrderHistory({int hours = 24}) async {
    _historyHours = hours;
    _isHistoryLoading = true;
    notifyListeners();
    if (_historyUsers.isEmpty) {
      unawaited(_loadHistoryUsers());
    }
    // If we are offline, rely purely on cached data and avoid hitting the API.
    if (_offlineMode) {
      await _loadCachedHistory();
      final merged = [
        ..._recentOrders,
        ..._offlineOrders(),
      ]..sort((a, b) {
          final ad = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bd = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bd.compareTo(ad);
        });
      _recentOrders = merged;
      _registerDetails = _buildRegisterDetailsFromOrders(_recentOrders);
      _cashInHand = _registerDetails.cashInHand;
      _historyLoadedOnce = true;
      _isHistoryLoading = false;
      // Keep the last known error if any, but do not overwrite with socket errors in offline mode.
      notifyListeners();
      return;
    }
    try {
      final results = await Future.wait<dynamic>([
        repository.fetchRecentSales(hours: hours, userId: _historyUserFilter),
        repository.fetchRegisterDetails(hours: hours),
      ]);
      final orders = List<OrderSummary>.from(results[0] as List<OrderSummary>);
      final DateTime now = DateTime.now();
      DateTime cutoff = now.subtract(const Duration(hours: 24));
      if (_historyResetAfter != null && _historyResetAfter!.isAfter(cutoff)) {
        cutoff = _historyResetAfter!;
      }
      _recentOrders = orders
          .where(
            (order) =>
                order.createdAt == null || !order.createdAt!.isBefore(cutoff),
          )
          .toList()
        ..sort((a, b) {
          final ad = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bd = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bd.compareTo(ad);
        });
      if (_activeUserLabel != null && _activeUserLabel!.isNotEmpty) {
        _recentOrders = _recentOrders
            .map((o) => o.userName == null || o.userName!.isEmpty
                ? OrderSummary(
                    id: o.id,
                    referenceCode: o.referenceCode,
                    customerName: o.customerName,
                    userName: _activeUserLabel,
                    userId: o.userId,
                    status: o.status,
                    paymentStatus: o.paymentStatus,
                    grandTotal: o.grandTotal,
                    paidAmount: o.paidAmount,
                    itemCount: o.itemCount,
                    productNames: o.productNames,
                    itemsDetail: o.itemsDetail,
                    createdAt: o.createdAt,
                    isLocal: o.isLocal,
                  )
                : o)
            .toList();
      }
      // Enrichir les noms de produits si nécessaire
      final needsDetails = _recentOrders.any((o) => o.itemsDetail.isEmpty);
      if (needsDetails) {
        _recentOrders = await loadProductNamesForOrders(_recentOrders);
      }
      _registerDetails = results[1] as RegisterDetails;
      _cashInHand = _registerDetails.cashInHand;
      if (_historyResetAfter != null) {
        _registerDetails = _buildRegisterDetailsFromOrders(_recentOrders);
      }
      await _cacheHistory(_recentOrders, _registerDetails);
      _errorMessage = null;
      _historyLoadedOnce = true;
    } on ApiException catch (error) {
      await _loadCachedHistory();
      _errorMessage = error.message;
      final lower = error.message.toLowerCase();
      if (lower.contains('unauth') || lower.contains('authent')) {
        _forceOffline('Mode hors ligne: authentification requise (${error.message}). Cache conserve.');
      } else {
        _forceOffline('Mode hors ligne: ${error.message}');
      }
    } catch (error) {
      await _loadCachedHistory();
      _errorMessage = error.toString();
      _forceOffline('Mode hors ligne: $error');
    } finally {
      _isHistoryLoading = false;
      notifyListeners();
    }
  }

  void updateHistoryUserFilter(int? user) {
    final next = user;
    if (_historyUserFilter == next) return;
    _historyUserFilter = next;
    notifyListeners();
  }

  Future<void> loadHistoryUsers() async {
    if (_historyUsers.isNotEmpty) return;
    await _loadHistoryUsers();
  }

  Future<void> resetHistoryStats() async {
    _historyResetAfter = DateTime.now();
    await _persistHistoryResetPreference();
    _recentOrders = [];
    _registerDetails = RegisterDetails.empty();
    _cashInHand = 0;
    _historyLoadedOnce = false;
    notifyListeners();
  }

  Future<List<OrderSummary>> loadProductNamesForOrders(List<OrderSummary> orders) async {
    final updated = <OrderSummary>[];
    for (final order in orders) {
      try {
        final details = await repository
            .fetchSaleDetails(order.id)
            .timeout(const Duration(seconds: 8));
        if (details != null) {
          updated.add(_copyOrderWithDetails(order, details));
          continue;
        }
        final names = await repository
            .fetchSaleProductNames(order.id)
            .timeout(const Duration(seconds: 8));
        updated.add(_copyOrderWithNames(order, names.isNotEmpty ? names : order.productNames));
      } catch (_) {
        updated.add(order);
      }
    }
    return updated;
  }

  OrderSummary _copyOrderWithNames(OrderSummary order, List<String> names) {
    return OrderSummary(
      id: order.id,
      referenceCode: order.referenceCode,
      customerName: order.customerName,
      userName: order.userName,
      userId: order.userId,
      status: order.status,
      paymentStatus: order.paymentStatus,
      grandTotal: order.grandTotal,
      paidAmount: order.paidAmount,
      itemCount: order.itemCount,
      productNames: names,
      itemsDetail: order.itemsDetail,
      createdAt: order.createdAt,
      isLocal: order.isLocal,
    );
  }

  OrderSummary _copyOrderWithDetails(
    OrderSummary order,
    OrderSummary details,
  ) {
    return OrderSummary(
      id: order.id,
      referenceCode: order.referenceCode,
      customerName: order.customerName,
      userName: order.userName,
      userId: order.userId,
      status: order.status,
      paymentStatus: order.paymentStatus,
      grandTotal: order.grandTotal,
      paidAmount: order.paidAmount,
      itemCount: order.itemCount,
      productNames:
          details.productNames.isNotEmpty ? details.productNames : order.productNames,
      itemsDetail:
          details.itemsDetail.isNotEmpty ? details.itemsDetail : order.itemsDetail,
      createdAt: order.createdAt,
      isLocal: order.isLocal,
    );
  }

  void selectCustomer(Customer? customer) {
    _selectedCustomer = customer;
    _persistSelectedCustomer();
    notifyListeners();
  }

  Future<void> selectWarehouse(Warehouse? warehouse) async {
    _selectedWarehouse = warehouse;
    _selectedWarehouseId = warehouse?.id;
    _applyWarehouseCurrency(warehouse);
    await _persistSelectedWarehouse();
    await _loadProducts();
  }

  Future<void> selectCategory(int? categoryId) async {
    _selectedCategoryId = categoryId == 0 ? null : categoryId;
    await _loadProducts();
  }

  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    await _loadProducts(search: query);
  }

  void addProduct(Product product, {List<ProductIngredient>? ingredients}) {
    final selectedIngredients = _normalizeIngredients(
      ingredients ?? product.ingredients,
    );
    final hasKnownStock = product.stockQuantity >= 0;
    if (hasKnownStock && product.stockQuantity == 0) {
      _errorMessage = 'Stock épuisé pour ${product.name}.';
      notifyListeners();
      return;
    }
    final totalQty = _totalQuantityForProduct(product.id);
    if (hasKnownStock && totalQty >= product.stockQuantity) {
      _errorMessage = 'Stock insuffisant pour ${product.name}.';
      notifyListeners();
      return;
    }
    final index = _cart.indexWhere((item) {
      return item.product.id == product.id &&
          _ingredientsEqual(item.ingredients, selectedIngredients);
    });
    if (index == -1) {
      _cart.add(CartItem(product: product, ingredients: selectedIngredients));
    } else {
      final current = _cart[index];
      _cart[index] = current.copyWith(quantity: current.quantity + 1);
    }
    notifyListeners();
  }

  void removeFromCart(String cartItemId) {
    _cart.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int quantity) {
    final index = _cart.indexWhere((item) => item.id == cartItemId);
    if (index == -1) return;
    if (quantity <= 0) {
      removeFromCart(cartItemId);
      return;
    }
    final current = _cart[index];
    final hasKnownStock = current.product.stockQuantity >= 0;
    if (hasKnownStock) {
      final otherQty =
          _totalQuantityForProduct(current.product.id) - current.quantity;
      if (otherQty + quantity > current.product.stockQuantity) {
        _errorMessage = 'Stock insuffisant pour ${current.product.name}.';
        notifyListeners();
        return;
      }
    }
    _cart[index] = current.copyWith(quantity: quantity);
    notifyListeners();
  }

  int _totalQuantityForProduct(int productId) {
    return _cart
        .where((item) => item.product.id == productId)
        .fold<int>(0, (sum, item) => sum + item.quantity);
  }

  List<ProductIngredient> _normalizeIngredients(
    List<ProductIngredient> ingredients,
  ) {
    final filtered = ingredients
        .where((i) => i.id > 0 && i.quantity > 0)
        .toList();
    filtered.sort((a, b) => a.id.compareTo(b.id));
    return filtered;
  }

  bool _ingredientsEqual(
    List<ProductIngredient> a,
    List<ProductIngredient> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
      if ((a[i].quantity - b[i].quantity).abs() > 0.0001) return false;
    }
    return true;
  }

  void updateDiscount(double value) {
    _discountInput = value;
    notifyListeners();
  }

  void updateDiscountMode(DiscountMode mode) {
    _discountMode = mode;
    notifyListeners();
  }

  void updateTaxRate(double value) {
    _taxRate = value.clamp(0, 100);
    notifyListeners();
  }

  void updateShipping(double value) {
    _shipping = value;
    notifyListeners();
  }

  void resetCart() {
    _cart.clear();
    _resetAdjustments();
    notifyListeners();
  }

  void _resetAdjustments() {
    _shipping = 0;
    _discountInput = 0;
    _taxRate = 0;
    _discountMode = DiscountMode.fixed;
  }

  void setCashInHand(double value) {
    _cashInHand = value < 0 ? 0 : value;
    notifyListeners();
  }

  Future<bool> closeRegisterIfNeeded() async {
    try {
      final config = await repository.fetchConfig();
      _applyConfig(config);
      final needsRegister = _parseBool(config['open_register']);
      if (needsRegister) {
        return true;
      }
      final closingAmount = _registerDetails.totalCashAmount > 0
          ? _registerDetails.totalCashAmount
          : _cashInHand;
      await repository.closeRegister(
        cashInHandWhileClosing: closingAmount,
      );
      return true;
    } on ApiException catch (error) {
      final message = error.message ?? '';
      if (message.toLowerCase().contains('register entry not found')) {
        return true;
      }
      _errorMessage = message;
      notifyListeners();
      return false;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> checkout({
    String? notes,
    int paymentTypeId = 1,
    int paymentStatusId = 1,
    double receivedAmount = 0,
    bool shouldPrint = false,
  }) async {
    if (_cart.isEmpty) {
      _errorMessage = 'Ajoutez au moins un produit au panier.';
      notifyListeners();
      return;
    }
    if (_selectedCustomer == null) {
      _errorMessage = 'Sélectionnez un client avant de finaliser la vente.';
      notifyListeners();
      return;
    }
    // Ensure a warehouse is selected (fallback to first cached)
    if (_selectedWarehouseId == null && _warehouses.isNotEmpty) {
      _selectedWarehouse = _warehouses.first;
      _selectedWarehouseId = _selectedWarehouse?.id;
    }
    if (_selectedWarehouseId == null) {
      _errorMessage = 'Sélectionnez un magasin avant de finaliser la vente.';
      notifyListeners();
      return;
    }

    // Offline path: enregistrer la vente localement et sortir sans erreur
    if (_offlineMode) {
      _isProcessingSale = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();
      await _addOfflineSaleFromCart(
        status: OfflineSaleStatus.pending,
        errorMessage: 'En attente de synchronisation',
        notes: notes,
        paymentTypeId: paymentTypeId,
        paymentStatusId: paymentStatusId,
        receivedAmount: receivedAmount,
      );
      _cart.clear();
      _resetAdjustments();
      _isProcessingSale = false;
      _successMessage = 'Vente enregistrée hors ligne. Elle sera synchronisée dès que possible.';
      notifyListeners();
      return;
    }

    _isProcessingSale = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      await repository.submitSale(
        customerId: _selectedCustomer!.id,
        cartItems: _cart,
        grandTotal: grandTotal,
        warehouseId: _selectedWarehouseId,
        discount: discountAmount,
        shipping: _shipping,
        taxRate: _taxRate,
        paymentTypeId: paymentTypeId,
        paymentStatusId: paymentStatusId,
        notes: notes,
        receivedAmount: receivedAmount,
      );
      _cart.clear();
      _resetAdjustments();
      await _loadProducts();
      await loadOrderHistory();
      _successMessage = shouldPrint
          ? 'Vente synchronisée. Impliquez votre flux d\'impression.'
          : 'Vente synchronisée avec succès.';
    } on ApiException catch (error) {
      final message = error.message;
      final lower = message.toLowerCase();
      final isStockIssue =
          lower.contains('stock') || lower.contains('insuffisant') || lower.contains('inventory');
      if (isStockIssue && _selectedCustomer != null) {
        await _addOfflineSaleFromCart(
          status: OfflineSaleStatus.failed,
          errorMessage: 'Stock insuffisant: $message. Contactez le support.',
          notes: notes,
          paymentTypeId: paymentTypeId,
          paymentStatusId: paymentStatusId,
          receivedAmount: receivedAmount,
        );
        _errorMessage = 'Stock insuffisant. Commande enregistrée en échec. Contactez le support.';
      } else {
        // Enregistrer hors ligne si échec réseau ou autre erreur
        await _addOfflineSaleFromCart(
          status: OfflineSaleStatus.pending,
          errorMessage: message,
          notes: notes,
          paymentTypeId: paymentTypeId,
          paymentStatusId: paymentStatusId,
          receivedAmount: receivedAmount,
        );
        _cart.clear();
        _resetAdjustments();
        _errorMessage = null;
        _successMessage = 'Vente enregistrée hors ligne. Elle sera synchronisée dès que possible.';
      }
    } catch (error) {
      await _addOfflineSaleFromCart(
        status: OfflineSaleStatus.pending,
        errorMessage: '$error',
        notes: notes,
        paymentTypeId: paymentTypeId,
        paymentStatusId: paymentStatusId,
        receivedAmount: receivedAmount,
      );
      _cart.clear();
      _resetAdjustments();
      _errorMessage = null;
      _successMessage = 'Vente enregistrée hors ligne. Elle sera synchronisée dès que possible.';
    } finally {
      _isProcessingSale = false;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _loadProducts({String? search}) async {
    _setLoading(true);
    try {
      final items = await repository.fetchProducts(
        warehouseId: _selectedWarehouseId,
        categoryId: _selectedCategoryId,
        search: search ?? _searchQuery,
      );
      _products = items;
      await _cacheProducts(items);
      _errorMessage = null;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      await _loadCachedProducts();
      await _loadCachedCustomers();
      await _loadCachedWarehouses();
      await _restoreSavedSelections();
      final lower = error.message.toLowerCase();
      if (lower.contains('unauth') || lower.contains('authent')) {
        _forceOffline('Mode hors ligne: authentification requise (${error.message}). Cache conserve.');
      } else {
        _forceOffline('Mode hors ligne: ${error.message}');
      }
    } catch (error) {
      _errorMessage = error.toString();
      await _loadCachedProducts();
      await _loadCachedCustomers();
      await _loadCachedWarehouses();
      await _restoreSavedSelections();
      _forceOffline('Mode hors ligne: $error');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadOfflineSales() async {
    _offlineSales = await _offlineSalesStorage.read();
  }

  Future<void> _persistOfflineSales() async {
    await _offlineSalesStorage.write(_offlineSales);
  }

  Future<void> _addOfflineSaleFromCart({
    required OfflineSaleStatus status,
    required String errorMessage,
    String? notes,
    required int paymentTypeId,
    required int paymentStatusId,
    required double receivedAmount,
  }) async {
    final itemsSubTotal = _cart.fold<double>(0, (sum, item) => sum + item.subTotal);
    final discountTotal = discountAmount;
    final discountShare = itemsSubTotal > 0 ? discountTotal / itemsSubTotal : 0;
    final taxRate = _taxRate;
    final saleItems = _cart.map((item) {
      final lineSubtotal = item.subTotal;
      final lineDiscount = lineSubtotal * discountShare;
      final lineTax = (lineSubtotal - lineDiscount) * (taxRate / 100);
      return item.toSalePayload(
        discountAmount: lineDiscount,
        taxAmount: lineTax,
      );
    }).toList();
    final id = _generateOfflineId();
    final sale = OfflineSale(
      id: id,
      customerId: _selectedCustomer!.id,
      warehouseId: _selectedWarehouseId,
      grandTotal: grandTotal,
      discount: discountAmount,
      shipping: _shipping,
      taxRate: _taxRate,
      paymentTypeId: paymentTypeId,
      paymentStatusId: paymentStatusId,
      receivedAmount: receivedAmount,
      notes: notes,
      saleItems: saleItems,
      createdAt: DateTime.now(),
      status: status,
      errorMessage: errorMessage,
    );
    _offlineSales = [sale, ..._offlineSales];
    await _persistOfflineSales();
  }

  String _generateOfflineId() {
    final rand = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'OFF-${DateTime.now().millisecondsSinceEpoch}-$rand';
  }

  Future<void> _syncOfflineSales() async {
    if (_offlineSales.isEmpty || _isSyncingOfflineSales) return;
    final hasPending = _offlineSales.any((sale) => sale.status == OfflineSaleStatus.pending);
    if (!hasPending) return;
    _isSyncingOfflineSales = true;
    try {
      final remaining = <OfflineSale>[];
      var syncedSomething = false;

      for (final sale in _offlineSales) {
        if (sale.status != OfflineSaleStatus.pending) {
          remaining.add(sale);
          continue;
        }
        try {
          await repository.submitOfflineSale(
            customerId: sale.customerId,
            saleItems: sale.saleItems,
            grandTotal: sale.grandTotal,
            warehouseId: sale.warehouseId,
            discount: sale.discount,
            shipping: sale.shipping,
            taxRate: sale.taxRate,
            paymentTypeId: sale.paymentTypeId,
            paymentStatusId: sale.paymentStatusId,
            notes: sale.notes,
            receivedAmount: sale.receivedAmount,
          );
          syncedSomething = true;
        } on ApiException catch (error) {
          final msg = error.message;
          final lower = msg.toLowerCase();
          final isStock = lower.contains('stock') ||
              lower.contains('insuffisant') ||
              lower.contains('inventory');
          if (isStock) {
            remaining.add(
              sale.copyWith(
                status: OfflineSaleStatus.failed,
                errorMessage: 'Stock insuffisant: $msg. Contactez le support.',
              ),
            );
          } else {
            remaining.add(sale.copyWith(errorMessage: msg));
          }
        } catch (error) {
          remaining.add(sale.copyWith(errorMessage: '$error'));
        }
      }

      _offlineSales = remaining;
      await _persistOfflineSales();
      if (syncedSomething) {
        _lastSyncAt = DateTime.now();
        notifyListeners();
      }
    } finally {
      _isSyncingOfflineSales = false;
    }
  }

  void _applyFrontSetting(Map<String, dynamic> payload) {
    final data = payload['data'] ?? payload;
    final value = data['value'] ?? data['data'] ?? data;
    final frontStoreId = value['default_warehouse'] ??
        value['default_warehouse_id'] ??
        value['warehouse_id'] ??
        value['store_id'];
    final selectedId = _selectedWarehouseId;
    final shouldApplyCurrency = selectedId == null ||
        frontStoreId == null ||
        int.tryParse('$frontStoreId') == selectedId;
    if (shouldApplyCurrency) {
      final currencyId = value['currency_id'] ?? value['currency'];
      if (currencyId != null) {
        _currencyId = int.tryParse('$currencyId');
      }
      final symbol = value['currency_symbol'] ?? value['currencySymbol'];
      if (symbol != null) {
        _currencySymbol = symbol.toString();
      }
      final currencyRight = value['is_currency_right'];
      if (currencyRight != null) {
        _isCurrencySymbolRight = _parseBool(currencyRight);
      }
    }
    _companyName = value['company_name']?.toString() ?? _companyName;
    _companyAddress = value['address']?.toString() ?? _companyAddress;
    _companyEmail = value['email']?.toString() ?? _companyEmail;
    _companyPhone = value['phone']?.toString() ?? _companyPhone;
    final logo = value['logo'] ?? value['logo_url'] ?? value['logoUrl'];
    if (logo != null) {
      _companyLogo = logo.toString();
    }
    if (frontStoreId != null && _selectedWarehouseId == null) {
      _selectedWarehouseId = int.tryParse('$frontStoreId');
    }
  }

  void _applyConfig(Map<String, dynamic> config) {
    if (config.containsKey('is_currency_right')) {
      final next = _parseBool(config['is_currency_right']);
      if (_isCurrencySymbolRight != next) {
        _isCurrencySymbolRight = next;
      }
    }
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  void _assignDefaultWarehouse() {
    if (_warehouses.isEmpty) return;
    if (_selectedWarehouseId != null) {
      _selectedWarehouse = _warehouses.firstWhere(
        (w) => w.id == _selectedWarehouseId,
        orElse: () => _warehouses.first,
      );
    } else {
      _selectedWarehouse = _warehouses.first;
      _selectedWarehouseId = _selectedWarehouse?.id;
    }
    _applyWarehouseCurrency(_selectedWarehouse);
  }

  void _applyWarehouseCurrency(Warehouse? warehouse) {
    if (warehouse?.currencyId != null) {
      _currencyId = warehouse!.currencyId;
    }
    if (warehouse?.currencySymbol != null &&
        warehouse!.currencySymbol!.isNotEmpty) {
      _currencySymbol = warehouse.currencySymbol!;
    }
    if (warehouse?.isCurrencySymbolRight != null) {
      _isCurrencySymbolRight = warehouse!.isCurrencySymbolRight!;
    }
  }

  RegisterDetails _buildRegisterDetailsFromOrders(List<OrderSummary> orders) {
    final totalGrand =
        orders.fold<double>(0, (sum, order) => sum + order.grandTotal);
    final totalPaid =
        orders.fold<double>(0, (sum, order) => sum + order.paidAmount);
    final items =
        orders.fold<int>(0, (sum, order) => sum + (order.itemCount));
    return RegisterDetails(
      cashInHand: _cashInHand,
      totalCashAmount: totalPaid,
      salesAmount: totalGrand,
      salesReturnAmount: 0,
      cashPayments: totalPaid,
      salesCount: orders.length,
      itemsCount: items,
    );
  }

  Future<void> _loadHistoryResetPreference() async {
    if (_activeUserLabel == null) {
      _historyResetAfter = null;
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final key = _historyResetKey;
    final stored = prefs.getString(key);
    _historyResetAfter =
        stored != null ? DateTime.tryParse(stored) : null;
  }

  Future<void> _persistHistoryResetPreference() async {
    if (_activeUserLabel == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = _historyResetKey;
    if (_historyResetAfter != null) {
      await prefs.setString(key, _historyResetAfter!.toIso8601String());
    } else {
      await prefs.remove(key);
    }
  }

  String get _historyResetKey =>
      'pos_history_reset_${_activeUserLabel ?? 'default'}';

  Future<void> _loadHistoryUsers() async {
    try {
      final names = await repository.fetchUsers();
      if (names.isEmpty) return;
      _historyUsers = names;
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  String get _historyCacheKey {
    final label = _activeUserLabel?.toLowerCase();
    if (label == 'admin') {
      return '${_cachedHistoryKeyPrefix}all';
    }
    return '$_cachedHistoryKeyPrefix${_activeUserLabel ?? 'default'}';
  }

  Map<String, dynamic> _productToMap(Product product) {
    // Store in a shape compatible with Product.fromJson (attributes map).
    return {
      'id': product.id,
      'attributes': {
        'name': product.name,
        'code': product.code,
        'product_price': product.price,
        'product_cost': product.cost,
        'category_id': product.categoryId,
        'ingredient_links': product.ingredients
            .map((ingredient) => ingredient.toJson())
            .toList(),
        'stock': {'quantity': product.stockQuantity},
        'order_tax': product.taxValue,
        'tax_type': product.taxType,
        'product_unit': product.productUnitId,
        'sale_unit': product.saleUnitId,
        'stock_alert': product.stockAlert,
        'product_unit_name': product.unitLabel,
        'image_url': product.imageUrl,
      },
    };
  }

  Map<String, dynamic> _orderToMap(OrderSummary order) {
    final saleItems = order.productNames
        .map((name) => {
              'product_name': name,
              'name': name,
            })
        .toList();
    return {
      'id': order.id,
      'attributes': {
        'reference_code': order.referenceCode,
        'customer_name': order.customerName,
        'user_id': order.userId,
        'status': order.status,
        'payment_status': order.paymentStatus,
        'grand_total': order.grandTotal,
        'paid_amount': order.paidAmount,
        'item_count': order.itemCount,
        'product_names': order.productNames,
        'sale_items': saleItems,
        'created_at': order.createdAt?.toIso8601String(),
      },
    };
  }

  Map<String, dynamic> _registerToMap(RegisterDetails details) {
    return {
      'cashInHand': details.cashInHand,
      'totalCashAmount': details.totalCashAmount,
      'salesAmount': details.salesAmount,
      'salesReturnAmount': details.salesReturnAmount,
      'cashPayments': details.cashPayments,
      'salesCount': details.salesCount,
      'itemsCount': details.itemsCount,
    };
  }

  Future<void> _cacheProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = products.map(_productToMap).toList();
    await prefs.setString(_cachedProductsKey, jsonEncode(payload));
  }

  Future<void> _cacheFrontSetting(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedFrontSettingsKey, jsonEncode(payload));
  }

  Future<void> _loadCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cachedProductsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _products = decoded
            .whereType<Map>()
            .map((e) {
              final map = e.cast<String, dynamic>();
              // Backward-compat for older flat cache shape.
              if (!map.containsKey('attributes')) {
                map['attributes'] = {
                  'name': map['name'],
                  'code': map['code'],
                  'product_price': map['price'],
                  'product_cost': map['cost'],
                  'category_id': map['categoryId'],
                  'stock': {'quantity': map['stockQuantity']},
                  'order_tax': map['taxValue'],
                  'tax_type': map['taxType'],
                  'product_unit': map['productUnitId'],
                  'sale_unit': map['saleUnitId'],
                  'stock_alert': map['stockAlert'],
                  'product_unit_name': map['unitLabel'],
                  'image_url': map['imageUrl'],
                };
              }
              return Product.fromJson(map);
            })
            .toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _cacheHistory(
    List<OrderSummary> orders,
    RegisterDetails details,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _historyCacheKey;
    final data = {
      'orders': orders.map(_orderToMap).toList(),
      'register': _registerToMap(details),
    };
    await prefs.setString(key, jsonEncode(data));
  }

  Future<void> _loadCachedHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _historyCacheKey;
    var raw = prefs.getString(key);
    // Fallback to legacy key if needed (for caches écrites avant la clé admin "all")
    if ((raw == null || raw.isEmpty) && _activeUserLabel != null) {
      final legacyKey = '$_cachedHistoryKeyPrefix${_activeUserLabel}';
      raw = prefs.getString(legacyKey);
    }
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final ordersRaw = decoded['orders'];
        if (ordersRaw is List) {
          _recentOrders = ordersRaw
              .whereType<Map>()
              .map((e) => OrderSummary.fromJson(e.cast<String, dynamic>()))
              .toList();
          // Enrichir les noms de produits si vide dans le cache
          final needsNames = _recentOrders.any(
            (o) => (o.productNames.isEmpty && o.itemsDetail.isEmpty),
          );
          if (needsNames) {
            _recentOrders = await loadProductNamesForOrders(_recentOrders);
          }
        }
        final registerRaw = decoded['register'];
        if (registerRaw is Map) {
          _registerDetails = RegisterDetails.fromJson(
            registerRaw.cast<String, dynamic>(),
          );
          _cashInHand = _registerDetails.cashInHand;
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _cacheCustomers(List<Customer> customers) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = customers
        .map((c) => {
              'id': c.id,
              'attributes': {
                'name': c.name,
                'email': c.email,
                'phone': c.phone,
              },
            })
        .toList();
    await prefs.setString(_cachedCustomersKey, jsonEncode(payload));
  }

  Future<void> _cacheWarehouses(List<Warehouse> warehouses) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = warehouses
        .map((w) => {
              'id': w.id,
              'attributes': {
                'name': w.name,
              },
            })
        .toList();
    await prefs.setString(_cachedWarehousesKey, jsonEncode(payload));
  }

  Future<void> _loadCachedCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cachedCustomersKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _customers = decoded
            .whereType<Map>()
            .map((e) => Customer.fromJson(e.cast<String, dynamic>()))
            .toList();
      }
      if (_customers.isEmpty) {
        _customers = [Customer(id: 0, name: 'Client')];
      }
    } catch (_) {}
  }

  Future<void> _loadCachedWarehouses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cachedWarehousesKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _warehouses = decoded
            .whereType<Map>()
            .map((e) => Warehouse.fromJson(e.cast<String, dynamic>()))
            .toList();
      }
    } catch (_) {}
  }

  Future<void> _loadCachedFrontSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cachedFrontSettingsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        _applyFrontSetting(decoded.cast<String, dynamic>());
      }
    } catch (_) {}
  }

  Future<void> _persistSelectedCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    if (_selectedCustomer != null) {
      await prefs.setInt(_selectedCustomerKey, _selectedCustomer!.id);
    }
  }

  Future<void> _persistSelectedWarehouse() async {
    final prefs = await SharedPreferences.getInstance();
    if (_selectedWarehouseId != null) {
      await prefs.setInt(_selectedWarehouseKey, _selectedWarehouseId!);
    }
  }

  Future<void> _restoreSavedSelections() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCustomerId = prefs.getInt(_selectedCustomerKey);
    if (savedCustomerId != null) {
      final found = _customers.where((c) => c.id == savedCustomerId).toList();
      if (found.isNotEmpty) {
        _selectedCustomer = found.first;
      }
    }
    final savedWarehouseId = prefs.getInt(_selectedWarehouseKey);
    if (savedWarehouseId != null) {
      final found = _warehouses.where((w) => w.id == savedWarehouseId).toList();
      if (found.isNotEmpty) {
        _selectedWarehouse = found.first;
        _selectedWarehouseId = found.first.id;
      }
    }
    _ensureDefaultSelections();
  }

  void _ensureDefaultSelections() {
    if (_selectedCustomer == null && _customers.isNotEmpty) {
      _selectedCustomer = _customers.first;
      _persistSelectedCustomer();
    }
    if (_selectedWarehouse == null && _warehouses.isNotEmpty) {
      _selectedWarehouse = _warehouses.first;
      _selectedWarehouseId = _selectedWarehouse!.id;
      _persistSelectedWarehouse();
    }
  }

  List<OrderSummary> _offlineOrders() {
    return _offlineSales.map((sale) {
      final matched = _customers.firstWhere(
        (c) => c.id == sale.customerId,
        orElse: () => Customer(id: sale.customerId, name: 'Client local'),
      );
      final customerName = matched.name;
      final items = sale.saleItems
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      final names = items
          .map((item) => item['name']?.toString() ?? '')
          .where((n) => n.trim().isNotEmpty)
          .toList();
      final details = items
          .map((item) {
            final name = item['name']?.toString() ?? '';
            final qtyRaw = item['quantity'];
            double qty = 0;
            if (qtyRaw is num) {
              qty = qtyRaw.toDouble();
            } else if (qtyRaw is String) {
              qty = double.tryParse(qtyRaw) ?? 0;
            }
            final ingredientsRaw = item['ingredients'];
            final ingredients = ingredientsRaw is List
                ? ingredientsRaw
                    .whereType<Map>()
                    .map((i) => ProductIngredient.fromJson(i.cast<String, dynamic>()))
                    .where((i) => i.id > 0 && i.name.trim().isNotEmpty)
                    .toList()
                : <ProductIngredient>[];
            return OrderItemSummary(
              name: name,
              quantity: qty,
              ingredients: ingredients,
            );
          })
          .where((d) => d.name.trim().isNotEmpty)
          .toList();
      final itemCount = details.isNotEmpty
          ? details.fold<int>(0, (sum, d) => sum + d.quantity.toInt())
          : names.length;
      final statusLabel = sale.status == OfflineSaleStatus.pending ? 'LOCAL' : 'ERREUR';
      return OrderSummary(
        id: sale.hashCode,
        referenceCode: sale.id,
        customerName: customerName,
        userName: _activeUserLabel,
        userId: null,
        status: statusLabel,
        paymentStatus: sale.paymentStatusId.toString(),
        grandTotal: sale.grandTotal,
        paidAmount: sale.grandTotal,
        itemCount: itemCount,
        productNames: names,
        itemsDetail: details,
        createdAt: sale.createdAt,
        isLocal: true,
      );
    }).toList();
  }
}
