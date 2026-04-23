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
import '../../../core/models/product_option.dart';
import '../../../core/models/currency.dart';
import '../../../core/models/payment_method.dart';
import '../../../core/models/register_details.dart';
import '../../../core/models/warehouse.dart';
import '../../../core/models/offline_sale.dart';
import '../../../core/models/discount.dart';
import '../../../core/models/shipping_method.dart';
import '../../../core/utils/media_url.dart';
import '../data/pos_repository.dart';
import '../data/offline_sales_storage.dart';
import '../models/user_summary.dart';
import '../models/printing_service.dart';

enum DiscountMode { fixed, percentage }

class PosController extends ChangeNotifier {
  PosController({required this.repository});

  final PosRepository repository;
  final OfflineSalesStorage _offlineSalesStorage = OfflineSalesStorage();
  static const _cachedProductsKey = 'pos_cached_products';
  static const _cachedHistoryKeyPrefix = 'pos_cached_history_';
  static const _cachedCustomersKey = 'pos_cached_customers';
  static const _cachedWarehousesKey = 'pos_cached_warehouses';
  static const _cachedCategoriesKey = 'pos_cached_categories';
  static const _cachedPaymentMethodsKey = 'pos_cached_payment_methods';
  static const _cachedShippingMethodsKey = 'pos_cached_shipping_methods';
  static const _cachedDiscountsKey = 'pos_cached_discounts';
  static const _cachedConfigKey = 'pos_cached_config';
  static const _cachedFrontSettingsKey = 'pos_cached_front_settings';
  static const _cachedPrintingServicesKey = 'pos_cached_printing_services';
  static const _selectedCustomerKey = 'pos_selected_customer';
  static const _selectedWarehouseKey = 'pos_selected_warehouse';

  bool _isLoading = true;
  bool _isProcessingSale = false;
  List<Product> _products = [];
  List<Customer> _customers = [];
  List<Warehouse> _warehouses = [];
  List<ProductCategory> _categories = [];
  List<PaymentMethod> _paymentMethods = [];
  List<ShippingMethod> _shippingMethods = [];
  List<Discount> _discounts = [];
  List<PrintingService> _printingServices = [];
  final List<CartItem> _cart = [];
  Customer? _selectedCustomer;
  Warehouse? _selectedWarehouse;
  ShippingMethod? _selectedShippingMethod;
  int? _selectedWarehouseId;
  int? _selectedCategoryId;
  double _shipping = 0;
  double _discountInput = 0;
  DiscountMode _discountMode = DiscountMode.fixed;
  double _taxRate = 0;
  bool _loyaltyEnabled = false;
  bool _allowLoyaltyRedeem = true;
  int _loyaltyPointsPerOrder = 0;
  int _loyaltyPointsPerItem = 0;
  double _loyaltyAmountPerPoint = 0;
  double _loyaltyPointValue = 0;
  double _loyaltyRedeemInput = 0;
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
  String? _historySourceFilter;
  String? _historyStatusFilter;
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
  List<ShippingMethod> get shippingMethods => _shippingMethods;
  ShippingMethod? get selectedShippingMethod => _selectedShippingMethod;
  List<Discount> get discounts => List.unmodifiable(_discounts);
  List<PrintingService> get printingServices =>
      List.unmodifiable(_printingServices);
  List<PrintingService> get activePrintingServices {
    final storeId = _selectedWarehouseId;
    final filtered = _printingServices.where((service) {
      if (!service.isActive) return false;
      if (storeId == null) return true;
      return service.storeId == storeId;
    }).toList();
    filtered.sort((a, b) {
      final order = a.sortOrder.compareTo(b.sortOrder);
      return order != 0 ? order : a.name.compareTo(b.name);
    });
    return List.unmodifiable(filtered);
  }

  PrintingService? get primaryReceiptService {
    final services = activePrintingServices;
    for (final service in services) {
      if (service.isReceipt) return service;
    }
    return services.isNotEmpty ? services.first : null;
  }

  Customer? get selectedCustomer => _selectedCustomer;
  Warehouse? get selectedWarehouse => _selectedWarehouse;
  int? get selectedCategoryId => _selectedCategoryId;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  double get shipping => _calculateShipping();
  double get discountInput => _discountInput;
  double get taxRate => _taxRate;
  DiscountMode get discountMode => _discountMode;
  bool get loyaltyEnabled => _loyaltyEnabled;
  bool get allowLoyaltyRedeem => _allowLoyaltyRedeem;
  int get selectedCustomerPoints => _selectedCustomer?.loyaltyPoints ?? 0;
  double get loyaltyPointValue => _loyaltyPointValue;
  double get loyaltyAvailableAmount =>
      selectedCustomerPoints * _loyaltyPointValue;
  double get loyaltyRedeemAmount => _effectiveLoyaltyRedeemAmount();
  double get loyaltyMaxRedeemAmount => _maxLoyaltyRedeemAmount();
  int get loyaltyEstimatedPoints => _estimateLoyaltyPoints();
  int get loyaltyRedeemPoints => _loyaltyPointValue > 0
      ? (loyaltyRedeemAmount / _loyaltyPointValue).floor()
      : 0;
  List<double> get discountPresets {
    final candidates = _discountMode == DiscountMode.percentage
        ? _percentDiscountPresets()
        : _fixedDiscountPresets();
    if (candidates.isNotEmpty) return candidates;
    return _discountMode == DiscountMode.percentage
        ? <double>[0, 5, 10, 15, 20]
        : <double>[0, 100, 500, 1000, 2000];
  }

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
    return List.unmodifiable(_recentOrders.where((order) {
      if (_historyUserFilter != null && order.userId != _historyUserFilter) {
        return false;
      }
      if (_historySourceFilter == 'pos' && order.isKioskOrder) {
        return false;
      }
      if (_historySourceFilter == 'kiosk' && !order.isKioskOrder) {
        return false;
      }
      if (_historyStatusFilter != null &&
          order.status.toLowerCase() != _historyStatusFilter!.toLowerCase()) {
        return false;
      }
      return true;
    }).toList());
  }

  int? get historyUserIdFilter => _historyUserFilter;
  int get historyHours => _historyHours;
  String? get historySourceFilter => _historySourceFilter;
  String? get historyStatusFilter => _historyStatusFilter;
  List<String> get availableHistoryStatuses {
    final values = _recentOrders
        .map((order) => order.status.trim())
        .where((status) => status.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return List.unmodifiable(values);
  }

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
  int get pendingOfflineSalesCount => _offlineSales
      .where((sale) => sale.status == OfflineSaleStatus.pending)
      .length;
  int get failedOfflineSalesCount => _offlineSales
      .where((sale) => sale.status == OfflineSaleStatus.failed)
      .length;
  bool get isSyncingOfflineSales => _isSyncingOfflineSales;
  int get ordersCount => _registerDetails.salesCount > 0
      ? _registerDetails.salesCount
      : _recentOrders.length;
  int get itemsSold => _registerDetails.itemsCount > 0
      ? _registerDetails.itemsCount
      : _recentOrders.fold(0, (sum, order) => sum + (order.itemCount));

  int get kioskQueueNumber {
    final count = _recentOrders.where((order) => order.isKioskOrder).length;
    return count + 1;
  }

  List<Product> get products {
    Iterable<Product> filtered = _products;
    if (_selectedCategoryId != null && _selectedCategoryId! > 0) {
      filtered = filtered.where(
        (product) => product.categoryId == _selectedCategoryId,
      );
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((product) =>
          product.name.toLowerCase().contains(query) ||
          product.code.toLowerCase().contains(query));
    }
    return filtered.toList();
  }

  List<CartItem> get cartItems => List.unmodifiable(_cart);

  int get totalQuantity => _cart.fold(0, (sum, item) => sum + item.quantity);

  double get itemsSubTotal =>
      _cart.fold<double>(0, (sum, item) => sum + item.subTotal);

  double get manualDiscountAmount {
    if (_discountMode == DiscountMode.percentage) {
      return itemsSubTotal * (_discountInput / 100);
    }
    return _discountInput;
  }

  double get discountAmount => manualDiscountAmount + loyaltyRedeemAmount;

  double get subTotal {
    final value = itemsSubTotal - discountAmount;
    return value < 0 ? 0 : value;
  }

  double get taxTotal => subTotal * (_taxRate / 100);

  double get grandTotal => subTotal + taxTotal + shipping;

  double _calculateShipping() {
    final method = _selectedShippingMethod;
    if (method == null) return _shipping;
    if (method.isFree) return 0;
    if (method.isManual) return _shipping;
    if (method.isOrderPercent) {
      return (subTotal * (method.value / 100)).clamp(0, double.infinity);
    }
    if (method.isPerItem) {
      return (totalQuantity * method.value).clamp(0, double.infinity);
    }
    return _shipping;
  }

  double _totalBeforeLoyalty() {
    final value = itemsSubTotal - manualDiscountAmount;
    final subTotalBefore = value < 0 ? 0 : value;
    final taxBefore = subTotalBefore * (_taxRate / 100);
    return subTotalBefore + taxBefore + shipping;
  }

  double _maxLoyaltyRedeemAmount() {
    if (!_loyaltyEnabled) return 0;
    if (!_allowLoyaltyRedeem) return 0;
    if (_selectedCustomer == null || _selectedCustomer!.id == 0) return 0;
    if (_loyaltyPointValue <= 0) return 0;
    final available = loyaltyAvailableAmount;
    final base = _totalBeforeLoyalty();
    return min(available, base);
  }

  double _effectiveLoyaltyRedeemAmount() {
    if (!_allowLoyaltyRedeem) return 0;
    final maxAmount = _maxLoyaltyRedeemAmount();
    if (_loyaltyRedeemInput <= 0) return 0;
    if (_loyaltyRedeemInput >= maxAmount) return maxAmount;
    return _loyaltyRedeemInput;
  }

  int _estimateLoyaltyPoints() {
    if (!_loyaltyEnabled) return 0;
    if (_selectedCustomer == null || _selectedCustomer!.id == 0) return 0;
    int points = 0;
    if (_cart.isNotEmpty && _loyaltyPointsPerOrder > 0) {
      points += _loyaltyPointsPerOrder;
    }
    if (_loyaltyPointsPerItem > 0) {
      final itemCount = _cart.fold<int>(0, (sum, item) => sum + item.quantity);
      points += itemCount * _loyaltyPointsPerItem;
    }
    if (_loyaltyAmountPerPoint > 0) {
      points += (grandTotal / _loyaltyAmountPerPoint).floor();
    }
    return points;
  }

  List<double> _percentDiscountPresets() {
    final values = _discounts
        .where((d) => d.isActive && d.isPercent && d.scope == 'order')
        .map((d) => d.value)
        .toList();
    values.sort();
    return values.toSet().toList();
  }

  List<double> _fixedDiscountPresets() {
    final values = _discounts
        .where((d) => d.isActive && d.isFixed && d.scope == 'order')
        .map((d) => d.value)
        .toList();
    values.sort();
    return values.toSet().toList();
  }

  void _applyShippingMethods(List<ShippingMethod> methods) {
    final active = methods.where((method) => method.isActive).toList();
    active.sort((a, b) => a.name.compareTo(b.name));
    _shippingMethods = active;
    if (_shippingMethods.isEmpty) {
      _selectedShippingMethod = null;
      return;
    }
    if (_selectedShippingMethod != null) {
      final matched = _shippingMethods.where(
        (method) => method.id == _selectedShippingMethod!.id,
      );
      if (matched.isNotEmpty) {
        _selectedShippingMethod = matched.first;
        return;
      }
    }
    final manual = _shippingMethods.where((method) => method.isManual);
    _selectedShippingMethod =
        manual.isNotEmpty ? manual.first : _shippingMethods.first;
    if (_selectedShippingMethod?.isFree == true) {
      _shipping = 0;
    }
  }

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
      await _loadCachedCategories();
      await _loadCachedPaymentMethods();
      await _loadCachedDiscounts();
      await _loadCachedShippingMethods();
      await _loadCachedConfig();
      await _loadCachedFrontSettings();
      await _loadCachedPrintingServices();
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
        repository.fetchDiscounts(),
        repository.fetchShippingMethods(),
      ]);
      _customers = List<Customer>.from(results[0] as List<Customer>);
      _normalizeCustomers();
      final frontSettings = results[1] as Map<String, dynamic>;
      _applyFrontSetting(frontSettings);
      await _cacheFrontSetting(frontSettings);
      _categories =
          List<ProductCategory>.from(results[2] as List<ProductCategory>);
      await _cacheCategories(_categories);
      _warehouses = List<Warehouse>.from(results[3] as List<Warehouse>);
      _paymentMethods =
          List<PaymentMethod>.from(results[4] as List<PaymentMethod>);
      _paymentMethods.sort((a, b) {
        if (a.isDefault == b.isDefault) return a.name.compareTo(b.name);
        return a.isDefault ? -1 : 1;
      });
      await _cachePaymentMethods(_paymentMethods);
      _applyConfig(results[5] as Map<String, dynamic>);
      await _cacheConfig(results[5] as Map<String, dynamic>);
      _discounts = List<Discount>.from(results[6] as List<Discount>);
      await _cacheDiscounts(_discounts);
      final shippingMethods =
          List<ShippingMethod>.from(results[7] as List<ShippingMethod>);
      _applyShippingMethods(shippingMethods);
      await _cacheShippingMethods(_shippingMethods);
      await _refreshPrintingServices();
      await _cacheCustomers(_customers);
      await _cacheWarehouses(_warehouses);
      _assignDefaultWarehouse();
      await _restoreSavedSelections();
      await _loadProducts();
      _ensureDefaultSelections();
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
    if (_offlineMode) {
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();
      return;
    }
    if (!skipSyncOffline) {
      try {
        await _syncOfflineSales();
      } on ApiException catch (error) {
        final lower = error.message.toLowerCase();
        if (lower.contains('unauth')) {
          _forceOffline(
              'Mode hors ligne: authentification requise (${error.message}). Cache conserve.');
          return;
        }
        rethrow;
      }
    }
    try {
      await _loadProducts();
      await loadOrderHistory();
      await _refreshFrontSetting();
      await _refreshPrintingServices();
      _lastSyncAt = DateTime.now();
      notifyListeners();
    } on ApiException catch (error) {
      final lower = error.message.toLowerCase();
      if (lower.contains('unauth')) {
        _forceOffline(
            'Authentification requise (${error.message}). Passage en mode hors ligne (cache).');
        return;
      }
      _forceOffline(
          'Impossible de rafraichir (${error.message}). Cache utilise.');
    } catch (_) {
      _forceOffline(
          'Impossible de rafraichir. Cache utilise en mode hors ligne.');
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
      final storeId = _selectedWarehouseId ??
          _selectedWarehouse?.id ??
          (_warehouses.isNotEmpty ? _warehouses.first.id : null);
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
    if (_offlineMode ||
        _isLoading ||
        _isProcessingSale ||
        _isSyncingOfflineSales) {
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
      final remaining = _offlineSales.length;
      if (remaining == 0) {
        _successMessage = 'Toutes les commandes locales ont été envoyées.';
        _errorMessage = null;
      } else if (remaining < pendingBefore) {
        final sent = pendingBefore - remaining;
        _successMessage =
            '$sent commande(s) ont été envoyées. $remaining en attente (consultez les erreurs).';
      } else {
        _errorMessage =
            'Synchronisation impossible. Vérifiez les commandes locales.';
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
      if (!_isConnectivityNoise(reason)) {
        _errorMessage ??= reason;
      }
      notifyListeners();
      return;
    }
    _offlineMode = true;
    _errorMessage = _isConnectivityNoise(reason) ? null : reason;
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
                    note: o.note,
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
        _forceOffline(
            'Mode hors ligne: authentification requise (${error.message}). Cache conserve.');
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

  void updateHistorySourceFilter(String? source) {
    if (_historySourceFilter == source) return;
    _historySourceFilter = source;
    notifyListeners();
  }

  void updateHistoryStatusFilter(String? status) {
    if (_historyStatusFilter == status) return;
    _historyStatusFilter = status;
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

  Future<List<OrderSummary>> loadProductNamesForOrders(
      List<OrderSummary> orders) async {
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
        updated.add(_copyOrderWithNames(
            order, names.isNotEmpty ? names : order.productNames));
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
      note: order.note,
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
      note: order.note,
      status: order.status,
      paymentStatus: order.paymentStatus,
      grandTotal: order.grandTotal,
      paidAmount: order.paidAmount,
      itemCount: order.itemCount,
      productNames: details.productNames.isNotEmpty
          ? details.productNames
          : order.productNames,
      itemsDetail: details.itemsDetail.isNotEmpty
          ? details.itemsDetail
          : order.itemsDetail,
      createdAt: order.createdAt,
      isLocal: order.isLocal,
    );
  }

  void selectCustomer(Customer? customer) {
    final previousId = _selectedCustomer?.id;
    _selectedCustomer = customer;
    if (previousId != customer?.id) {
      _loyaltyRedeemInput = 0;
    }
    _persistSelectedCustomer();
    notifyListeners();
  }

  Future<Customer?> createCustomer({
    required String name,
    String? email,
    String? phone,
    String? address,
    String? note,
  }) async {
    if (_offlineMode) {
      _errorMessage = 'Mode hors ligne: impossible d\'ajouter un client.';
      notifyListeners();
      return null;
    }
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      _errorMessage = 'Le nom du client est requis.';
      notifyListeners();
      return null;
    }
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      final created = await repository.createCustomer(
        name: trimmedName,
        email: email,
        phone: phone,
        address: address,
        note: note,
      );
      _customers = _customers.where((c) => c.id != created.id).toList()
        ..add(created);
      _selectedCustomer = created;
      _normalizeCustomers();
      await _cacheCustomers(_customers);
      await _persistSelectedCustomer();
      _successMessage = 'Client ajouté.';
      notifyListeners();
      return created;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
      return null;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> selectWarehouse(Warehouse? warehouse) async {
    _selectedWarehouse = warehouse;
    _selectedWarehouseId = warehouse?.id;
    _applyWarehouseCurrency(warehouse);
    await _persistSelectedWarehouse();
    if (_offlineMode) {
      notifyListeners();
      return;
    }
    await _loadProducts();
  }

  void selectShippingMethod(ShippingMethod? method) {
    _selectedShippingMethod = method;
    if (method == null || method.isFree) {
      _shipping = 0;
    }
    notifyListeners();
  }

  Future<void> selectCategory(int? categoryId) async {
    _selectedCategoryId = categoryId == 0 ? null : categoryId;
    notifyListeners();
  }

  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    notifyListeners();
  }

  void addProduct(Product product, {List<ProductOption>? options}) {
    final selectedOptions = _normalizeOptions(
      options ?? product.options,
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
          _optionsEqual(item.options, selectedOptions);
    });
    if (index == -1) {
      _cart.add(CartItem(product: product, options: selectedOptions));
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

  List<ProductOption> _normalizeOptions(
    List<ProductOption> options,
  ) {
    final filtered = options.where((o) => o.id > 0 && o.quantity > 0).toList();
    filtered.sort((a, b) => a.id.compareTo(b.id));
    return filtered;
  }

  bool _optionsEqual(
    List<ProductOption> a,
    List<ProductOption> b,
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

  void updateLoyaltyRedeemAmount(double value) {
    if (!_allowLoyaltyRedeem) {
      _loyaltyRedeemInput = 0;
      notifyListeners();
      return;
    }
    _loyaltyRedeemInput = value < 0 ? 0 : value;
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
    if (_selectedShippingMethod != null && !_selectedShippingMethod!.isManual) {
      return;
    }
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
    _loyaltyRedeemInput = 0;
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
    String? saleStatus,
    List<CartItem>? cartItemsOverride,
    double? discountAmountOverride,
    double? shippingOverride,
    double? taxRateOverride,
    double? grandTotalOverride,
  }) async {
    final cartItems = cartItemsOverride ?? _cart;
    if (cartItems.isEmpty) {
      _errorMessage = 'Ajoutez au moins un produit au panier.';
      notifyListeners();
      return;
    }
    final customerId = _selectedCustomer?.id ?? 0;
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

    _isProcessingSale = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      await _addOfflineSaleFromCart(
        cartItems: cartItems,
        grandTotalValue: grandTotalOverride,
        discountAmountValue: discountAmountOverride,
        shippingValue: shippingOverride,
        taxRateValue: taxRateOverride,
        status: OfflineSaleStatus.pending,
        errorMessage: 'En attente de synchronisation',
        notes: notes,
        saleStatus: saleStatus,
        paymentTypeId: paymentTypeId,
        paymentStatusId: paymentStatusId,
        receivedAmount: receivedAmount,
      );
      final shouldApplyLoyalty =
          loyaltyEnabled && customerId > 0 && paymentStatusId != 2;
      final effectiveGrandTotal = grandTotalOverride ?? grandTotal;
      final canEarnPoints = shouldApplyLoyalty &&
          (paymentStatusId != 3 || receivedAmount >= effectiveGrandTotal);
      _applyLocalLoyaltyAdjustments(
        earned: canEarnPoints ? loyaltyEstimatedPoints : 0,
        redeemed: shouldApplyLoyalty ? loyaltyRedeemPoints : 0,
      );
      _cart.clear();
      _resetAdjustments();
      _successMessage = shouldPrint
          ? 'Commande enregistrée localement et impression lancée. La synchronisation partira en arrière-plan.'
          : 'Commande enregistrée localement. La synchronisation partira en arrière-plan.';
      if (!_offlineMode) {
        unawaited(_syncLocalQueueInBackground());
      }
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isProcessingSale = false;
      notifyListeners();
    }
  }

  Future<bool> submitKioskOrder({
    required List<CartItem> items,
    required int queueNumber,
    required String serviceMode,
    String? customerName,
    double receivedAmount = 0,
    int paymentTypeId = 0,
    String? saleStatus,
  }) async {
    if (items.isEmpty) {
      _errorMessage = 'Ajoutez au moins un produit au panier.';
      notifyListeners();
      return false;
    }
    if (_offlineMode) {
      _errorMessage = 'Mode hors ligne: la borne nécessite une connexion.';
      notifyListeners();
      return false;
    }
    if (_selectedWarehouseId == null && _warehouses.isNotEmpty) {
      _selectedWarehouse = _warehouses.first;
      _selectedWarehouseId = _selectedWarehouse?.id;
    }
    if (_selectedWarehouseId == null) {
      _errorMessage = 'Sélectionnez un magasin avant de finaliser la vente.';
      notifyListeners();
      return false;
    }

    _isProcessingSale = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      final itemsSubTotal =
          items.fold<double>(0, (sum, item) => sum + item.subTotal);
      final taxTotal = itemsSubTotal * (_taxRate / 100);
      final grandTotal = itemsSubTotal + taxTotal;
      final normalizedMode =
          serviceMode.trim().isEmpty ? 'SUR PLACE' : serviceMode.toUpperCase();
      final normalizedCustomer = (customerName ?? '').trim();
      final note = normalizedCustomer.isNotEmpty
          ? 'BORNE #$queueNumber - $normalizedMode - CLIENT: $normalizedCustomer'
          : 'BORNE #$queueNumber - $normalizedMode';
      await repository.submitSale(
        customerId: 0,
        cartItems: items,
        grandTotal: grandTotal,
        warehouseId: _selectedWarehouseId,
        discount: 0,
        shipping: 0,
        taxRate: _taxRate,
        paymentTypeId: paymentTypeId,
        paymentStatusId: 2,
        notes: note,
        saleStatus: saleStatus ?? 'pos',
        receivedAmount: 0,
      );
      _successMessage = 'Commande borne enregistrée.';
      _lastSyncAt = DateTime.now();
      await loadOrderHistory(hours: _historyHours);
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
    } finally {
      _isProcessingSale = false;
    }
  }

  Future<bool> payOrder({
    required int saleId,
    required int paymentTypeId,
    required double receivedAmount,
  }) async {
    _isProcessingSale = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      await repository.paySale(
        saleId: saleId,
        paymentTypeId: paymentTypeId,
        receivedAmount: receivedAmount,
      );
      _successMessage = 'Commande payée.';
      await loadOrderHistory(hours: _historyHours);
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isProcessingSale = false;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _loadProducts() async {
    if (_offlineMode) {
      _setLoading(false);
      notifyListeners();
      return;
    }
    _setLoading(true);
    try {
      // Always fetch the full catalog for the selected store, then apply
      // category/search filters locally to avoid refresh on each navigation.
      final items = await repository.fetchProducts(
        warehouseId: _selectedWarehouseId,
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
        _forceOffline(
            'Mode hors ligne: authentification requise (${error.message}). Cache conserve.');
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

  bool _isConnectivityNoise(String message) {
    final lower = message.toLowerCase();
    return lower.contains('hors ligne') ||
        lower.contains('connexion') ||
        lower.contains('reseau') ||
        lower.contains('réseau') ||
        lower.contains('socket') ||
        lower.contains('timeout') ||
        lower.contains('authentification requise') ||
        lower.contains('unauthenticated') ||
        lower.contains('delai d\'attente') ||
        lower.contains('rafraichir');
  }

  Future<void> _loadOfflineSales() async {
    _offlineSales = await _offlineSalesStorage.read();
  }

  Future<void> _persistOfflineSales() async {
    await _offlineSalesStorage.write(_offlineSales);
  }

  Future<void> _syncLocalQueueInBackground() async {
    try {
      await _syncOfflineSales();
      await _loadProducts();
      await _refreshFrontSetting();
      await _refreshPrintingServices();
    } catch (_) {
      // Keep the local queue for the next automatic/manual sync.
    }
  }

  Future<void> _addOfflineSaleFromCart({
    required List<CartItem> cartItems,
    required OfflineSaleStatus status,
    required String errorMessage,
    String? notes,
    String? saleStatus,
    required int paymentTypeId,
    required int paymentStatusId,
    required double receivedAmount,
    double? grandTotalValue,
    double? discountAmountValue,
    double? shippingValue,
    double? taxRateValue,
  }) async {
    final itemsSubTotal =
        cartItems.fold<double>(0, (sum, item) => sum + item.subTotal);
    final discountTotal = discountAmountValue ?? discountAmount;
    final discountShare = itemsSubTotal > 0 ? discountTotal / itemsSubTotal : 0;
    final taxRate = taxRateValue ?? _taxRate;
    final saleItems = cartItems.map((item) {
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
      customerId: _selectedCustomer?.id ?? 0,
      warehouseId: _selectedWarehouseId,
      grandTotal: grandTotalValue ?? grandTotal,
      discount: discountTotal,
      shipping: shippingValue ?? _shipping,
      taxRate: taxRate,
      paymentTypeId: paymentTypeId,
      paymentStatusId: paymentStatusId,
      receivedAmount: receivedAmount,
      loyaltyRedeemAmount: loyaltyRedeemAmount,
      loyaltyRedeemPoints: loyaltyRedeemPoints,
      notes: notes,
      saleStatus: saleStatus,
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
    final hasPending =
        _offlineSales.any((sale) => sale.status == OfflineSaleStatus.pending);
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
            saleStatus: sale.saleStatus,
            receivedAmount: sale.receivedAmount,
            loyaltyRedeemAmount: sale.loyaltyRedeemAmount,
            loyaltyRedeemPoints: sale.loyaltyRedeemPoints,
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
        _errorMessage = null;
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
      _companyLogo = normalizeMediaUrl(logo.toString()) ?? '';
    }
    if (frontStoreId != null && _selectedWarehouseId == null) {
      _selectedWarehouseId = int.tryParse('$frontStoreId');
    }
    final loyaltyEnabled = value['loyalty_enabled'] ?? value['loyaltyEnabled'];
    if (loyaltyEnabled != null) {
      _loyaltyEnabled = _parseBool(loyaltyEnabled);
      if (!_loyaltyEnabled) {
        _loyaltyRedeemInput = 0;
      }
    }
    final allowRedeem =
        value['allow_loyalty_redeem'] ?? value['allowLoyaltyRedeem'];
    if (allowRedeem != null) {
      _allowLoyaltyRedeem = _parseBool(allowRedeem);
      if (!_allowLoyaltyRedeem) {
        _loyaltyRedeemInput = 0;
      }
    }
    final pointsPerOrder =
        value['loyalty_points_per_order'] ?? value['loyaltyPointsPerOrder'];
    if (pointsPerOrder != null) {
      _loyaltyPointsPerOrder = _parseInt(pointsPerOrder);
    }
    final pointsPerItem =
        value['loyalty_points_per_item'] ?? value['loyaltyPointsPerItem'];
    if (pointsPerItem != null) {
      _loyaltyPointsPerItem = _parseInt(pointsPerItem);
    }
    final amountPerPoint =
        value['loyalty_amount_per_point'] ?? value['loyaltyAmountPerPoint'];
    if (amountPerPoint != null) {
      _loyaltyAmountPerPoint = _parseDouble(amountPerPoint);
    }
    final pointValue =
        value['loyalty_point_value'] ?? value['loyaltyPointValue'];
    if (pointValue != null) {
      _loyaltyPointValue = _parseDouble(pointValue);
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

  void _applyLocalLoyaltyAdjustments({
    required int earned,
    required int redeemed,
  }) {
    if (!_loyaltyEnabled) return;
    if (_selectedCustomer == null || _selectedCustomer!.id == 0) return;
    if (earned == 0 && redeemed == 0) return;
    final current = _selectedCustomer!;
    final updatedPoints = max(0, current.loyaltyPoints + earned - redeemed);
    final updated = Customer(
      id: current.id,
      name: current.name,
      email: current.email,
      phone: current.phone,
      loyaltyPoints: updatedPoints,
    );
    _selectedCustomer = updated;
    final index = _customers.indexWhere((c) => c.id == current.id);
    if (index != -1) {
      _customers[index] = updated;
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

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
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
    final items = orders.fold<int>(0, (sum, order) => sum + (order.itemCount));
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
    _historyResetAfter = stored != null ? DateTime.tryParse(stored) : null;
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
        'option_links':
            product.options.map((option) => option.toJson()).toList(),
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
        'note': order.note,
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
        _products = decoded.whereType<Map>().map((e) {
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
        }).toList();
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

  Future<void> _cacheCategories(List<ProductCategory> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = categories
        .map((category) => {
              'id': category.id,
              'attributes': {
                'name': category.name,
              },
            })
        .toList();
    await prefs.setString(_cachedCategoriesKey, jsonEncode(payload));
  }

  Future<void> _cachePaymentMethods(List<PaymentMethod> methods) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = methods
        .map((method) => {
              'id': method.id,
              'name': method.name,
              'type': method.type,
              'is_default': method.isDefault,
              'is_active': method.isActive,
            })
        .toList();
    await prefs.setString(_cachedPaymentMethodsKey, jsonEncode(payload));
  }

  Future<void> _cacheShippingMethods(List<ShippingMethod> methods) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = methods
        .map((method) => {
              'id': method.id,
              'name': method.name,
              'type': method.type,
              'value': method.value,
              'is_active': method.isActive,
            })
        .toList();
    await prefs.setString(_cachedShippingMethodsKey, jsonEncode(payload));
  }

  Future<void> _cacheDiscounts(List<Discount> discounts) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = discounts
        .map((discount) => {
              'id': discount.id,
              'name': discount.name,
              'type': discount.type,
              'value': discount.value,
              'scope': discount.scope,
              'is_active': discount.isActive,
            })
        .toList();
    await prefs.setString(_cachedDiscountsKey, jsonEncode(payload));
  }

  Future<void> _cacheConfig(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedConfigKey, jsonEncode(payload));
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
      _normalizeCustomers();
    } catch (_) {}
  }

  Future<void> _loadCachedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cachedCategoriesKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _categories = decoded
            .whereType<Map>()
            .map((e) => ProductCategory.fromJson(e.cast<String, dynamic>()))
            .toList();
      }
    } catch (_) {}
  }

  Future<void> _loadCachedPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cachedPaymentMethodsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _paymentMethods = decoded
            .whereType<Map>()
            .map((e) => PaymentMethod.fromJson(e.cast<String, dynamic>()))
            .where((method) => method.isActive)
            .toList();
      }
    } catch (_) {}
  }

  Future<void> _loadCachedShippingMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cachedShippingMethodsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final methods = decoded
            .whereType<Map>()
            .map((e) => ShippingMethod.fromJson(e.cast<String, dynamic>()))
            .toList();
        _applyShippingMethods(methods);
      }
    } catch (_) {}
  }

  Future<void> _loadCachedDiscounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cachedDiscountsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _discounts = decoded
            .whereType<Map>()
            .map((e) => Discount.fromJson(e.cast<String, dynamic>()))
            .toList();
      }
    } catch (_) {}
  }

  Future<void> _loadCachedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cachedConfigKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        _applyConfig(decoded.cast<String, dynamic>());
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

  Future<void> _refreshPrintingServices() async {
    try {
      _printingServices = await repository.fetchPrintingServices();
      await _cachePrintingServices(_printingServices);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _cachePrintingServices(List<PrintingService> services) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = services.map((service) => service.toJson()).toList();
      await prefs.setString(_cachedPrintingServicesKey, jsonEncode(payload));
    } catch (_) {}
  }

  Future<void> _loadCachedPrintingServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_cachedPrintingServicesKey);
      if (stored == null || stored.isEmpty) return;
      final decoded = jsonDecode(stored);
      if (decoded is List) {
        _printingServices = decoded
            .whereType<Map>()
            .map((item) =>
                PrintingService.fromJson(item.map((k, v) => MapEntry('$k', v))))
            .toList();
        _printingServices.sort((a, b) {
          final order = a.sortOrder.compareTo(b.sortOrder);
          return order != 0 ? order : a.name.compareTo(b.name);
        });
      }
    } catch (_) {}
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

  void _normalizeCustomers() {
    if (_customers.isEmpty) {
      _customers = [Customer(id: 0, name: 'Client')];
      return;
    }
    if (!_customers.any((c) => c.id == 0)) {
      _customers = [Customer(id: 0, name: 'Client'), ..._customers];
    }
    if (_selectedCustomer != null) {
      final matched = _customers.where((c) => c.id == _selectedCustomer!.id);
      if (matched.isNotEmpty) {
        _selectedCustomer = matched.first;
      } else if (_customers.isNotEmpty) {
        _selectedCustomer = _customers.first;
      }
    }
  }

  List<OrderSummary> _offlineOrders() {
    return _offlineSales.map((sale) {
      final matched = _customers.firstWhere(
        (c) => c.id == sale.customerId,
        orElse: () => Customer(id: sale.customerId, name: 'Client local'),
      );
      final customerName = matched.name;
      final items =
          sale.saleItems.map((e) => Map<String, dynamic>.from(e)).toList();
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
            final optionsRaw = item['options'] ?? item['ingredients'];
            final options = optionsRaw is List
                ? optionsRaw
                    .whereType<Map>()
                    .map((i) =>
                        ProductOption.fromJson(i.cast<String, dynamic>()))
                    .where((o) => o.id > 0 && o.name.trim().isNotEmpty)
                    .toList()
                : <ProductOption>[];
            return OrderItemSummary(
              name: name,
              quantity: qty,
              options: options,
            );
          })
          .where((d) => d.name.trim().isNotEmpty)
          .toList();
      final itemCount = details.isNotEmpty
          ? details.fold<int>(0, (sum, d) => sum + d.quantity.toInt())
          : names.length;
      final statusLabel =
          sale.status == OfflineSaleStatus.pending ? 'LOCAL' : 'ERREUR';
      return OrderSummary(
        id: sale.hashCode,
        referenceCode: sale.id,
        customerName: customerName,
        userName: _activeUserLabel,
        userId: null,
        note: sale.notes,
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
