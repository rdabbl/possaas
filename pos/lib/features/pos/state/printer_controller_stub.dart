import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../core/models/cart_item.dart';
import '../../../core/models/order_summary.dart';
import '../../../core/models/register_details.dart';
import '../data/printer_settings_storage.dart';

enum PrinterConnectionType { lan, wifi, usb, bluetooth, system }

extension PrinterConnectionTypeX on PrinterConnectionType {
  String get label {
    switch (this) {
      case PrinterConnectionType.lan:
        return 'LAN';
      case PrinterConnectionType.wifi:
        return 'Wi-Fi';
      case PrinterConnectionType.usb:
        return 'USB';
      case PrinterConnectionType.bluetooth:
        return 'Bluetooth';
      case PrinterConnectionType.system:
        return 'Système';
    }
  }
}

class PrinterDeviceInfo {
  PrinterDeviceInfo({
    required this.name,
    required this.type,
    this.details = 'Non supporté',
  });

  final String name;
  final PrinterConnectionType type;
  final String details;
}

class PrinterSettingsController extends ChangeNotifier {
  PrinterSettingsController({PrinterSettingsStorage? storage})
      : _storage = storage ?? const PrinterSettingsStorage();

  final PrinterSettingsStorage _storage;
  final List<double> paperWidthOptions = const [58, 72, 80];
  PrinterConnectionType _connectionType = PrinterConnectionType.lan;
  final List<PrinterDeviceInfo> _devices = [];
  PrinterDeviceInfo? _selectedDevice;
  bool _isScanning = false;
  bool _isTesting = false;
  double _paperWidth = 80;
  double _paperHeight = 200;
  bool _autoCut = true;
  double _fontScale = 0.8;
  String? _statusMessage;
  bool _statusIsError = false;
  String _manualAddress = '';
  String _manualPort = '9100';
  String _wifiSsid = '';
  String _wifiPassword = '';
  bool _hasLoadedInitialSettings = false;
  String? _activeUserLabel;

  UnmodifiableListView<PrinterDeviceInfo> get devices =>
      UnmodifiableListView(_devices);
  PrinterDeviceInfo? get selectedDevice => _selectedDevice;
  PrinterConnectionType get connectionType => _connectionType;
  bool get isScanning => _isScanning;
  bool get isTesting => _isTesting;
  double get paperWidth => _paperWidth;
  double get paperHeight => _paperHeight;
  bool get autoCut => _autoCut;
  double get fontScale => _fontScale;
  String? get statusMessage => _statusMessage;
  bool get statusIsError => _statusIsError;
  String get manualAddress => _manualAddress;
  String get manualPort => _manualPort;
  String get wifiSsid => _wifiSsid;
  String get wifiPassword => _wifiPassword;

  bool get isTestEnabled => false;
  bool get canDiscover => false;
  bool get canUseManualEntry => false;
  bool get currentTypeSupported => false;
  List<PrinterConnectionType> get availableTypes =>
      PrinterConnectionType.values;

  Future<void> attachToUser(String? userLabel) async {
    if (_hasLoadedInitialSettings && _activeUserLabel == userLabel) return;
    _activeUserLabel = userLabel;
    await _loadSettings();
  }

  Future<void> persistSettings() async {
    await _persistSettings();
    _setStatus('Paramètres enregistrés (impression indisponible sur Web).', false);
  }

  void selectType(PrinterConnectionType type) {
    _connectionType = type;
    notifyListeners();
  }

  void selectDevice(PrinterDeviceInfo device) {
    _selectedDevice = device;
    notifyListeners();
  }

  void updatePaperWidth(double width) {
    _paperWidth = width;
    notifyListeners();
  }

  void updatePaperWidthFromInput(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed > 0) {
      updatePaperWidth(parsed);
    }
  }

  void updatePaperHeight(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null) {
      _paperHeight = parsed;
      notifyListeners();
    }
  }

  void toggleAutoCut(bool value) {
    _autoCut = value;
    notifyListeners();
  }

  void updateFontScale(double value) {
    _fontScale = value;
    notifyListeners();
  }

  void updateManualAddress(String value) {
    _manualAddress = value;
  }

  void updateManualPort(String value) {
    _manualPort = value;
  }

  void updateWifiSsid(String value) {
    _wifiSsid = value;
  }

  void updateWifiPassword(String value) {
    _wifiPassword = value;
  }

  Future<void> addManualNetworkPrinter() async {
    _setStatus('Ajout manuel indisponible sur Web.', true);
  }

  Future<void> discoverPrinters() async {
    _isScanning = true;
    notifyListeners();
    _setStatus('La recherche d\'imprimantes n\'est pas supportée sur Web.', true);
    _isScanning = false;
    notifyListeners();
  }

  Future<void> testPrint() async {
    _setStatus('Impression non disponible sur Web.', true);
  }

  Future<void> printSaleReceipt({
    required List<CartItem> items,
    required double subTotal,
    required double discount,
    required double tax,
    required double shipping,
    required double grandTotal,
    required String currencySymbol,
    required bool currencyOnRight,
    required String? customerName,
    required String? userLabel,
    required String? companyName,
    required String? companyAddress,
    required String? companyEmail,
    required String? companyPhone,
    required String? warehouseName,
    required String? companyLogoUrl,
    required String paymentType,
    required String paymentStatus,
    double? receivedAmount,
    double? change,
  }) async {
    _setStatus('Impression non disponible sur Web.', true);
  }

  Future<void> printSalesHistory({
    required List<OrderSummary> orders,
    required RegisterDetails register,
    required String currencySymbol,
    required bool currencyOnRight,
    required String? userLabel,
  }) async {
    _setStatus('Impression non disponible sur Web.', true);
  }

  Future<void> _loadSettings() async {
    final stored = await _storage.read(_activeUserLabel);
    if (stored != null) {
      _paperWidth = _doubleFrom(stored['paperWidth']) ?? _paperWidth;
      _paperHeight = _doubleFrom(stored['paperHeight']) ?? _paperHeight;
      _autoCut = _boolFrom(stored['autoCut']) ?? _autoCut;
      _fontScale = _doubleFrom(stored['fontScale']) ?? _fontScale;
      _manualAddress = _stringFrom(stored['manualAddress']) ?? '';
      _manualPort = _stringFrom(stored['manualPort']) ?? '9100';
      _wifiSsid = _stringFrom(stored['wifiSsid']) ?? '';
      _wifiPassword = _stringFrom(stored['wifiPassword']) ?? '';
    }
    _hasLoadedInitialSettings = true;
    notifyListeners();
  }

  Future<void> _persistSettings() async {
    final payload = <String, dynamic>{
      'paperWidth': _paperWidth,
      'paperHeight': _paperHeight,
      'autoCut': _autoCut,
      'fontScale': _fontScale,
      'manualAddress': _manualAddress,
      'manualPort': _manualPort,
      'wifiSsid': _wifiSsid,
      'wifiPassword': _wifiPassword,
    };
    await _storage.write(_activeUserLabel, payload);
  }

  void _setStatus(String message, bool isError) {
    _statusMessage = message;
    _statusIsError = isError;
    notifyListeners();
  }

  double? _doubleFrom(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  bool? _boolFrom(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    final normalized = value.toString().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }

  String? _stringFrom(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }
}
