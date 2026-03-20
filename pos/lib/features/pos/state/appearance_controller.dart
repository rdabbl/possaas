import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/appearance_settings_storage.dart';

class AppearanceController extends ChangeNotifier {
  static final bool _isAndroid =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  AppearanceController({AppearanceSettingsStorage? storage})
      : _storage = storage ?? const AppearanceSettingsStorage();

  Color _accentColor = const Color(0xFF0F9A8A);
  int _productGridColumns = 3;
  bool _useDarkMode = false;
  bool _showClientField = !_isAndroid;
  bool _showWarehouseField = !_isAndroid;
  bool _showSearchInput = !_isAndroid;
  bool _showCategoryFilter = !_isAndroid;
  bool _showAddToCartButton = !_isAndroid;
  bool _showProductCode = !_isAndroid;
  bool _showStockInfo = !_isAndroid;
  bool _showCartSummary = !_isAndroid;
  bool _showTotalsInCart = !_isAndroid;
  bool _showProductList = !_isAndroid;
  bool _showCashButton = !_isAndroid;
  bool _showResetButton = !_isAndroid;
  bool _showHoldButton = !_isAndroid;
  bool _showHistoryPanel = !_isAndroid;
  double _uiScale = 1.0;
  bool _resetHistoryAt4Am = false;
  int _historyResetHour = 4;
  bool _swapSidePanels = false;
  final AppearanceSettingsStorage _storage;
  bool _isLoaded = false;

  Color get accentColor => _accentColor;
  int get productGridColumns => _productGridColumns;
  bool get useDarkMode => _useDarkMode;
  bool get showClientField => _showClientField;
  bool get showWarehouseField => _showWarehouseField;
  bool get showSearchInput => _showSearchInput;
  bool get showCategoryFilter => _showCategoryFilter;
  bool get showAddToCartButton => _showAddToCartButton;
  bool get showProductCode => _showProductCode;
  bool get showStockInfo => _showStockInfo;
  bool get showCartSummary => _showCartSummary;
  bool get showTotalsInCart => _showTotalsInCart;
  bool get showProductList => _showProductList;
  bool get showCashButton => _showCashButton;
  bool get showResetButton => _showResetButton;
  bool get showHoldButton => _showHoldButton;
  double get uiScale => _uiScale;
  bool get showHistoryPanel => _showHistoryPanel;
  bool get resetHistoryAt4Am => _resetHistoryAt4Am;
  int get historyResetHour => _historyResetHour;
  bool get swapSidePanels => _swapSidePanels;

  ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _accentColor,
      brightness: _useDarkMode ? Brightness.dark : Brightness.light,
    );
    final inputTheme = _buildInputTheme(colorScheme);

    final base = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      inputDecorationTheme: inputTheme,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _accentColor,
          side: BorderSide(color: _accentColor, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
      ),
    );
    final scaledIconTheme =
        base.iconTheme.copyWith(size: (base.iconTheme.size ?? 24) * _uiScale);
    return base.copyWith(
      iconTheme: scaledIconTheme,
    );
  }

  void updateAccentColor(Color color) {
    if (color == _accentColor) {
      return;
    }
    _accentColor = color;
    notifyListeners();
    _persist();
  }

  void updateGridColumns(int value) {
    final normalized = value.clamp(1, 5);
    if (normalized == _productGridColumns) {
      return;
    }
    _productGridColumns = normalized;
    notifyListeners();
    _persist();
  }

  void toggleDarkMode(bool value) {
    if (_useDarkMode == value) return;
    _useDarkMode = value;
    notifyListeners();
    _persist();
  }

  void updateClientFieldVisibility(bool value) {
    if (_showClientField == value) {
      return;
    }
    _showClientField = value;
    notifyListeners();
    _persist();
  }

  void updateWarehouseFieldVisibility(bool value) {
    if (_showWarehouseField == value) {
      return;
    }
    _showWarehouseField = value;
    notifyListeners();
    _persist();
  }

  void updateSearchInputVisibility(bool value) {
    if (_showSearchInput == value) {
      return;
    }
    _showSearchInput = value;
    notifyListeners();
    _persist();
  }

  void updateCategoryFilterVisibility(bool value) {
    if (_showCategoryFilter == value) {
      return;
    }
    _showCategoryFilter = value;
    notifyListeners();
    _persist();
  }

  void updateAddToCartVisibility(bool value) {
    if (_showAddToCartButton == value) {
      return;
    }
    _showAddToCartButton = value;
    notifyListeners();
    _persist();
  }

  void updateProductCodeVisibility(bool value) {
    if (_showProductCode == value) {
      return;
    }
    _showProductCode = value;
    notifyListeners();
    _persist();
  }

  void updateStockInfoVisibility(bool value) {
    if (_showStockInfo == value) {
      return;
    }
    _showStockInfo = value;
    notifyListeners();
    _persist();
  }

  void updateUiScale(double value) {
    final normalized = value.clamp(0.6, 1.2);
    if ((_uiScale - normalized).abs() < 0.001) return;
    _uiScale = normalized;
    notifyListeners();
    _persist();
  }

  void updateCartSummaryVisibility(bool value) {
    if (_showCartSummary == value) return;
    _showCartSummary = value;
    notifyListeners();
    _persist();
  }

  void updateCartTotalsVisibility(bool value) {
    if (_showTotalsInCart == value) return;
    _showTotalsInCart = value;
    notifyListeners();
    _persist();
  }

  void updateProductListVisibility(bool value) {
    if (_showProductList == value) return;
    _showProductList = value;
    notifyListeners();
    _persist();
  }

  void updateCashButtonVisibility(bool value) {
    if (_showCashButton == value) return;
    _showCashButton = value;
    notifyListeners();
    _persist();
  }

  void updateResetButtonVisibility(bool value) {
    if (_showResetButton == value) return;
    _showResetButton = value;
    notifyListeners();
    _persist();
  }

  void updateHoldButtonVisibility(bool value) {
    if (_showHoldButton == value) return;
    _showHoldButton = value;
    notifyListeners();
    _persist();
  }

  void updateHistoryPanelVisibility(bool value) {
    if (_showHistoryPanel == value) return;
    _showHistoryPanel = value;
    notifyListeners();
    _persist();
  }

  void updateHistoryReset(bool value) {
    if (_resetHistoryAt4Am == value) {
      return;
    }
    _resetHistoryAt4Am = value;
    notifyListeners();
    _persist();
  }

  void updateHistoryResetHour(int value) {
    final normalized = value.clamp(0, 23);
    if (_historyResetHour == normalized) {
      return;
    }
    _historyResetHour = normalized;
    notifyListeners();
    _persist();
  }

  void updateSidePanelsSwap(bool value) {
    if (_swapSidePanels == value) return;
    _swapSidePanels = value;
    notifyListeners();
    _persist();
  }

  InputDecorationTheme _buildInputTheme(ColorScheme scheme) {
    OutlineInputBorder outline({double width = 1.2}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: width),
      );
    }

    return InputDecorationTheme(
      border: outline(),
      enabledBorder: outline(),
      focusedBorder: outline(width: 1.8),
      errorBorder: outline(),
      focusedErrorBorder: outline(width: 1.8),
    );
  }

  Future<void> bootstrap() async {
    if (_isLoaded) return;
    final stored = await _storage.read();
    if (stored != null) {
      _accentColor = Color(_intFrom(stored['accentColor']) ?? _accentColor.value);
      _productGridColumns =
          _intFrom(stored['productGridColumns'])?.clamp(1, 5) ?? _productGridColumns;
      _useDarkMode = _boolFrom(stored['useDarkMode']) ?? _useDarkMode;
      _showClientField = _boolFrom(stored['showClientField']) ?? _showClientField;
      _showWarehouseField =
          _boolFrom(stored['showWarehouseField']) ?? _showWarehouseField;
      _showSearchInput = _boolFrom(stored['showSearchInput']) ?? _showSearchInput;
      _showCategoryFilter =
          _boolFrom(stored['showCategoryFilter']) ?? _showCategoryFilter;
      _showAddToCartButton =
          _boolFrom(stored['showAddToCartButton']) ?? _showAddToCartButton;
      _showProductCode = _boolFrom(stored['showProductCode']) ?? _showProductCode;
      _showStockInfo = _boolFrom(stored['showStockInfo']) ?? _showStockInfo;
      _showCartSummary = _boolFrom(stored['showCartSummary']) ?? _showCartSummary;
      _showTotalsInCart = _boolFrom(stored['showTotalsInCart']) ?? _showTotalsInCart;
      _showProductList = _boolFrom(stored['showProductList']) ?? _showProductList;
      _showCashButton = _boolFrom(stored['showCashButton']) ?? _showCashButton;
      _showResetButton = _boolFrom(stored['showResetButton']) ?? _showResetButton;
      _showHoldButton = _boolFrom(stored['showHoldButton']) ?? _showHoldButton;
      _showHistoryPanel = _boolFrom(stored['showHistoryPanel']) ?? _showHistoryPanel;
      _uiScale = _doubleFrom(stored['uiScale'])?.clamp(0.6, 1.2) ?? _uiScale;
      _resetHistoryAt4Am =
          _boolFrom(stored['resetHistoryAt4Am']) ?? _resetHistoryAt4Am;
      _historyResetHour =
          _intFrom(stored['historyResetHour'])?.clamp(0, 23) ?? _historyResetHour;
      _swapSidePanels = _boolFrom(stored['swapSidePanels']) ?? _swapSidePanels;
    }
    _isLoaded = true;
    notifyListeners();
  }

  Map<String, dynamic> _toJson() => {
        'accentColor': _accentColor.value,
        'productGridColumns': _productGridColumns,
        'useDarkMode': _useDarkMode,
        'showClientField': _showClientField,
        'showWarehouseField': _showWarehouseField,
        'showSearchInput': _showSearchInput,
        'showCategoryFilter': _showCategoryFilter,
        'showAddToCartButton': _showAddToCartButton,
        'showProductCode': _showProductCode,
        'showStockInfo': _showStockInfo,
        'showCartSummary': _showCartSummary,
        'showTotalsInCart': _showTotalsInCart,
        'showProductList': _showProductList,
        'showCashButton': _showCashButton,
        'showResetButton': _showResetButton,
        'showHoldButton': _showHoldButton,
        'uiScale': _uiScale,
        'showHistoryPanel': _showHistoryPanel,
        'resetHistoryAt4Am': _resetHistoryAt4Am,
        'historyResetHour': _historyResetHour,
        'swapSidePanels': _swapSidePanels,
      };

  Future<void> _persist() async {
    if (!_isLoaded) return;
    await _storage.write(_toJson());
  }

  double? _doubleFrom(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  bool? _boolFrom(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return null;
  }

  int? _intFrom(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
