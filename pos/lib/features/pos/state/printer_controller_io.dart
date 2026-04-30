import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:pos_printer_manager/models/pos_printer.dart';

import '../../../core/models/cart_item.dart';
import '../../../core/models/order_summary.dart';
import '../../../core/models/product.dart';
import '../../../core/models/product_option.dart';
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
    required this.printer,
    required this.type,
  });

  final POSPrinter printer;
  final PrinterConnectionType type;

  String get name =>
      printer.name ?? printer.address ?? printer.id ?? 'Sans nom';
  String get details {
    switch (type) {
      case PrinterConnectionType.lan:
      case PrinterConnectionType.wifi:
        return printer.address ?? '-';
      case PrinterConnectionType.usb:
        return 'VID:${printer.vendorId ?? 0} PID:${printer.productId ?? 0}';
      case PrinterConnectionType.bluetooth:
        return printer.address ?? '-';
      case PrinterConnectionType.system:
        return 'Non supporte';
    }
  }
}

class PrinterSettingsController extends ChangeNotifier {
  PrinterSettingsController({PrinterSettingsStorage? storage})
      : _storage = storage ?? const PrinterSettingsStorage() {
    CapabilityProfile.ensureProfileLoaded();
    _connectionType = _defaultType();
  }

  final PrinterSettingsStorage _storage;
  final List<double> paperWidthOptions = const [58, 72, 80];
  late PrinterConnectionType _connectionType;
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

  bool get isTestEnabled => _selectedDevice != null && !_isTesting;
  bool get canDiscover => !_isScanning && _supportsType(connectionType);
  bool get canUseManualEntry =>
      connectionType == PrinterConnectionType.lan ||
      connectionType == PrinterConnectionType.wifi;
  bool get currentTypeSupported => _supportsType(_connectionType);
  List<PrinterConnectionType> get availableTypes =>
      PrinterConnectionType.values.where(_supportsType).toList();

  void syncServices(List<PrintingService> services, {int? preferredServiceId}) {
    final normalized =
        services.isNotEmpty ? services : [PrintingService.fallback()];
    final same = _services.length == normalized.length &&
        _services.every(
            (service) => normalized.any((other) => other.id == service.id));
    _services = List<PrintingService>.from(normalized);
    final nextId = _resolveServiceId(preferredServiceId);
    if (_activeServiceId != nextId) {
      _activeServiceId = nextId;
      _devices.clear();
      _selectedDevice = null;
      _hasLoadedInitialSettings = false;
      _loadSettings();
    } else if (!same) {
      notifyListeners();
    }
  }

  int? _resolveServiceId(int? preferredServiceId) {
    if (preferredServiceId != null &&
        _services.any((service) => service.id == preferredServiceId)) {
      return preferredServiceId;
    }
    if (_activeServiceId != null &&
        _services.any((service) => service.id == _activeServiceId)) {
      return _activeServiceId;
    }
    return _services.isNotEmpty ? _services.first.id : null;
  }

  Future<void> selectService(int serviceId) async {
    if (_activeServiceId == serviceId) return;
    _activeServiceId = serviceId;
    _statusMessage = null;
    _devices.clear();
    _selectedDevice = null;
    _hasLoadedInitialSettings = false;
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
    if (_hasLoadedInitialSettings) {
      return;
    }
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

  PrinterConnectionType _defaultType() {
    final preferred = [
      PrinterConnectionType.lan,
      PrinterConnectionType.wifi,
      PrinterConnectionType.usb,
      PrinterConnectionType.bluetooth,
    ];
    for (final type in preferred) {
      if (_supportsType(type)) return type;
    }
    return PrinterConnectionType.lan;
  }

  void selectType(PrinterConnectionType type) {
    if (!_supportsType(type)) return;
    if (_connectionType == type) return;
    _connectionType = type;
    _statusMessage = null;
    _selectedDevice = null;
    _devices.clear();
    _showDiscoveredPrinters = true;
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
    if (value.trim().isEmpty) return;
    final parsed = double.tryParse(value);
    if (parsed != null && parsed > 0) {
      updatePaperWidth(parsed);
    }
  }

  void updatePaperHeight(String value) {
    if (value.trim().isEmpty) {
      _paperHeight = 0;
      notifyListeners();
      return;
    }
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
    _fontScale = value.clamp(0.5, 2.0);
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
    if (_showCustomerInfo == value) return;
    _showCustomerInfo = value;
    notifyListeners();
  }

  void toggleShowCustomerPhone(bool value) {
    if (_showCustomerPhone == value) return;
    _showCustomerPhone = value;
    notifyListeners();
  }

  void toggleShowCustomerEmail(bool value) {
    if (_showCustomerEmail == value) return;
    _showCustomerEmail = value;
    notifyListeners();
  }

  void showPrinterDiscovery() {
    if (_showDiscoveredPrinters) return;
    _showDiscoveredPrinters = true;
    notifyListeners();
  }

  Future<void> addManualNetworkPrinter() async {
    final address = _manualAddress.trim();
    if (address.isEmpty) {
      _setStatus('Indiquez une adresse IP ou un hote.', true);
      return;
    }
    final printer = NetWorkPrinter(
      id: '$address:$manualPortValue',
      name: address,
      address: address,
    );
    final device = PrinterDeviceInfo(printer: printer, type: _connectionType);
    _devices.add(device);
    _selectedDevice = device;
    _manualAddress = '';
    _showDiscoveredPrinters = true;
    notifyListeners();
    _setStatus('Imprimante $address ajoutee manuellement.', false);
  }

  int get manualPortValue => int.tryParse(_manualPort) ?? 9100;

  Future<void> discoverPrinters() async {
    if (!_supportsType(connectionType)) {
      _setStatus(
          'Ce type de connexion nest pas disponible sur cette plateforme.',
          true);
      return;
    }
    _isScanning = true;
    _statusMessage = null;
    _devices.clear();
    _showDiscoveredPrinters = true;
    notifyListeners();
    try {
      List<PrinterDeviceInfo> found = [];
      switch (connectionType) {
        case PrinterConnectionType.lan:
        case PrinterConnectionType.wifi:
          final printers = await NetworkPrinterManager.discover();
          found = printers
              .map((p) => PrinterDeviceInfo(printer: p, type: connectionType))
              .toList();
          break;
        case PrinterConnectionType.usb:
          final printers = await USBPrinterManager.discover();
          found = printers
              .map((p) => PrinterDeviceInfo(printer: p, type: connectionType))
              .toList();
          break;
        case PrinterConnectionType.bluetooth:
          final printers = await BluetoothPrinterManager.discover();
          found = printers
              .map((p) => PrinterDeviceInfo(printer: p, type: connectionType))
              .toList();
          break;
        case PrinterConnectionType.system:
          _setStatus('Type systeme non supporte pour impression.', true);
          break;
      }
      _devices.addAll(found);
      if (_devices.isEmpty) {
        _setStatus('Aucune imprimante detectee.', true);
      } else {
        _selectedDevice ??= _devices.first;
      }
    } catch (error) {
      _setStatus('Erreur lors du scan: $error', true);
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> testPrint({int? serviceId}) async {
    _isTesting = true;
    notifyListeners();
    try {
      await _runTestPrintService(serviceId);
    } finally {
      _isTesting = false;
      notifyListeners();
    }
  }

  Future<void> testPrintAllServices() async {
    if (_services.isEmpty) {
      await testPrint(serviceId: _activeServiceId);
      return;
    }
    _isTesting = true;
    notifyListeners();
    try {
      for (final service in _services) {
        await _runTestPrintService(service.id);
      }
      _setStatus('Tous les tickets exemple ont ete imprimes.', false);
    } finally {
      _isTesting = false;
      notifyListeners();
    }
  }

  Future<void> printKioskQueueTicket({
    required int queueNumber,
    required String? companyName,
    int? serviceId,
  }) async {
    final snapshot = await _resolveSnapshot(serviceId);
    final service = _resolveService(serviceId);
    final selected = snapshot.selectedDevice;
    if (selected == null) {
      _setStatus('Selectionnez une imprimante.', true);
      return;
    }
    if (!_supportsType(selected.type) ||
        selected.type == PrinterConnectionType.system) {
      _setStatus('Impression non supportee pour ce type.', true);
      return;
    }

    try {
      final profile = await CapabilityProfile.load();
      final paperSize = _mapPaperSize(snapshot.paperWidth);
      final payload = _buildKioskQueueTicket(
        paperSize,
        profile,
        queueNumber: queueNumber,
        companyName: companyName,
        serviceLabel: _serviceLabel(service),
        autoCut: snapshot.autoCut,
        ticketHeader: snapshot.ticketHeader,
        ticketFooter: snapshot.ticketFooter,
      );
      final response = await _sendToPrinter(
        selected,
        paperSize,
        profile,
        payload,
        port: snapshot.manualPortValue,
      );
      if (response == ConnectionResponse.success) {
        _setStatus('Ticket borne imprime.', false);
      } else {
        _setStatus(_describeResponse(response), true);
      }
    } catch (error) {
      _setStatus('Erreur impression: $error', true);
    }
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
    final snapshot = await _resolveSnapshot(serviceId);
    final service = _resolveService(serviceId);
    final selected = snapshot.selectedDevice;
    if (selected == null) {
      _setStatus('Selectionnez une imprimante.', true);
      return;
    }
    if (!_supportsType(selected.type) ||
        selected.type == PrinterConnectionType.system) {
      _setStatus('Impression non supportee pour ce type.', true);
      return;
    }

    try {
      final profile = await CapabilityProfile.load();
      final paperSize = _mapPaperSize(snapshot.paperWidth);
      final resolvedTemplate = (template ?? 'receipt').toLowerCase();

      final payload = resolvedTemplate == 'kitchen'
          ? _buildKitchenTicket(
              paperSize,
              profile,
              items: items,
              customerName: customerName,
              userLabel: userLabel,
              companyName: companyName,
              serviceLabel: _serviceLabel(service),
              warehouseName: warehouseName,
              autoCut: snapshot.autoCut,
              ticketHeader: snapshot.ticketHeader,
              ticketFooter: snapshot.ticketFooter,
              showCustomerInfo: snapshot.showCustomerInfo,
            )
          : _buildCombinedTicket(
              paperSize,
              profile,
              items: items,
              subTotal: subTotal,
              discount: discount,
              tax: tax,
              shipping: shipping,
              grandTotal: grandTotal,
              currencySymbol: currencySymbol,
              currencyOnRight: currencyOnRight,
              customerName: customerName,
              customerPhone: customerPhone,
              customerEmail: customerEmail,
              userLabel: userLabel,
              companyName: companyName,
              companyAddress: companyAddress,
              companyEmail: companyEmail,
              companyPhone: companyPhone,
              warehouseName: warehouseName,
              serviceLabel: _serviceLabel(service),
              paymentType: paymentType,
              paymentStatus: paymentStatus,
              receivedAmount: receivedAmount,
              changeAmount: change,
              autoCut: snapshot.autoCut,
              ticketHeader: snapshot.ticketHeader,
              ticketFooter: snapshot.ticketFooter,
              showCustomerInfo: snapshot.showCustomerInfo,
              showCustomerPhone: snapshot.showCustomerPhone,
              showCustomerEmail: snapshot.showCustomerEmail,
            );

      final response = await _sendToPrinter(
        selected,
        paperSize,
        profile,
        payload,
        port: snapshot.manualPortValue,
      );
      if (response == ConnectionResponse.success) {
        _setStatus('Ticket imprime.', false);
      } else {
        _setStatus(_describeResponse(response), true);
      }
    } catch (error) {
      _setStatus('Erreur impression: $error', true);
    }
  }

  Future<void> printSalesHistory({
    required List<OrderSummary> orders,
    required RegisterDetails register,
    required String currencySymbol,
    required bool currencyOnRight,
    required String? userLabel,
    int? serviceId,
  }) async {
    final snapshot = await _resolveSnapshot(serviceId);
    final service = _resolveService(serviceId);
    final selected = snapshot.selectedDevice;
    if (selected == null) {
      _setStatus('Selectionnez une imprimante.', true);
      return;
    }
    if (!_supportsType(selected.type) ||
        selected.type == PrinterConnectionType.system) {
      _setStatus('Impression non supportee pour ce type.', true);
      return;
    }

    try {
      final profile = await CapabilityProfile.load();
      final paperSize = _mapPaperSize(snapshot.paperWidth);
      final payload = _buildSalesHistoryTicket(
        paperSize,
        profile,
        orders: orders,
        register: register,
        currencySymbol: currencySymbol,
        currencyOnRight: currencyOnRight,
        userLabel: userLabel,
        serviceLabel: _serviceLabel(service),
        autoCut: snapshot.autoCut,
        ticketHeader: snapshot.ticketHeader,
        ticketFooter: snapshot.ticketFooter,
      );
      final response = await _sendToPrinter(
        selected,
        paperSize,
        profile,
        payload,
        port: snapshot.manualPortValue,
      );
      if (response == ConnectionResponse.success) {
        _setStatus('Historique imprime.', false);
      } else {
        _setStatus(_describeResponse(response), true);
      }
    } catch (error) {
      _setStatus('Erreur impression: $error', true);
    }
  }

  // --------------------- Helpers ---------------------

  _PrinterSnapshot _currentSnapshot() {
    return _PrinterSnapshot(
      connectionType: _connectionType,
      selectedDevice: _selectedDevice,
      paperWidth: _paperWidth,
      paperHeight: _paperHeight,
      autoCut: _autoCut,
      fontScale: _fontScale,
      manualAddress: _manualAddress,
      manualPort: _manualPort,
      ticketHeader: _ticketHeader,
      ticketFooter: _ticketFooter,
      showCustomerInfo: _showCustomerInfo,
      showCustomerPhone: _showCustomerPhone,
      showCustomerEmail: _showCustomerEmail,
    );
  }

  _PrinterSnapshot _snapshotFromSettings(Map<String, dynamic> settings) {
    var resolvedType = _printerTypeFromString(settings['connectionType']);
    if (resolvedType == null || !_supportsType(resolvedType)) {
      resolvedType = _defaultType();
    }
    return _PrinterSnapshot(
      connectionType: resolvedType,
      selectedDevice: _deserializeDevice(settings['selectedDevice']),
      paperWidth: _doubleFrom(settings['paperWidth']) ?? _paperWidth,
      paperHeight: _doubleFrom(settings['paperHeight']) ?? _paperHeight,
      autoCut: _boolFrom(settings['autoCut']) ?? _autoCut,
      fontScale: _doubleFrom(settings['fontScale']) ?? _fontScale,
      manualAddress: _stringFrom(settings['manualAddress']) ?? '',
      manualPort: _stringFrom(settings['manualPort']) ?? '9100',
      ticketHeader: _stringFrom(settings['ticketHeader']) ?? '',
      ticketFooter:
          _stringFrom(settings['ticketFooter']) ?? 'Merci pour votre achat.',
      showCustomerInfo: _boolFrom(settings['showCustomerInfo']) ?? true,
      showCustomerPhone: _boolFrom(settings['showCustomerPhone']) ?? true,
      showCustomerEmail: _boolFrom(settings['showCustomerEmail']) ?? true,
    );
  }

  Future<_PrinterSnapshot> _resolveSnapshot(int? serviceId) async {
    if (serviceId == null || serviceId == _activeServiceId) {
      return _currentSnapshot();
    }
    final stored = await _storage.read(null);
    final settings = _extractServiceSettings(stored, _serviceKey(serviceId));
    if (settings == null) {
      return _currentSnapshot();
    }
    return _snapshotFromSettings(settings);
  }

  String _formatReceiptAmount(double value, String symbol, bool symbolOnRight) {
    final formatted = NumberFormat.currency(symbol: '', decimalDigits: 2)
        .format(value)
        .trim();
    final trimmedSymbol = symbol.trim();
    if (trimmedSymbol.isEmpty) return formatted;
    return symbolOnRight
        ? '$formatted $trimmedSymbol'
        : '$trimmedSymbol $formatted';
  }

  List<int> _buildCombinedTicket(
    PaperSize paperSize,
    CapabilityProfile profile, {
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
    required String serviceLabel,
    required String paymentType,
    required String paymentStatus,
    required double? receivedAmount,
    required double? changeAmount,
    required bool autoCut,
    required String ticketHeader,
    required String ticketFooter,
    required bool showCustomerInfo,
    required bool showCustomerPhone,
    required bool showCustomerEmail,
  }) {
    final g = Generator(paperSize, profile);
    String fmt(double v) =>
        _formatReceiptAmount(v, currencySymbol, currencyOnRight);
    final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final bytes = <int>[];
    final serverName = (userLabel ?? '').trim();
    final companyTitle = (companyName ?? '').trim();
    final companyAddressLine = (companyAddress ?? '').trim();
    final companyEmailLine = (companyEmail ?? '').trim();
    final companyPhoneLine = (companyPhone ?? '').trim();
    final warehouseLine = (warehouseName ?? '').trim();
    final customerLine = (customerName ?? '').trim();
    final customerPhoneLine = (customerPhone ?? '').trim();
    final customerEmailLine = (customerEmail ?? '').trim();
    final ticketHeaderLine = ticketHeader.trim();
    final ticketFooterLine = ticketFooter.trim();

    final title = companyTitle.isNotEmpty ? companyTitle : 'Ticket';
    bytes.addAll(
      g.text(
        title,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    );
    bytes.addAll(
        g.text('Date : $now', styles: const PosStyles(align: PosAlign.center)));
    if (companyAddressLine.isNotEmpty) {
      bytes.addAll(g.text(companyAddressLine,
          styles: const PosStyles(align: PosAlign.center)));
    }
    if (companyEmailLine.isNotEmpty) {
      bytes.addAll(g.text('Email : $companyEmailLine',
          styles: const PosStyles(align: PosAlign.center)));
    }
    if (companyPhoneLine.isNotEmpty) {
      bytes.addAll(g.text('Tel : $companyPhoneLine',
          styles: const PosStyles(align: PosAlign.center)));
    }
    if (warehouseLine.isNotEmpty) {
      bytes.addAll(g.text('Magasin : $warehouseLine',
          styles: const PosStyles(align: PosAlign.center)));
    }
    if (showCustomerInfo && customerLine.isNotEmpty) {
      bytes.addAll(g.text('Client : $customerLine'));
    }
    if (showCustomerPhone && customerPhoneLine.isNotEmpty) {
      bytes.addAll(g.text('Tel client : $customerPhoneLine'));
    }
    if (showCustomerEmail && customerEmailLine.isNotEmpty) {
      bytes.addAll(g.text('Email client : $customerEmailLine'));
    }
    if (serverName.isNotEmpty) {
      bytes.addAll(g.text('Serveur : $serverName'));
    }
    if (serviceLabel.isNotEmpty) {
      bytes.addAll(g.text('Service : $serviceLabel'));
    }
    if (ticketHeaderLine.isNotEmpty) {
      bytes.addAll(g.feed(1));
      bytes.addAll(g.text(ticketHeaderLine,
          styles: const PosStyles(align: PosAlign.center)));
    }
    bytes.addAll(g.hr());

    for (final item in items) {
      final unitPrice =
          item.quantity == 0 ? 0.0 : item.subTotal / item.quantity;
      bytes.addAll(
        g.text(
          item.product.name,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
      );
      bytes.addAll(
        g.row([
          PosColumn(
            text: '${item.quantity} x ${fmt(unitPrice)}',
            width: 8,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: fmt(item.subTotal),
            width: 4,
            styles: const PosStyles(align: PosAlign.right, bold: true),
          ),
        ]),
      );
      if (item.options.isNotEmpty) {
        final optionsLabel = item.options.map((option) {
          final qty = option.quantity;
          final qtyText = qty == qty.roundToDouble()
              ? qty.toStringAsFixed(0)
              : qty.toString();
          return qty <= 1 ? option.name : '${option.name} x$qtyText';
        }).join(', ');
        bytes.addAll(
          g.text(
            '  + $optionsLabel',
            styles: const PosStyles(align: PosAlign.left),
          ),
        );
      }
    }

    bytes.addAll(g.hr());
    bytes.addAll(g.row([
      PosColumn(text: 'Sous-total', width: 8),
      PosColumn(
          text: fmt(subTotal),
          width: 4,
          styles: const PosStyles(align: PosAlign.right)),
    ]));
    if (discount != 0) {
      bytes.addAll(g.row([
        PosColumn(text: 'Remise', width: 8),
        PosColumn(
            text: fmt(discount),
            width: 4,
            styles: const PosStyles(align: PosAlign.right)),
      ]));
    }
    bytes.addAll(g.row([
      PosColumn(text: 'Taxe', width: 8),
      PosColumn(
          text: fmt(tax),
          width: 4,
          styles: const PosStyles(align: PosAlign.right)),
    ]));
    if (shipping != 0) {
      bytes.addAll(g.row([
        PosColumn(text: 'Livraison', width: 8),
        PosColumn(
            text: fmt(shipping),
            width: 4,
            styles: const PosStyles(align: PosAlign.right)),
      ]));
    }
    bytes.addAll(g.hr(ch: '-'));
    bytes.addAll(
      g.row([
        PosColumn(
          text: 'Total',
          width: 8,
          styles: const PosStyles(bold: true, height: PosTextSize.size2),
        ),
        PosColumn(
          text: fmt(grandTotal),
          width: 4,
          styles: const PosStyles(
              align: PosAlign.right, bold: true, height: PosTextSize.size2),
        ),
      ]),
    );
    bytes.addAll(g.hr());
    bytes.addAll(g.row([
      PosColumn(text: 'Paiement', width: 6),
      PosColumn(
        text: paymentType,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]));
    bytes.addAll(g.row([
      PosColumn(text: 'Statut', width: 6),
      PosColumn(
        text: paymentStatus,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]));
    if (receivedAmount != null) {
      bytes.addAll(g.row([
        PosColumn(text: 'Recu', width: 6),
        PosColumn(
          text: fmt(receivedAmount),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]));
    }
    if (changeAmount != null) {
      bytes.addAll(g.row([
        PosColumn(text: 'Rendu', width: 6),
        PosColumn(
          text: fmt(changeAmount),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]));
    }
    bytes.addAll(g.feed(1));
    if (ticketFooterLine.isNotEmpty) {
      bytes.addAll(
        g.text(
          ticketFooterLine,
          styles: const PosStyles(
              align: PosAlign.center, fontType: PosFontType.fontB),
        ),
      );
    }

    // Mini ticket resume
    bytes.addAll(
      g.text(
        title,
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );
    if (serviceLabel.isNotEmpty) {
      bytes.addAll(g.text('Service : $serviceLabel',
          styles: const PosStyles(align: PosAlign.center)));
    }
    bytes.addAll(
        g.text('Date : $now', styles: const PosStyles(align: PosAlign.center)));
    bytes.addAll(g.text('Total : ${fmt(grandTotal)}',
        styles: const PosStyles(align: PosAlign.center, bold: true)));
    _appendCut(bytes, g, autoCut: autoCut);

    return bytes;
  }

  List<int> _buildKioskQueueTicket(
    PaperSize paperSize,
    CapabilityProfile profile, {
    required int queueNumber,
    required String? companyName,
    required String serviceLabel,
    required bool autoCut,
    required String ticketHeader,
    required String ticketFooter,
  }) {
    final g = Generator(paperSize, profile);
    final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final title = (companyName ?? '').trim().isNotEmpty
        ? companyName!.trim()
        : 'Commande borne';
    final ticketHeaderLine = ticketHeader.trim();
    final ticketFooterLine = ticketFooter.trim();
    final bytes = <int>[];

    bytes.addAll(
      g.text(
        title,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    );
    bytes.addAll(g.feed(1));
    if (serviceLabel.isNotEmpty) {
      bytes.addAll(g.text('Service : $serviceLabel',
          styles: const PosStyles(align: PosAlign.center)));
      bytes.addAll(g.feed(1));
    }
    if (ticketHeaderLine.isNotEmpty) {
      bytes.addAll(g.text(ticketHeaderLine,
          styles: const PosStyles(align: PosAlign.center)));
      bytes.addAll(g.feed(1));
    }
    bytes.addAll(
      g.text(
        'Numero $queueNumber',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    );
    bytes.addAll(g.feed(1));
    bytes.addAll(
        g.text('Date : $now', styles: const PosStyles(align: PosAlign.center)));
    if (ticketFooterLine.isNotEmpty) {
      bytes.addAll(g.feed(1));
      bytes.addAll(g.text(ticketFooterLine,
          styles: const PosStyles(align: PosAlign.center)));
    }
    bytes.addAll(g.feed(2));
    _appendCut(bytes, g, autoCut: autoCut);
    return bytes;
  }

  List<int> _buildKitchenTicket(
    PaperSize paperSize,
    CapabilityProfile profile, {
    required List<CartItem> items,
    required String? customerName,
    required String? userLabel,
    required String? companyName,
    required String? warehouseName,
    required String serviceLabel,
    required bool autoCut,
    required String ticketHeader,
    required String ticketFooter,
    required bool showCustomerInfo,
  }) {
    final g = Generator(paperSize, profile);
    final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final ticketHeaderLine = ticketHeader.trim();
    final ticketFooterLine = ticketFooter.trim();
    final bytes = <int>[];

    bytes.addAll(
      g.text(
        companyName != null && companyName.trim().isNotEmpty
            ? companyName.trim()
            : 'Commande cuisine',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    );
    bytes.addAll(
        g.text('Date : $now', styles: const PosStyles(align: PosAlign.center)));
    if (warehouseName != null && warehouseName.trim().isNotEmpty) {
      bytes.addAll(g.text('Magasin : ${warehouseName.trim()}'));
    }
    if (showCustomerInfo &&
        customerName != null &&
        customerName.trim().isNotEmpty) {
      bytes.addAll(g.text('Client : ${customerName.trim()}'));
    }
    if (userLabel != null && userLabel.trim().isNotEmpty) {
      bytes.addAll(g.text('Serveur : ${userLabel.trim()}'));
    }
    if (serviceLabel.isNotEmpty) {
      bytes.addAll(g.text('Service : $serviceLabel'));
    }
    if (ticketHeaderLine.isNotEmpty) {
      bytes.addAll(g.text(ticketHeaderLine,
          styles: const PosStyles(align: PosAlign.center)));
    }
    bytes.addAll(g.hr());

    for (final item in items) {
      bytes.addAll(
        g.row([
          PosColumn(
            text: '${item.quantity.toStringAsFixed(0)}x',
            width: 2,
            styles: const PosStyles(bold: true),
          ),
          PosColumn(
            text: item.product.name,
            width: 10,
            styles: const PosStyles(align: PosAlign.left, bold: true),
          ),
        ]),
      );
      if (item.options.isNotEmpty) {
        final optionsLabel = item.options.map((option) {
          final qty = option.quantity;
          final qtyText = qty == qty.roundToDouble()
              ? qty.toStringAsFixed(0)
              : qty.toString();
          return qty <= 1 ? option.name : '${option.name} x$qtyText';
        }).join(', ');
        bytes.addAll(
          g.text(
            '  + $optionsLabel',
            styles: const PosStyles(align: PosAlign.left),
          ),
        );
      }
    }

    if (ticketFooterLine.isNotEmpty) {
      bytes.addAll(g.hr(ch: '-'));
      bytes.addAll(g.text(ticketFooterLine,
          styles: const PosStyles(align: PosAlign.center)));
    }
    _appendCut(bytes, g, autoCut: autoCut);

    return bytes;
  }

  List<int> _buildSalesHistoryTicket(
    PaperSize paperSize,
    CapabilityProfile profile, {
    required List<OrderSummary> orders,
    required RegisterDetails register,
    required String currencySymbol,
    required bool currencyOnRight,
    required String? userLabel,
    required String serviceLabel,
    required bool autoCut,
    required String ticketHeader,
    required String ticketFooter,
  }) {
    final g = Generator(paperSize, profile);
    String fmt(double v) =>
        _formatReceiptAmount(v, currencySymbol, currencyOnRight);
    final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final serverName = (userLabel ?? '').trim();
    final ticketHeaderLine = ticketHeader.trim();
    final ticketFooterLine = ticketFooter.trim();
    final bytes = <int>[];

    bytes.addAll(
      g.text(
        'Historique des ventes',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    );
    bytes.addAll(g.text('Imprime le : $now',
        styles: const PosStyles(align: PosAlign.center)));
    if (serverName.isNotEmpty) {
      bytes.addAll(g.text('Serveur : $serverName',
          styles: const PosStyles(align: PosAlign.center)));
    }
    if (serviceLabel.isNotEmpty) {
      bytes.addAll(g.text('Service : $serviceLabel',
          styles: const PosStyles(align: PosAlign.center)));
    }
    if (ticketHeaderLine.isNotEmpty) {
      bytes.addAll(g.text(ticketHeaderLine,
          styles: const PosStyles(align: PosAlign.center)));
    }
    bytes.addAll(g.hr());
    bytes.addAll(g.text('Ventes : ${orders.length}',
        styles: const PosStyles(align: PosAlign.left)));
    bytes.addAll(g.text('Articles : ${register.itemsCount}',
        styles: const PosStyles(align: PosAlign.left)));
    bytes.addAll(g.text('Total ventes : ${fmt(register.salesAmount)}',
        styles: const PosStyles(align: PosAlign.left)));

    // Accumulate quantities and totals per product
    final Map<String, _ProductAggregate> aggregates = {};
    for (final order in orders) {
      final names = order.productNames.isNotEmpty
          ? order.productNames
          : [
              order.referenceCode.isNotEmpty
                  ? order.referenceCode
                  : 'Commande #${order.id}'
            ];
      for (final name in names) {
        final key = name.trim();
        if (key.isEmpty) continue;
        final agg = aggregates.putIfAbsent(key, () => _ProductAggregate());
        agg.add(order.itemCount, order.grandTotal);
      }
    }

    // Table header
    bytes.addAll(
      g.row([
        PosColumn(
          text: 'Vente / Produits',
          width: 8,
          styles: const PosStyles(
              align: PosAlign.left, bold: true, fontType: PosFontType.fontB),
        ),
        PosColumn(
          text: 'Qté',
          width: 2,
          styles: const PosStyles(
              align: PosAlign.center, bold: true, fontType: PosFontType.fontB),
        ),
        PosColumn(
          text: 'Total',
          width: 2,
          styles: const PosStyles(
              align: PosAlign.right, bold: true, fontType: PosFontType.fontB),
        ),
      ]),
    );
    bytes.addAll(g.hr(ch: '-'));

    final entries = aggregates.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    for (final entry in entries) {
      bytes.addAll(
        g.row([
          PosColumn(
            text: entry.key,
            width: 8,
            styles: const PosStyles(fontType: PosFontType.fontB),
          ),
          PosColumn(
            text: entry.value.quantity.toString(),
            width: 2,
            styles: const PosStyles(
                align: PosAlign.center, fontType: PosFontType.fontB),
          ),
          PosColumn(
            text: fmt(entry.value.total),
            width: 2,
            styles: const PosStyles(
                align: PosAlign.right, fontType: PosFontType.fontB),
          ),
        ]),
      );
    }

    if (ticketFooterLine.isNotEmpty) {
      bytes.addAll(g.hr(ch: '-'));
      bytes.addAll(g.text(ticketFooterLine,
          styles: const PosStyles(align: PosAlign.center)));
    }
    _appendCut(bytes, g, autoCut: autoCut);

    return bytes;
  }

  Future<ConnectionResponse> _sendToPrinter(
    PrinterDeviceInfo device,
    PaperSize paperSize,
    CapabilityProfile profile,
    List<int> bytes, {
    required int port,
  }) async {
    switch (device.type) {
      case PrinterConnectionType.lan:
      case PrinterConnectionType.wifi:
        final manager = NetworkPrinterManager(
          device.printer,
          paperSize,
          profile,
          port: port,
        );
        final connected = await manager.connect();
        if (connected != ConnectionResponse.success) return connected;
        final written = await manager.writeBytes(bytes, isDisconnect: false);
        await manager.disconnect(timeout: const Duration(milliseconds: 300));
        return written;
      case PrinterConnectionType.usb:
        final manager = USBPrinterManager(device.printer, paperSize, profile);
        final connected = await manager.connect();
        if (connected != ConnectionResponse.success) return connected;
        final written = await manager.writeBytes(bytes, isDisconnect: false);
        await manager.disconnect(timeout: const Duration(milliseconds: 300));
        return written;
      case PrinterConnectionType.bluetooth:
        final manager = BluetoothPrinterManager(
          device.printer,
          paperSize,
          profile,
        );
        final connected = await manager.connect();
        if (connected != ConnectionResponse.success) return connected;
        final written = await manager.writeBytes(bytes, isDisconnect: false);
        await manager.disconnect(timeout: const Duration(milliseconds: 300));
        return written;
      case PrinterConnectionType.system:
        return ConnectionResponse.unsupport;
    }
  }

  bool _supportsType(PrinterConnectionType type) {
    if (kIsWeb) return false;
    switch (type) {
      case PrinterConnectionType.lan:
      case PrinterConnectionType.wifi:
        return true;
      case PrinterConnectionType.usb:
        return defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.windows;
      case PrinterConnectionType.bluetooth:
        return defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS;
      case PrinterConnectionType.system:
        return false;
    }
  }

  PaperSize _mapPaperSize(double width) {
    if (width <= 58) return PaperSize.mm58;
    if (width <= 72) return PaperSize.mm72;
    return PaperSize.mm80;
  }

  String _describeResponse(ConnectionResponse response) {
    switch (response) {
      case ConnectionResponse.success:
        return 'Impression reussie';
      case ConnectionResponse.timeout:
        return 'Connexion expirée.';
      case ConnectionResponse.printerNotSelected:
        return 'Imprimante introuvable.';
      case ConnectionResponse.printerNotConnected:
        return 'Imprimante non connectee.';
      case ConnectionResponse.printerNotWritable:
        return 'Imprimante non disponible.';
      case ConnectionResponse.printInProgress:
        return 'Impression deja en cours.';
      case ConnectionResponse.unsupport:
        return 'Fonction non supportee.';
      case ConnectionResponse.unknown:
      default:
        return 'Erreur inconnue.';
    }
  }

  void _setStatus(String message, bool isError) {
    _statusMessage = message;
    _statusIsError = isError;
    notifyListeners();
  }

  Future<void> _runTestPrintService(int? serviceId) async {
    final service = _resolveService(serviceId);
    if (service?.isKiosk == true) {
      await printKioskQueueTicket(
        queueNumber: 152,
        companyName: 'POS SAAS',
        serviceId: service?.id ?? _activeServiceId,
      );
      return;
    }
    await printSaleReceipt(
      items: _buildExampleItems(),
      subTotal: 95,
      discount: 5,
      tax: 9.5,
      shipping: 0,
      grandTotal: 99.5,
      currencySymbol: 'DH',
      currencyOnRight: true,
      customerName: 'Client exemple',
      userLabel: 'Caissier',
      companyName: 'POS SAAS',
      companyAddress: 'Centre-ville',
      companyEmail: 'contact@example.com',
      companyPhone: '0600000000',
      warehouseName: 'Boutique principale',
      companyLogoUrl: null,
      paymentType: 'Espece',
      paymentStatus: 'Paye',
      receivedAmount: 100,
      change: 0.5,
      serviceId: service?.id ?? _activeServiceId,
      template: service?.isKitchen == true
          ? 'kitchen'
          : (service?.template ?? 'receipt'),
    );
  }

  void _appendCut(
    List<int> bytes,
    Generator generator, {
    required bool autoCut,
  }) {
    bytes.addAll(generator.feed(6));
    if (autoCut) {
      bytes.addAll(generator.cut(mode: PosCutMode.full));
    } else {
      bytes.addAll(generator.feed(2));
    }
  }

  String _serviceLabel(PrintingService? service) {
    if (service == null) return '';
    if (service.isKitchen) return 'Cuisine';
    if (service.isKiosk) return 'Borne';
    if (service.isReceipt) return 'POS';
    final name = service.name.trim();
    return name.isEmpty ? '' : name;
  }

  PrintingService? _resolveService(int? serviceId) {
    final resolvedId = serviceId ?? _activeServiceId;
    if (resolvedId == null)
      return _services.isNotEmpty ? _services.first : null;
    for (final service in _services) {
      if (service.id == resolvedId) return service;
    }
    return _services.isNotEmpty ? _services.first : null;
  }

  List<CartItem> _buildExampleItems() {
    return [
      CartItem(
        product: Product(
          id: 1,
          name: 'Burger maison',
          code: 'BG-01',
          price: 45,
          cost: 0,
          stockQuantity: 0,
          taxValue: 0,
          options: const [],
        ),
        quantity: 2,
        options: const [
          ProductOption(id: 1, name: 'Fromage', quantity: 1),
          ProductOption(id: 2, name: 'Sauce maison', quantity: 1),
        ],
      ),
      CartItem(
        product: Product(
          id: 2,
          name: 'Boisson',
          code: 'DR-01',
          price: 5,
          cost: 0,
          stockQuantity: 0,
          taxValue: 0,
          options: const [],
        ),
        quantity: 1,
      ),
    ];
  }

  Future<void> _loadSettings() async {
    final stored = await _storage.read(null);
    final serviceKey = _serviceKey(_activeServiceId);
    final settings = _extractServiceSettings(stored, serviceKey);
    if (settings != null) {
      final storedType = _printerTypeFromString(settings['connectionType']);
      if (storedType != null && _supportsType(storedType)) {
        _connectionType = storedType;
      } else {
        _connectionType = _defaultType();
      }
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
      _selectedDevice = _deserializeDevice(settings['selectedDevice']);
      _showDiscoveredPrinters = _selectedDevice == null;
    } else {
      _resetToDefaults();
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
      'selectedDevice': _serializeDevice(_selectedDevice),
    };
    final stored = await _storage.read(null) ?? <String, dynamic>{};
    final services = _asStringKeyMap(stored['services']) ?? <String, dynamic>{};
    services[_serviceKey(_activeServiceId)] = payload;
    stored['services'] = services;
    await _storage.write(null, stored);
  }

  void _resetToDefaults() {
    _connectionType = _defaultType();
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
    _selectedDevice = null;
    _showDiscoveredPrinters = true;
  }

  Map<String, dynamic>? _serializeDevice(PrinterDeviceInfo? device) {
    if (device == null) return null;
    final printer = device.printer;
    return {
      'type': device.type.name,
      'printer': {
        'id': printer.id,
        'name': printer.name,
        'address': printer.address,
        'deviceId': printer.deviceId,
        'vendorId': printer.vendorId,
        'productId': printer.productId,
        'connected': printer.connected,
        'type': printer.type,
        'connectionType': printer.connectionType?.name,
      },
    };
  }

  PrinterDeviceInfo? _deserializeDevice(dynamic raw) {
    if (raw == null) return null;
    final data = _asStringKeyMap(raw);
    if (data == null) return null;
    final type = _printerTypeFromString(data['type']);
    final printer = _deserializePrinter(data['printer']);
    if (type == null || printer == null) return null;
    return PrinterDeviceInfo(printer: printer, type: type);
  }

  POSPrinter? _deserializePrinter(dynamic raw) {
    final data = _asStringKeyMap(raw);
    if (data == null) return null;
    final printer = POSPrinter(
      id: _stringFrom(data['id']),
      name: _stringFrom(data['name']),
      address: _stringFrom(data['address']),
      deviceId: _intFrom(data['deviceId']),
      vendorId: _intFrom(data['vendorId']),
      productId: _intFrom(data['productId']),
      connected: _boolFrom(data['connected']) ?? false,
      type: _intFrom(data['type']) ?? 0,
    );
    printer.connectionType = _connectionTypeFromString(data['connectionType']);
    return printer;
  }

  Map<String, dynamic>? _extractServiceSettings(
    Map<String, dynamic>? stored,
    String serviceKey,
  ) {
    if (stored == null) return null;
    final services = _asStringKeyMap(stored['services']);
    if (services != null) {
      final candidate = _asStringKeyMap(services[serviceKey]);
      if (candidate != null) {
        return candidate;
      }
    }
    if (stored.containsKey('connectionType') ||
        stored.containsKey('paperWidth') ||
        stored.containsKey('selectedDevice')) {
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
    switch (raw.toLowerCase()) {
      case 'lan':
        return PrinterConnectionType.lan;
      case 'wifi':
        return PrinterConnectionType.wifi;
      case 'usb':
        return PrinterConnectionType.usb;
      case 'bluetooth':
        return PrinterConnectionType.bluetooth;
      case 'system':
        return PrinterConnectionType.system;
    }
    return null;
  }

  ConnectionType? _connectionTypeFromString(dynamic raw) {
    if (raw is! String) return null;
    for (final type in ConnectionType.values) {
      if (type.name == raw) return type;
    }
    return null;
  }

  double? _doubleFrom(dynamic value) {
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

  String? _stringFrom(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }
}

class _PrinterSnapshot {
  _PrinterSnapshot({
    required this.connectionType,
    required this.selectedDevice,
    required this.paperWidth,
    required this.paperHeight,
    required this.autoCut,
    required this.fontScale,
    required this.manualAddress,
    required this.manualPort,
    required this.ticketHeader,
    required this.ticketFooter,
    required this.showCustomerInfo,
    required this.showCustomerPhone,
    required this.showCustomerEmail,
  });

  final PrinterConnectionType connectionType;
  final PrinterDeviceInfo? selectedDevice;
  final double paperWidth;
  final double paperHeight;
  final bool autoCut;
  final double fontScale;
  final String manualAddress;
  final String manualPort;
  final String ticketHeader;
  final String ticketFooter;
  final bool showCustomerInfo;
  final bool showCustomerPhone;
  final bool showCustomerEmail;

  int get manualPortValue => int.tryParse(manualPort) ?? 9100;
}

class _ProductAggregate {
  int quantity = 0;
  double total = 0;

  void add(int qty, double amount) {
    quantity += qty;
    total += amount;
  }
}
