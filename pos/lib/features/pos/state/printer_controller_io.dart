import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:pos_printer_manager/models/pos_printer.dart';

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

  String get name => printer.name ?? printer.address ?? printer.id ?? 'Sans nom';
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
  final bool _isTesting = false;
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
  String? _activeUserLabel;
  bool _hasLoadedInitialSettings = false;

  UnmodifiableListView<PrinterDeviceInfo> get devices => UnmodifiableListView(_devices);
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

  bool get isTestEnabled => _selectedDevice != null && !_isTesting;
  bool get canDiscover => !_isScanning && _supportsType(connectionType);
  bool get canUseManualEntry =>
      connectionType == PrinterConnectionType.lan || connectionType == PrinterConnectionType.wifi;
  bool get currentTypeSupported => _supportsType(_connectionType);
  List<PrinterConnectionType> get availableTypes =>
      PrinterConnectionType.values.where(_supportsType).toList();

  Future<void> attachToUser(String? userLabel) async {
    final normalized = userLabel?.trim();
    if (_activeUserLabel == normalized && _hasLoadedInitialSettings) {
      return;
    }
    _activeUserLabel = normalized;
    await _loadSettings();
  }

  Future<void> persistSettings() async {
    await _persistSettings();
    _setStatus('Parametres imprimante enregistres.', false);
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
    if (_connectionType == type || !_supportsType(type)) return;
    _connectionType = type;
    _statusMessage = null;
    _selectedDevice = null;
    _devices.clear();
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

  void updateWifiSsid(String value) {
    _wifiSsid = value;
  }

  void updateWifiPassword(String value) {
    _wifiPassword = value;
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
    notifyListeners();
    _setStatus('Imprimante $address ajoutee manuellement.', false);
  }

  int get manualPortValue => int.tryParse(_manualPort) ?? 9100;

  Future<void> discoverPrinters() async {
    if (!_supportsType(connectionType)) {
      _setStatus('Ce type de connexion nest pas disponible sur cette plateforme.', true);
      return;
    }
    _isScanning = true;
    _statusMessage = null;
    _devices.clear();
    notifyListeners();
    try {
      List<PrinterDeviceInfo> found = [];
      switch (connectionType) {
        case PrinterConnectionType.lan:
        case PrinterConnectionType.wifi:
          final printers = await NetworkPrinterManager.discover();
          found = printers.map((p) => PrinterDeviceInfo(printer: p, type: connectionType)).toList();
          break;
        case PrinterConnectionType.usb:
          final printers = await USBPrinterManager.discover();
          found = printers.map((p) => PrinterDeviceInfo(printer: p, type: connectionType)).toList();
          break;
        case PrinterConnectionType.bluetooth:
          final printers = await BluetoothPrinterManager.discover();
          found = printers.map((p) => PrinterDeviceInfo(printer: p, type: connectionType)).toList();
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

  Future<void> testPrint() async {
    _setStatus('Test impression desactive.', true);
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
    final selected = _selectedDevice;
    if (selected == null) {
      _setStatus('Selectionnez une imprimante.', true);
      return;
    }
    if (!_supportsType(selected.type) || selected.type == PrinterConnectionType.system) {
      _setStatus('Impression non supportee pour ce type.', true);
      return;
    }

    try {
      final profile = await CapabilityProfile.load();
      final paperSize = _mapPaperSize();

      final payload = _buildCombinedTicket(
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
        userLabel: userLabel,
        companyName: companyName,
        warehouseName: warehouseName,
        paymentType: paymentType,
        paymentStatus: paymentStatus,
      );

      final response = await _sendToPrinter(
        selected,
        paperSize,
        profile,
        payload,
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
  }) async {
    final selected = _selectedDevice;
    if (selected == null) {
      _setStatus('Selectionnez une imprimante.', true);
      return;
    }
    if (!_supportsType(selected.type) || selected.type == PrinterConnectionType.system) {
      _setStatus('Impression non supportee pour ce type.', true);
      return;
    }

    try {
      final profile = await CapabilityProfile.load();
      final paperSize = _mapPaperSize();
      final payload = _buildSalesHistoryTicket(
        paperSize,
        profile,
        orders: orders,
        register: register,
        currencySymbol: currencySymbol,
        currencyOnRight: currencyOnRight,
        userLabel: userLabel,
      );
      final response = await _sendToPrinter(
        selected,
        paperSize,
        profile,
        payload,
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

  String _formatReceiptAmount(double value, String symbol, bool symbolOnRight) {
    final formatted = NumberFormat.currency(symbol: '', decimalDigits: 2).format(value).trim();
    final trimmedSymbol = symbol.trim();
    if (trimmedSymbol.isEmpty) return formatted;
    return symbolOnRight ? '$formatted $trimmedSymbol' : '$trimmedSymbol $formatted';
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
    required String? userLabel,
    required String? companyName,
    required String? warehouseName,
    required String paymentType,
    required String paymentStatus,
  }) {
    final g = Generator(paperSize, profile);
    String fmt(double v) => _formatReceiptAmount(v, currencySymbol, currencyOnRight);
    final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final bytes = <int>[];
    final serverName = (userLabel ?? '').trim();

    // Ticket principal
    final title = (companyName ?? '').isNotEmpty ? (companyName ?? '') : 'Ticket';
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
    bytes.addAll(g.text('Date : $now', styles: const PosStyles(align: PosAlign.center)));
    if (serverName.isNotEmpty) {
      bytes.addAll(g.text('Serveur : $serverName'));
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
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true),
          ),
          PosColumn(
            text: fmt(item.subTotal),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
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
   
    if (discount != 0) {
      bytes.addAll(g.row([
        PosColumn(text: 'Remise', width: 8),
        PosColumn(text: fmt(discount), width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]));
    }
   
    bytes.addAll(g.hr());
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
          styles: const PosStyles(align: PosAlign.right, bold: true, height: PosTextSize.size2),
        ),
      ]),
    );
   // bytes.addAll(g.text('Paiement : $paymentType'));
   // bytes.addAll(g.text('Statut : $paymentStatus'));

    bytes.addAll(g.feed(2));
    if (_wifiSsid.trim().isNotEmpty) {
      bytes.addAll(g.text('Wi-fi : ${_wifiSsid.trim()}'));
    }
    if (_wifiPassword.trim().isNotEmpty) {
      bytes.addAll(g.text('Code : ${_wifiPassword.trim()}'));
    }
    bytes.addAll(
      g.text(
        'Merci pour votre achat.',
        styles: const PosStyles(align: PosAlign.center, fontType: PosFontType.fontB),
      ),
    );
    bytes.addAll(g.feed(1));
    if (_autoCut) {
      bytes.addAll(g.cut());
    } else {
      bytes.addAll(g.feed(3));
    }

    // Mini ticket apres coupe
    bytes.addAll(
      g.text(
        'ticket',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );
    bytes.addAll(g.text('Date : $now', styles: const PosStyles(align: PosAlign.center)));
    if (serverName.isNotEmpty) {
      bytes.addAll(g.text('Serveur : $serverName'));
    }

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
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true),
          ),
          PosColumn(
            text: fmt(item.subTotal),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
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
    bytes.addAll(g.feed(1));
    if (_autoCut) {
      bytes.addAll(g.cut());
    } else {
      bytes.addAll(g.feed(3));
    }

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
  }) {
    final g = Generator(paperSize, profile);
    String fmt(double v) => _formatReceiptAmount(v, currencySymbol, currencyOnRight);
    final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final serverName = (userLabel ?? '').trim();
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
    bytes.addAll(g.text('Imprime le : $now', styles: const PosStyles(align: PosAlign.center)));
    if (serverName.isNotEmpty) {
      bytes.addAll(g.text('Serveur : $serverName', styles: const PosStyles(align: PosAlign.center)));
    }
    bytes.addAll(g.hr());
    bytes.addAll(g.text('Ventes : ${orders.length}', styles: const PosStyles(align: PosAlign.left)));
    bytes.addAll(g.text('Articles : ${register.itemsCount}', styles: const PosStyles(align: PosAlign.left)));
    bytes.addAll(g.text('Total ventes : ${fmt(register.salesAmount)}', styles: const PosStyles(align: PosAlign.left)));

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
          styles: const PosStyles(align: PosAlign.left, bold: true, fontType: PosFontType.fontB),
        ),
        PosColumn(
          text: 'Qté',
          width: 2,
          styles: const PosStyles(align: PosAlign.center, bold: true, fontType: PosFontType.fontB),
        ),
        PosColumn(
          text: 'Total',
          width: 2,
          styles: const PosStyles(align: PosAlign.right, bold: true, fontType: PosFontType.fontB),
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
            styles: const PosStyles(align: PosAlign.center, fontType: PosFontType.fontB),
          ),
          PosColumn(
            text: fmt(entry.value.total),
            width: 2,
            styles: const PosStyles(align: PosAlign.right, fontType: PosFontType.fontB),
          ),
        ]),
      );
    }

    bytes.addAll(g.feed(1));
    if (_autoCut) {
      bytes.addAll(g.cut());
    } else {
      bytes.addAll(g.feed(3));
    }

    return bytes;
  }

  Future<ConnectionResponse> _sendToPrinter(
    PrinterDeviceInfo device,
    PaperSize paperSize,
    CapabilityProfile profile,
    List<int> bytes,
  ) async {
    switch (device.type) {
      case PrinterConnectionType.lan:
      case PrinterConnectionType.wifi:
        final manager = NetworkPrinterManager(
          device.printer,
          paperSize,
          profile,
          port: manualPortValue,
        );
        final connected = await manager.connect();
        if (connected != ConnectionResponse.success) return connected;
        return manager.writeBytes(bytes);
      case PrinterConnectionType.usb:
        final manager = USBPrinterManager(device.printer, paperSize, profile);
        final connected = await manager.connect();
        if (connected != ConnectionResponse.success) return connected;
        return manager.writeBytes(bytes);
      case PrinterConnectionType.bluetooth:
        final manager = BluetoothPrinterManager(
          device.printer,
          paperSize,
          profile,
        );
        final connected = await manager.connect();
        if (connected != ConnectionResponse.success) return connected;
        return manager.writeBytes(bytes);
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

  PaperSize _mapPaperSize() {
    if (_paperWidth <= 58) return PaperSize.mm58;
    if (_paperWidth <= 72) return PaperSize.mm72;
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

  Future<void> _loadSettings() async {
    final stored = await _storage.read(_activeUserLabel);
    if (stored != null) {
      final storedType = _printerTypeFromString(stored['connectionType']);
      if (storedType != null && _supportsType(storedType)) {
        _connectionType = storedType;
      }
      _paperWidth = _doubleFrom(stored['paperWidth']) ?? _paperWidth;
      _paperHeight = _doubleFrom(stored['paperHeight']) ?? _paperHeight;
      _autoCut = _boolFrom(stored['autoCut']) ?? _autoCut;
      _fontScale = _doubleFrom(stored['fontScale']) ?? _fontScale;
      _manualAddress = _stringFrom(stored['manualAddress']) ?? '';
      _manualPort = _stringFrom(stored['manualPort']) ?? '9100';
      _wifiSsid = _stringFrom(stored['wifiSsid']) ?? '';
      _wifiPassword = _stringFrom(stored['wifiPassword']) ?? '';
      _selectedDevice = _deserializeDevice(stored['selectedDevice']);
    } else {
      _selectedDevice = null;
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
      'wifiSsid': _wifiSsid,
      'wifiPassword': _wifiPassword,
      'selectedDevice': _serializeDevice(_selectedDevice),
    };
    await _storage.write(_activeUserLabel, payload);
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

  Map<String, dynamic>? _asStringKeyMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry('$key', val));
    }
    return null;
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

class _ProductAggregate {
  int quantity = 0;
  double total = 0;

  void add(int qty, double amount) {
    quantity += qty;
    total += amount;
  }
}
