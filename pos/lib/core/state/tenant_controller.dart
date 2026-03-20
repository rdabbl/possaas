import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../storage/tenant_storage.dart';
import '../storage/token_storage.dart';
import '../../features/pos/data/offline_sales_storage.dart';

class TenantController extends ChangeNotifier {
  TenantController({TenantStorage? storage})
      : _storage = storage ?? const TenantStorage();

  final TenantStorage _storage;
  final OfflineSalesStorage _offlineSalesStorage = OfflineSalesStorage();

  bool _initializing = true;
  String? _apiBaseUrl;
  String? _posUrl;
  String? _licenseKey;
  String _saasBaseUrl =
      AppConfig.apiBaseUrl.replaceFirst(RegExp(r'/api/?$'), '');

  bool get initializing => _initializing;
  bool get isConfigured => _apiBaseUrl != null && _apiBaseUrl!.isNotEmpty;
  String? get apiBaseUrl => _apiBaseUrl;
  String? get posUrl => _posUrl;
  String? get licenseKey => _licenseKey;
  String get saasBaseUrl => _saasBaseUrl;

  Future<void> bootstrap() async {
    final stored = await _storage.read();
    if (stored != null) {
      final api = stored['apiBaseUrl']?.toString();
      final pos = stored['posUrl']?.toString();
      _apiBaseUrl = api?.isNotEmpty == true ? api : null;
      _posUrl = pos?.isNotEmpty == true
          ? pos
          : (api != null ? _stripApiSuffix(api) : null);
      final license = stored['licenseKey']?.toString();
      _licenseKey = license?.isNotEmpty == true ? license : null;
      final saas = stored['saasBaseUrl']?.toString();
      if (saas != null && saas.isNotEmpty) {
        _saasBaseUrl = _normalizeBaseUrl(saas);
      }
    }
    _initializing = false;
    notifyListeners();
  }

  Future<void> saveTenant({
    required String posUrl,
    required String licenseKey,
    String? saasBaseUrl,
  }) async {
    final normalizedPos = _normalizeBaseUrl(posUrl);
    final apiBaseUrl = _ensureApiSuffix(normalizedPos);
    final normalizedLicense = licenseKey.trim();
    final normalizedSaas =
        saasBaseUrl != null && saasBaseUrl.trim().isNotEmpty
            ? _normalizeBaseUrl(saasBaseUrl)
            : _saasBaseUrl;

    final baseChanged = _apiBaseUrl != null && _apiBaseUrl != apiBaseUrl;

    _posUrl = normalizedPos;
    _apiBaseUrl = apiBaseUrl;
    _licenseKey = normalizedLicense;
    _saasBaseUrl = normalizedSaas;

    await _storage.write({
      'apiBaseUrl': _apiBaseUrl,
      'posUrl': _posUrl,
      'licenseKey': _licenseKey,
      'saasBaseUrl': _saasBaseUrl,
    });

    if (baseChanged) {
      await _clearTenantData();
    }

    notifyListeners();
  }

  Future<void> clearTenant() async {
    _posUrl = null;
    _apiBaseUrl = null;
    _licenseKey = null;
    await _storage.clear();
    await _clearTenantData();
    notifyListeners();
  }

  Future<void> _clearTenantData() async {
    const tokenStorage = TokenStorage();
    await tokenStorage.clearAll();
    await _offlineSalesStorage.clear();

    final prefs = await SharedPreferences.getInstance();
    const cacheKeys = [
      'pos_cached_products',
      'pos_cached_customers',
      'pos_cached_warehouses',
      'pos_cached_front_settings',
      'pos_selected_customer',
      'pos_selected_warehouse',
    ];
    for (final key in cacheKeys) {
      await prefs.remove(key);
    }
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith('pos_cached_history_')) {
        await prefs.remove(key);
      }
    }
  }

  String _normalizeBaseUrl(String input) {
    var url = input.trim();
    if (url.isEmpty) return url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  String _ensureApiSuffix(String url) {
    if (url.endsWith('/api')) return url;
    return '$url/api';
  }

  String _stripApiSuffix(String url) {
    var trimmed = url;
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (trimmed.endsWith('/api')) {
      trimmed = trimmed.substring(0, trimmed.length - 4);
    }
    return trimmed;
  }
}
