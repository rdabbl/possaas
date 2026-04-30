import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../core/models/cart_item.dart';
import '../../../core/models/order_summary.dart';
import '../../../core/models/register_details.dart';
import '../data/printer_settings_storage.dart';
import '../models/printing_service.dart';

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
        return 'Systeme';
    }
  }
}

class PrinterDeviceInfo {
  PrinterDeviceInfo({
    required this.name,
    required this.type,
    this.details = 'Non supporte',
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
  String _ticketHeader = '';
  String _ticketFooter = 'Merci pour votre achat.';
  bool _showCustomerInfo = true;
  bool _showCustomerPhone = true;
  bool _showCustomerEmail = true;
  bool _hasLoadedInitialSettings = false;
  bool _showDiscoveredPrinters = true;
  List<PrintingService> _services = [];
  int? _activeServiceId;
  bool _autoPrintFromPos = true;
  bool _autoPrintFromKiosk = true;
  Set<String> _posTemplates = {'receipt'};
  Set<String> _kioskTemplates = {'kiosk', 'kitchen'};

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
  String get ticketHeader => _ticketHeader;
  String get ticketFooter => _ticketFooter;
  bool get showCustomerInfo => _showCustomerInfo;
  bool get showCustomerPhone => _showCustomerPhone;
  bool get showCustomerEmail => _showCustomerEmail;
  bool get showDiscoveredPrinters => _showDiscoveredPrinters;
  List<PrintingService> get services => List.unmodifiable(_services);
  bool get autoPrintFromPos => _autoPrintFromPos;
  bool get autoPrintFromKiosk => _autoPrintFromKiosk;
  Set<String> get posTemplates => Set.unmodifiable(_posTemplates);
  Set<String> get kioskTemplates => Set.unmodifiable(_kioskTemplates);
  int? get activeServiceId => _activeServiceId;
  PrintingService? get activeService => _activeServiceId == null
      ? null
      : _services.firstWhere(
          (service) => service.id == _activeServiceId,
          orElse: () => _services.isNotEmpty
              ? _services.first
              : PrintingService.fallback(),
        );

  bool get isTestEnabled => false;
  bool get canDiscover => false;
  bool get canUseManualEntry =>
      connectionType == PrinterConnectionType.lan ||
      connectionType == PrinterConnectionType.wifi;
  bool get currentTypeSupported => false;
  List<PrinterConnectionType> get availableTypes =>
      PrinterConnectionType.values;

  void syncServices(List<PrintingService> services, {int? preferredServiceId}) {
    final normalized =
        services.isNotEmpty ? services : [PrintingService.fallback()];
    _services = List<PrintingService>.from(normalized);
    _activeServiceId = preferredServiceId ??
        (_services.isNotEmpty ? _services.first.id : null);
    notifyListeners();
  }

  Future<void> selectService(int serviceId) async {
    if (_activeServiceId == serviceId) return;
    _activeServiceId = serviceId;
    await _loadSettings();
  }

  void toggleAutoPrintFromPos(bool value) {
    if (_autoPrintFromPos == value) return;
    _autoPrintFromPos = value;
    notifyListeners();
  }

  void toggleAutoPrintFromKiosk(bool value) {
    if (_autoPrintFromKiosk == value) return;
    _autoPrintFromKiosk = value;
    notifyListeners();
  }

  void toggleTemplateForSource({
    required bool fromKiosk,
    required String template,
    required bool enabled,
  }) {
    final normalized = template.trim().toLowerCase();
    if (normalized.isEmpty) return;
    final set = fromKiosk ? _kioskTemplates : _posTemplates;
    if (enabled) {
      set.add(normalized);
    } else {
      set.remove(normalized);
    }
    notifyListeners();
  }

  bool shouldPrintTemplate({
    required bool fromKiosk,
    required String template,
  }) {
    final normalized = template.trim().toLowerCase();
    if (fromKiosk) {
      return _autoPrintFromKiosk && _kioskTemplates.contains(normalized);
    }
    return _autoPrintFromPos && _posTemplates.contains(normalized);
  }

  Future<void> attachToUser(String? userLabel) async {
    if (_hasLoadedInitialSettings) return;
    await _loadSettings();
  }

  Future<void> persistSettings() async {
    await _persistSettings();
    _showDiscoveredPrinters = false;
    notifyListeners();
    _setStatus(
      'Configuration imprimante enregistree sur cette caisse pour tous les utilisateurs.',
      false,
    );
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

  void updateTicketHeader(String value) {
    _ticketHeader = value;
  }

  void updateTicketFooter(String value) {
    _ticketFooter = value;
  }

  void toggleShowCustomerInfo(bool value) {
    _showCustomerInfo = value;
    notifyListeners();
  }

  void toggleShowCustomerPhone(bool value) {
    _showCustomerPhone = value;
    notifyListeners();
  }

  void toggleShowCustomerEmail(bool value) {
    _showCustomerEmail = value;
    notifyListeners();
  }

  void showPrinterDiscovery() {
    if (_showDiscoveredPrinters) return;
    _showDiscoveredPrinters = true;
    notifyListeners();
  }

  Future<void> addManualNetworkPrinter() async {
    _setStatus('Ajout manuel indisponible sur Web.', true);
  }

  Future<void> discoverPrinters() async {
    _isScanning = true;
    notifyListeners();
    _setStatus(
        'La recherche d\'imprimantes n\'est pas supportee sur Web.', true);
    _isScanning = false;
    notifyListeners();
  }

  Future<void> testPrint({int? serviceId}) async {
    _setStatus('Impression non disponible sur Web.', true);
  }

  Future<void> testPrintAllServices() async {
    _setStatus('Impression non disponible sur Web.', true);
  }

  Future<void> printKioskQueueTicket({
    required int queueNumber,
    required String? companyName,
    int? serviceId,
  }) async {
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
    String? customerPhone,
    String? customerEmail,
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
    int? serviceId,
    String? template,
  }) async {
    _setStatus('Impression non disponible sur Web.', true);
  }

  Future<void> printSalesHistory({
    required List<OrderSummary> orders,
    required RegisterDetails register,
    required String currencySymbol,
    required bool currencyOnRight,
    required String? userLabel,
    int? serviceId,
  }) async {
    _setStatus('Impression non disponible sur Web.', true);
  }

  Future<void> _loadSettings() async {
    final stored = await _storage.read(null);
    final serviceKey = _serviceKey(_activeServiceId);
    final settings = _extractServiceSettings(stored, serviceKey);
    if (settings != null) {
      final storedType = _printerTypeFromString(settings['connectionType']);
      _connectionType = storedType ?? PrinterConnectionType.lan;
      _paperWidth = _doubleFrom(settings['paperWidth']) ?? _paperWidth;
      _paperHeight = _doubleFrom(settings['paperHeight']) ?? _paperHeight;
      _autoCut = _boolFrom(settings['autoCut']) ?? _autoCut;
      _fontScale = _doubleFrom(settings['fontScale']) ?? _fontScale;
      _manualAddress = _stringFrom(settings['manualAddress']) ?? '';
      _manualPort = _stringFrom(settings['manualPort']) ?? '9100';
      _ticketHeader = _stringFrom(settings['ticketHeader']) ?? '';
      _ticketFooter =
          _stringFrom(settings['ticketFooter']) ?? 'Merci pour votre achat.';
      _showCustomerInfo = _boolFrom(settings['showCustomerInfo']) ?? true;
      _showCustomerPhone = _boolFrom(settings['showCustomerPhone']) ?? true;
      _showCustomerEmail = _boolFrom(settings['showCustomerEmail']) ?? true;
      _autoPrintFromPos = _boolFrom(settings['autoPrintFromPos']) ?? true;
      _autoPrintFromKiosk = _boolFrom(settings['autoPrintFromKiosk']) ?? true;
      _posTemplates = _stringSetFrom(settings['posTemplates'], {'receipt'});
      _kioskTemplates =
          _stringSetFrom(settings['kioskTemplates'], {'kiosk', 'kitchen'});
      _showDiscoveredPrinters = false;
    } else {
      _connectionType = PrinterConnectionType.lan;
      _paperWidth = 80;
      _paperHeight = 200;
      _autoCut = true;
      _fontScale = 0.8;
      _manualAddress = '';
      _manualPort = '9100';
      _ticketHeader = '';
      _ticketFooter = 'Merci pour votre achat.';
      _showCustomerInfo = true;
      _showCustomerPhone = true;
      _showCustomerEmail = true;
      _autoPrintFromPos = true;
      _autoPrintFromKiosk = true;
      _posTemplates = {'receipt'};
      _kioskTemplates = {'kiosk', 'kitchen'};
      _showDiscoveredPrinters = true;
    }
    _hasLoadedInitialSettings = true;
    notifyListeners();
  }

  Future<void> _persistSettings() async {
    final payload = <String, dynamic>{
      'connectionType': _connectionType.name,
      'paperWidth': _paperWidth,
      'paperHeight': _paperHeight,
      'autoCut': _autoCut,
      'fontScale': _fontScale,
      'manualAddress': _manualAddress,
      'manualPort': _manualPort,
      'ticketHeader': _ticketHeader,
      'ticketFooter': _ticketFooter,
      'showCustomerInfo': _showCustomerInfo,
      'showCustomerPhone': _showCustomerPhone,
      'showCustomerEmail': _showCustomerEmail,
      'autoPrintFromPos': _autoPrintFromPos,
      'autoPrintFromKiosk': _autoPrintFromKiosk,
      'posTemplates': _posTemplates.toList(),
      'kioskTemplates': _kioskTemplates.toList(),
    };
    final stored = await _storage.read(null) ?? <String, dynamic>{};
    final services = _asStringKeyMap(stored['services']) ?? <String, dynamic>{};
    services[_serviceKey(_activeServiceId)] = payload;
    stored['services'] = services;
    await _storage.write(null, stored);
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

  Map<String, dynamic>? _extractServiceSettings(
    Map<String, dynamic>? stored,
    String serviceKey,
  ) {
    if (stored == null) return null;
    final services = _asStringKeyMap(stored['services']);
    if (services != null) {
      final candidate = _asStringKeyMap(services[serviceKey]);
      if (candidate != null) return candidate;
    }
    if (stored.containsKey('paperWidth') ||
        stored.containsKey('paperHeight') ||
        stored.containsKey('autoCut')) {
      return stored;
    }
    return null;
  }

  Map<String, dynamic>? _asStringKeyMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry('$key', val));
    }
    return null;
  }

  String _serviceKey(int? serviceId) {
    if (serviceId == null) return 'default';
    return serviceId.toString();
  }

  Set<String> _stringSetFrom(dynamic value, Set<String> fallback) {
    if (value is List) {
      return value
          .map((e) => e.toString().trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toSet();
    }
    return {...fallback};
  }

  PrinterConnectionType? _printerTypeFromString(dynamic raw) {
    if (raw is! String) return null;
    for (final type in PrinterConnectionType.values) {
      if (type.name == raw) return type;
    }
    return null;
  }
}
