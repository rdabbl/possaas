import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../core/models/cart_item.dart';
import '../../../../core/models/product.dart';
import '../../../../core/models/product_category.dart';
import '../../../../core/models/customer.dart';
import '../../../../core/models/order_summary.dart';
import '../../../../core/models/register_details.dart';
import '../../../../core/models/currency.dart';
import '../../../../core/models/offline_sale.dart';
import '../../../../core/models/payment_method.dart';
import '../../../../core/models/shipping_method.dart';
import '../../../../core/models/warehouse.dart';
import '../../../../core/models/product_option.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../../../auth/state/auth_controller.dart';
import '../../state/appearance_controller.dart';
import '../../state/pos_controller.dart';
import '../../state/printer_controller.dart';
import '../../models/printing_service.dart';
import 'kiosk_page.dart';
import 'webview_page.dart';
import '../widgets/product_grid.dart';
import 'package:pos_nimirik/core/i18n/i18n.dart';

String _formatCurrency(double value, String symbol, bool symbolOnRight) {
  final formatted = NumberFormat.currency(
    symbol: '',
    decimalDigits: 2,
  ).format(value).trim();
  final trimmedSymbol = symbol.trim();
  if (trimmedSymbol.isEmpty) {
    return formatted;
  }
  return symbolOnRight
      ? '$formatted $trimmedSymbol'
      : '$trimmedSymbol $formatted';
}

List<PrintingService> _resolvePrintingServices(PosController controller) {
  final services = controller.activePrintingServices;
  if (services.isNotEmpty) return services;
  final storeId = controller.selectedWarehouse?.id ?? 0;
  return [PrintingService.fallback(storeId: storeId)];
}

List<PrintingService> _servicesForTemplate(
  List<PrintingService> services,
  String template, {
  int storeId = 0,
}) {
  final normalized = template.trim().toLowerCase();
  final filtered = services
      .where((service) => service.template.trim().toLowerCase() == normalized)
      .toList();
  if (filtered.isNotEmpty) return filtered;
  if (normalized == 'receipt' && services.isEmpty) {
    return [PrintingService.fallback(storeId: storeId)];
  }
  return <PrintingService>[];
}

OutlineInputBorder _outlineInputBorder(
  BuildContext context, {
  double radius = 12,
  double width = 1.2,
}) {
  final color = Theme.of(context).colorScheme.primary;
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(radius),
    borderSide: BorderSide(color: color, width: width),
  );
}

const List<int> _historyPresetHours = [
  12,
  24,
  48,
  24 * 7,
  24 * 15,
  24 * 30,
];

String _historyLabelForHours(int hours) {
  switch (hours) {
    case 12:
      return tr('12h');
    case 24:
      return tr('24h');
    case 48:
      return tr('48h');
    case 168:
      return tr('7j');
    case 360:
      return tr('15j');
    case 720:
      return tr('1 mois');
    default:
      return '$hours${tr('h')}';
  }
}

const double _posDesignWidth = 1440;
const double _posDesignHeight = 860;
const Color _posYellow = Color(0xFFF7C045);
const Color _posYellowSoft = Color(0xFFFFF6DE);
const Color _posYellowBorder = Color(0xFFF6D58F);

class PosPage extends StatefulWidget {
  const PosPage({super.key});

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _shippingController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _loyaltyController = TextEditingController();

  double _lastDiscount = 0;
  double _lastShipping = 0;
  double _lastTax = 0;
  double _lastLoyalty = 0;
  bool _messageClearScheduled = false;
  bool _showTopStatusBanner = true;
  String _bannerSignature = '';
  Timer? _topBannerTimer;
  late final PosController _posController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_handleSearchChange);
    _posController = context.read<PosController>();
    _posController.startAutoSync(interval: const Duration(minutes: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final posController = _posController;
      final auth = context.read<AuthController>();
      final printerController = context.read<PrinterSettingsController>();
      await posController.updateActiveUserLabel(auth.userLabel);
      await printerController.attachToUser(null);
      printerController.syncServices(_resolvePrintingServices(posController));
      await posController.loadOrderHistory();
      await posController.loadHistoryUsers();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _posController.syncNow();
    }
  }

  Future<void> _handleWarehouseChange(Warehouse? warehouse) async {
    await _posController.selectWarehouse(warehouse);
    final printer = context.read<PrinterSettingsController>();
    printer.syncServices(_resolvePrintingServices(_posController));
  }

  Future<void> _attemptReconnect() async {
    final auth = context.read<AuthController>();
    final pos = context.read<PosController>();
    pos.clearMessages();
    // Essayer de repasser en ligne et relancer une authentification si possible.
    final ok = await auth.tryReauthenticate();
    if (!ok) {
      pos.setOfflineMode(true);
      _showReconnectSnack(
        tr('Impossible de se reconnecter. Mode hors ligne conserve.'),
      );
      return;
    }

    pos.setOfflineMode(false);
    try {
      await pos.refreshProducts();
      await pos.loadOrderHistory();
      await pos.loadHistoryUsers();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        pos.setOfflineMode(true);
        _showReconnectSnack(
          tr('Session expiree. Utilisation du mode hors ligne.'),
        );
        return;
      }
      pos.setOfflineMode(true);
      _showReconnectSnack(
        '${tr('Rafraichissement impossible')} (${e.message}). '
        '${tr('Mode hors ligne conserve.')}',
      );
    } catch (_) {
      pos.setOfflineMode(true);
      _showReconnectSnack(
        tr('Rafraichissement impossible. Mode hors ligne conserve.'),
      );
    }
  }

  void _showReconnectSnack(String message) {
    // Status is now visible in the banner indicator; keep this silent.
  }

  @override
  void dispose() {
    _topBannerTimer?.cancel();
    _searchController.dispose();
    _notesController.dispose();
    _discountController.dispose();
    _shippingController.dispose();
    _taxController.dispose();
    _loyaltyController.dispose();
    _posController.stopAutoSync();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Consumer<PosController>(
      builder: (context, controller, _) {
        _syncFormControllers(controller);
        _maybeScheduleBannerClear(controller);
        if (controller.offlineMode != auth.offlineMode) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && controller.offlineMode != auth.offlineMode) {
              controller.setOfflineMode(auth.offlineMode);
            }
          });
        }
        final content = controller.isLoading && controller.products.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (_showTopStatusBanner) ...[
                    _MainStatusBanner(
                      errorMessage: controller.errorMessage,
                      successMessage: controller.successMessage,
                      offlineMode: controller.offlineMode,
                      onDismiss: controller.clearMessages,
                    ),
                    const SizedBox(height: 10),
                  ],
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDFDFB),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 7,
                            child: _CatalogPanel(
                              controller: controller,
                              searchController: _searchController,
                              onOpenMenu: _openQuickMenu,
                              onOpenHistory: _openOrderHistory,
                              onOpenCalculator: _openCalculator,
                              onOpenKiosk: _openKioskPage,
                              onOpenWebView: _openWebViewPage,
                              onRefresh: () => controller.refreshProducts(
                                skipSyncOffline: true,
                              ),
                              onCashInHand: () =>
                                  _promptCashInHandIfNeeded(force: true),
                              onSync: controller.refreshProducts,
                              onReconnect: _attemptReconnect,
                              offlineMode: controller.offlineMode,
                              lastSyncAt: controller.lastSyncAt,
                              onLogout: () async {
                                await context.read<AuthController>().logout();
                              },
                              onSelectProduct: (product) =>
                                  _handleProductSelection(
                                controller,
                                product,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 332,
                            child: _CartPanel(
                              controller: controller,
                              discountController: _discountController,
                              shippingController: _shippingController,
                              taxController: _taxController,
                              loyaltyController: _loyaltyController,
                              notesController: _notesController,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );

        final appearance = context.watch<AppearanceController>();
        final rawBg = appearance.backgroundImageUrl.trim();
        final imageProvider = rawBg.isEmpty
            ? null
            : (rawBg.startsWith('http://') || rawBg.startsWith('https://'))
                ? NetworkImage(rawBg) as ImageProvider
                : AssetImage(rawBg);

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Container(
              decoration: imageProvider == null
                  ? null
                  : BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.22),
                          BlendMode.darken,
                        ),
                      ),
                    ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const outerPadding = 6.0;
                  return Padding(
                    padding: const EdgeInsets.all(outerPadding),
                    child: Center(
                      child: ClipRect(
                        child: SizedBox(
                          width: constraints.maxWidth - (outerPadding * 2),
                          height: constraints.maxHeight - (outerPadding * 2),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              width: _posDesignWidth,
                              height: _posDesignHeight,
                              child: content,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleSearchChange() {
    setState(() {});
  }

  Future<void> _handleProductSelection(
    PosController controller,
    Product product,
  ) async {
    if (product.options.isEmpty) {
      controller.addProduct(product);
      return;
    }
    final selected = await showDialog<List<ProductOption>>(
      context: context,
      builder: (_) => _OptionSelectionDialog(product: product),
    );
    if (selected == null) return;
    controller.addProduct(product, options: selected);
  }

  Future<void> _promptCashInHandIfNeeded({bool force = false}) async {
    final controller = context.read<PosController>();
    if (!force && controller.cashInHand > 0) return;
    final result = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CashInHandDialog(initial: controller.cashInHand),
    );
    if (result != null) {
      controller.setCashInHand(result);
    }
  }

  void _syncFormControllers(PosController controller) {
    if (_lastDiscount != controller.discountInput) {
      _lastDiscount = controller.discountInput;
      _discountController.text = controller.discountInput == 0
          ? ''
          : controller.discountInput.toStringAsFixed(2);
    }
    if (_lastShipping != controller.shipping) {
      _lastShipping = controller.shipping;
      _shippingController.text = controller.shipping == 0
          ? ''
          : controller.shipping.toStringAsFixed(2);
    }
    if (_lastTax != controller.taxRate) {
      _lastTax = controller.taxRate;
      _taxController.text =
          controller.taxRate == 0 ? '' : controller.taxRate.toString();
    }
    if (_lastLoyalty != controller.loyaltyRedeemAmount) {
      _lastLoyalty = controller.loyaltyRedeemAmount;
      _loyaltyController.text = controller.loyaltyRedeemAmount == 0
          ? ''
          : controller.loyaltyRedeemAmount.toStringAsFixed(2);
    }
    if (controller.cartItems.isEmpty && _notesController.text.isNotEmpty) {
      _notesController.clear();
    }
  }

  Future<void> _openOrderHistory() async {
    final pos = context.read<PosController>();
    final printer = context.read<PrinterSettingsController>();
    final auth = context.read<AuthController>();
    await showDialog(
      context: context,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider<PosController>.value(value: pos),
          ChangeNotifierProvider<PrinterSettingsController>.value(
            value: printer,
          ),
          ChangeNotifierProvider<AuthController>.value(value: auth),
        ],
        child: const _OrderHistoryDialog(),
      ),
    );
  }

  Future<void> _openAppearanceSettings() async {
    await showDialog(
      context: context,
      builder: (_) => const _AppearanceSettingsDialog(),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
    );
  }

  bool get _isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  Future<void> _toggleFullScreen() async {
    if (!_isDesktop) {
      _showSnack(tr('Le plein écran est disponible uniquement sur desktop.'));
      return;
    }
    final isFullScreen = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!isFullScreen);
  }

  Future<void> _openCalculator() async {
    await showDialog(
      context: context,
      builder: (_) => const _CalculatorDialog(),
    );
  }

  Future<void> _openPosConfiguration() async {
    final pos = context.read<PosController>();
    await showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider<PosController>.value(
        value: pos,
        child: _PosConfigurationDialog(
          onTestReset: () => pos.resetHistoryStats(),
        ),
      ),
    );
  }

  Future<void> _openKioskPage() async {
    final appearance = context.read<AppearanceController>();
    if (!appearance.kioskEnabled) {
      _showSnack(tr('La borne est désactivée dans la configuration POS.'));
      return;
    }
    final pos = context.read<PosController>();
    final printer = context.read<PrinterSettingsController>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider<PosController>.value(value: pos),
            ChangeNotifierProvider<PrinterSettingsController>.value(
              value: printer,
            ),
          ],
          child: const KioskPage(),
        ),
      ),
    );
  }

  Future<void> _openWebViewPage() async {
    final appearance = context.read<AppearanceController>();
    final raw = appearance.webViewUrl.trim();
    final url = raw.isEmpty ? AppConfig.defaultWebViewUrl : raw;
    if (Uri.tryParse(url) == null) {
      _showSnack(tr('URL WebView invalide.'));
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PosWebViewPage(
          url: url,
          title: tr('Portail web'),
        ),
      ),
    );
  }

  Future<void> _openKioskConfiguration() async {
    await showDialog(
      context: context,
      builder: (_) => const _KioskConfigurationDialog(),
    );
  }

  Future<void> _openPrinterSettings() async {
    final printerController = context.read<PrinterSettingsController>();
    final posController = context.read<PosController>();
    printerController.syncServices(_resolvePrintingServices(posController));
    await showDialog(
      context: context,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider<PrinterSettingsController>.value(
            value: printerController,
          ),
          ChangeNotifierProvider<PosController>.value(value: posController),
        ],
        child: const _PrinterSettingsDialog(),
      ),
    );
  }

  Future<void> _openQuickMenu() async {
    final actions = [
      _ActionMenuItem(
        icon: Icons.tune,
        label: tr('Apparence'),
        onTap: _openAppearanceSettings,
      ),
      _ActionMenuItem(
        icon: Icons.print_outlined,
        label: tr('Imprimante'),
        onTap: _openPrinterSettings,
      ),
      _ActionMenuItem(
        icon: Icons.settings_applications_outlined,
        label: tr('Config POS'),
        onTap: _openPosConfiguration,
      ),
      _ActionMenuItem(
        icon: Icons.storefront_outlined,
        label: tr('Config borne'),
        onTap: _openKioskConfiguration,
      ),
      _ActionMenuItem(
        icon: Icons.public,
        label: tr('Portail web'),
        onTap: _openWebViewPage,
      ),
      if (context.read<AppearanceController>().kioskEnabled)
        _ActionMenuItem(
          icon: Icons.store_mall_directory_outlined,
          label: tr('Interface borne'),
          onTap: _openKioskPage,
        ),
    ];
    await _showActionMenu(context, actions);
  }

  void _maybeScheduleBannerClear(PosController controller) {
    final signature =
        '${controller.offlineMode}|${controller.errorMessage ?? ''}|${controller.successMessage ?? ''}';
    if (_bannerSignature != signature) {
      _bannerSignature = signature;
      _showTopStatusBanner = true;
      _topBannerTimer?.cancel();
      _topBannerTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() => _showTopStatusBanner = false);
      });
    }

    final hasMessage =
        controller.errorMessage != null || controller.successMessage != null;
    if (hasMessage && !_messageClearScheduled) {
      _messageClearScheduled = true;
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;
        controller.clearMessages();
        _messageClearScheduled = false;
      });
    } else if (!hasMessage) {
      _messageClearScheduled = false;
    }
  }
}

class _TopSelectors extends StatelessWidget {
  const _TopSelectors({
    required this.controller,
    required this.onCashInHand,
    required this.onSync,
    required this.onReconnect,
    required this.offlineMode,
    required this.lastSyncAt,
    this.padding = const EdgeInsets.fromLTRB(24, 16, 24, 0),
  });

  final PosController controller;
  final VoidCallback onCashInHand;
  final VoidCallback onSync;
  final VoidCallback onReconnect;
  final bool offlineMode;
  final DateTime? lastSyncAt;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();

    Future<void> performLogout() async {
      await auth.logout();
    }

    return Padding(
      padding: padding,
      child: Align(
        alignment: Alignment.centerLeft,
        child: _HeaderIconToolbar(
          onRefresh: () => controller.refreshProducts(skipSyncOffline: true),
          onLogout: () {
            performLogout();
          },
          userLabel: context.read<AuthController>().userLabel,
          onCashInHand: onCashInHand,
          offlineMode: offlineMode,
          onSync: onSync,
          lastSyncAt: lastSyncAt,
          onReconnect: onReconnect,
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T value) display;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: _outlineInputBorder(context),
        enabledBorder: _outlineInputBorder(context),
        focusedBorder: _outlineInputBorder(context, width: 1.8),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(value: item, child: Text(display(item))),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    required this.tone,
    required this.modeLabel,
    required this.onDismiss,
  });

  final String message;
  final _BannerTone tone;
  final String modeLabel;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final palette = switch (tone) {
      _BannerTone.error => (
          bg: const Color(0xFF341010),
          border: const Color(0xFF7F1D1D),
          text: const Color(0xFFFCA5A5),
          icon: const Color(0xFFEF4444),
          iconData: Icons.error_outline,
        ),
      _BannerTone.success => (
          bg: const Color(0xFF0E2A17),
          border: const Color(0xFF166534),
          text: const Color(0xFF86EFAC),
          icon: const Color(0xFF22C55E),
          iconData: Icons.check_circle_outline,
        ),
      _BannerTone.warning => (
          bg: const Color(0xFF35210A),
          border: const Color(0xFF9A6700),
          text: const Color(0xFFFCD34D),
          icon: const Color(0xFFF59E0B),
          iconData: Icons.info_outline,
        ),
    };
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: palette.bg,
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Icon(palette.iconData, color: palette.icon),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              modeLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: Icon(Icons.close, color: palette.text),
          ),
        ],
      ),
    );
  }
}

enum _BannerTone { error, success, warning }

class _MainStatusBanner extends StatelessWidget {
  const _MainStatusBanner({
    required this.errorMessage,
    required this.successMessage,
    required this.offlineMode,
    required this.onDismiss,
  });

  final String? errorMessage;
  final String? successMessage;
  final bool offlineMode;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final modeLabel = offlineMode ? tr('Mode hors ligne') : tr('Mode en ligne');
    final String message;
    final _BannerTone tone;

    if (errorMessage != null && errorMessage!.trim().isNotEmpty) {
      message = errorMessage!;
      tone =
          _resolveTone(errorMessage!, isError: true, offlineMode: offlineMode);
    } else if (successMessage != null && successMessage!.trim().isNotEmpty) {
      message = successMessage!;
      tone = _resolveTone(successMessage!,
          isError: false, offlineMode: offlineMode);
    } else {
      message = offlineMode
          ? tr(
              'Les donnees locales sont utilisees. La synchronisation reprendra quand la connexion reviendra.')
          : tr(
              'Connexion active. Le POS utilise la synchronisation automatique.');
      tone = offlineMode ? _BannerTone.warning : _BannerTone.success;
    }

    return _StatusBanner(
      message: message,
      tone: tone,
      modeLabel: modeLabel,
      onDismiss: onDismiss,
    );
  }

  _BannerTone _resolveTone(
    String message, {
    required bool isError,
    required bool offlineMode,
  }) {
    final lower = message.toLowerCase();
    final isWarning = lower.contains('hors ligne') ||
        lower.contains('local') ||
        lower.contains('synchronis') ||
        lower.contains('en attente') ||
        lower.contains('connexion') ||
        offlineMode;
    if (isWarning) return _BannerTone.warning;
    return isError ? _BannerTone.error : _BannerTone.success;
  }
}

class _CatalogPanel extends StatelessWidget {
  const _CatalogPanel({
    required this.controller,
    required this.searchController,
    required this.onOpenMenu,
    required this.onOpenHistory,
    required this.onOpenCalculator,
    required this.onOpenKiosk,
    required this.onOpenWebView,
    required this.onRefresh,
    required this.onCashInHand,
    required this.onSync,
    required this.onReconnect,
    required this.offlineMode,
    required this.lastSyncAt,
    required this.onLogout,
    required this.onSelectProduct,
  });

  final PosController controller;
  final TextEditingController searchController;
  final VoidCallback onOpenMenu;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenCalculator;
  final VoidCallback onOpenKiosk;
  final VoidCallback onOpenWebView;
  final VoidCallback onRefresh;
  final VoidCallback onCashInHand;
  final VoidCallback onSync;
  final VoidCallback onReconnect;
  final bool offlineMode;
  final DateTime? lastSyncAt;
  final VoidCallback onLogout;
  final void Function(Product product) onSelectProduct;

  @override
  Widget build(BuildContext context) {
    final appearance = context.watch<AppearanceController>();
    final storeName = controller.selectedWarehouse?.name ??
        controller.companyName ??
        tr('Store');
    final showClient = appearance.showClientField;
    final showWarehouse = appearance.showWarehouseField;
    final showSearch = appearance.showSearchInput;
    final customers = controller.customers;
    Customer? selectedCustomer;
    if (controller.selectedCustomer != null) {
      final matched = customers
          .where((c) => c.id == controller.selectedCustomer!.id)
          .toList();
      if (matched.isNotEmpty) {
        selectedCustomer = matched.first;
      }
    }
    selectedCustomer ??= customers.isNotEmpty ? customers.first : null;
    final warehouses = controller.warehouses;
    Warehouse? selectedWarehouse;
    if (controller.selectedWarehouse != null) {
      final matched = warehouses
          .where((w) => w.id == controller.selectedWarehouse!.id)
          .toList();
      if (matched.isNotEmpty) {
        selectedWarehouse = matched.first;
      }
    }
    selectedWarehouse ??= warehouses.isNotEmpty ? warehouses.first : null;
    final categories = <ProductCategory>[
      ProductCategory(id: 0, name: tr('All')),
      ...controller.categories,
    ];
    final selectedCategoryId = controller.selectedCategoryId ?? 0;
    final userLabel = (context.read<AuthController>().userLabel ?? '').trim();
    final defaultUserLabel = tr('User');
    final displayName = userLabel.isEmpty ? defaultUserLabel : userLabel;
    final initials = userLabel.trim().isEmpty
        ? (defaultUserLabel.isNotEmpty
            ? defaultUserLabel[0].toUpperCase()
            : 'U')
        : userLabel
            .trim()
            .split(' ')
            .where((part) => part.isNotEmpty)
            .take(2)
            .map((part) => part[0].toUpperCase())
            .join();

    Widget buildSearch() {
      return TextField(
        controller: searchController,
        onChanged: controller.searchProducts,
        decoration: InputDecoration(
          hintText: tr('Search'),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    controller.searchProducts('');
                  },
                ),
          filled: true,
          fillColor: _posYellowSoft,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _posYellowBorder),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      );
    }

    Widget buildCustomerSelector() {
      if (!showClient) return const SizedBox.shrink();
      final showLoyalty =
          controller.loyaltyEnabled && (selectedCustomer?.id ?? 0) > 0;
      final loyaltyText = showLoyalty
          ? '${tr('Loyalty balance')}: ${controller.selectedCustomerPoints} ${tr('pts')} '
              '(${_formatCurrency(controller.loyaltyAvailableAmount, controller.currencySymbol, controller.isCurrencySymbolRight)})'
          : '';
      Future<void> handleAddCustomer() async {
        final result = await showDialog<_NewCustomerPayload>(
          context: context,
          builder: (_) => const _NewCustomerDialog(),
        );
        if (result == null) return;
        final created = await controller.createCustomer(
          name: result.name,
          email: result.email,
          phone: result.phone,
          address: result.address,
          note: result.note,
        );
        if (!context.mounted) return;
        if (created == null) {
          final message = controller.errorMessage ??
              tr('Erreur lors de la création du client.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('Client ajouté.'))),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: controller.offlineMode ? null : handleAddCustomer,
                tooltip: tr('Nouveau client'),
                icon: const Icon(Icons.person_add_alt_1),
                style: IconButton.styleFrom(
                  backgroundColor: _posYellowSoft,
                  foregroundColor: const Color(0xFF111827),
                  padding: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<Customer>(
                  value: selectedCustomer,
                  decoration: InputDecoration(
                    labelText: tr('Client'),
                    filled: true,
                    fillColor: _posYellowSoft,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _posYellowBorder),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  items: customers
                      .map(
                        (customer) => DropdownMenuItem(
                          value: customer,
                          child: Text(customer.name),
                        ),
                      )
                      .toList(),
                  onChanged:
                      customers.isEmpty ? null : controller.selectCustomer,
                ),
              ),
            ],
          ),
          if (showLoyalty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                loyaltyText,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
        ],
      );
    }

    Widget buildWarehouseSelector() {
      if (!showWarehouse) return const SizedBox.shrink();
      void handleWarehouseChange(Warehouse? warehouse) {
        unawaited(() async {
          await controller.selectWarehouse(warehouse);
          final printer = context.read<PrinterSettingsController>();
          printer.syncServices(_resolvePrintingServices(controller));
        }());
      }

      return DropdownButtonFormField<Warehouse>(
        value: selectedWarehouse,
        decoration: InputDecoration(
          labelText: tr('Magasin'),
          filled: true,
          fillColor: _posYellowSoft,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _posYellowBorder),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        items: warehouses
            .map(
              (warehouse) => DropdownMenuItem(
                value: warehouse,
                child: Text(warehouse.name),
              ),
            )
            .toList(),
        onChanged: warehouses.isEmpty ? null : handleWarehouseChange,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 980;
        final showClientOrWarehouse = showClient || showWarehouse;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroBanner(
              title: storeName,
              userLabel: displayName,
              userInitials: initials,
              onMenu: onOpenMenu,
              onLogout: onLogout,
              onOpenHistory: onOpenHistory,
              onOpenCalculator: onOpenCalculator,
              onOpenKiosk: onOpenKiosk,
              onOpenWebView: onOpenWebView,
              offlineMode: offlineMode,
              statusMessage: controller.errorMessage ??
                  controller.successMessage ??
                  (offlineMode
                      ? tr(
                          'Mode hors ligne actif. Les données locales sont utilisées.')
                      : tr(
                          'Mode en ligne actif. Synchronisation opérationnelle.')),
            ),
            const SizedBox(height: 12),
            if (showClientOrWarehouse)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showClient) Expanded(child: buildCustomerSelector()),
                  if (showClient && showWarehouse) const SizedBox(width: 10),
                  if (showWarehouse) Expanded(child: buildWarehouseSelector()),
                ],
              ),
            if (showClientOrWarehouse) const SizedBox(height: 12),
            if (isTight) ...[
              if (showSearch) buildSearch(),
            ] else if (showSearch)
              buildSearch(),
            if (appearance.showCategoryFilter) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final selected = category.id == selectedCategoryId;
                    return _CategoryTile(
                      label: category.name,
                      imageUrl: category.imageUrl,
                      selected: selected,
                      onTap: () => controller.selectCategory(category.id),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (appearance.showProductList) ...[
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ProductGrid(
                        products: controller.products,
                        categories: controller.categories,
                        isLoading: controller.isLoading,
                        onRefresh: () =>
                            controller.refreshProducts(skipSyncOffline: true),
                        onAdd: onSelectProduct,
                        currencySymbol: controller.currencySymbol,
                        currencySymbolRight: controller.isCurrencySymbolRight,
                        customColumns: appearance.productGridColumns,
                      ),
                    ),
                    if (appearance.showHistoryPanel) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 240,
                        child: _HistorySection(
                          embedded: true,
                          listHeight: 220,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Text(
                    tr('Section produits masquée dans les paramètres.'),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.title,
    required this.userLabel,
    required this.userInitials,
    required this.onMenu,
    required this.onLogout,
    required this.onOpenHistory,
    required this.onOpenCalculator,
    required this.onOpenKiosk,
    required this.onOpenWebView,
    required this.offlineMode,
    required this.statusMessage,
  });

  final String title;
  final String userLabel;
  final String userInitials;
  final VoidCallback onMenu;
  final VoidCallback onLogout;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenCalculator;
  final VoidCallback onOpenKiosk;
  final VoidCallback onOpenWebView;
  final bool offlineMode;
  final String statusMessage;

  @override
  Widget build(BuildContext context) {
    final appearance = context.watch<AppearanceController>();
    final defaultTitle = tr('Store');
    final initials = title.trim().isEmpty
        ? (defaultTitle.isNotEmpty ? defaultTitle[0].toUpperCase() : 'S')
        : title.trim()[0].toUpperCase();
    return Container(
      height: 124,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        border: Border.all(color: _posYellowBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Tooltip(
            message: offlineMode ? tr('Mode hors ligne') : tr('Mode en ligne'),
            child: InkWell(
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(offlineMode
                        ? tr('Mode hors ligne')
                        : tr('Mode en ligne')),
                    content: Text(statusMessage),
                    actions: [
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(tr('Fermer')),
                      ),
                    ],
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: offlineMode
                      ? const Color(0xFFFFEDD5)
                      : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: offlineMode
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF22C55E),
                  ),
                ),
                child: Icon(
                  offlineMode ? Icons.cloud_off : Icons.cloud_done,
                  size: 20,
                  color: offlineMode
                      ? const Color(0xFFB45309)
                      : const Color(0xFF166534),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onMenu,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _posYellow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.menu, color: Colors.black),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 28,
            backgroundColor: _posYellow,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: _posYellowSoft,
                      child: Text(
                        userInitials,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        userLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const _BannerDateTime(),
              ],
            ),
          ),
          Row(
            children: [
              _BannerIconButton(
                icon: Icons.receipt_long,
                onTap: onOpenHistory,
                label: tr('Commandes'),
                tooltip: tr('Historique'),
              ),
              const SizedBox(width: 8),
              if (appearance.kioskEnabled) ...[
                _BannerIconButton(
                  icon: Icons.store_mall_directory_outlined,
                  onTap: onOpenKiosk,
                  label: tr('Borne'),
                  tooltip: tr('Interface borne'),
                ),
                const SizedBox(width: 8),
              ],
              _BannerIconButton(
                icon: Icons.public,
                onTap: onOpenWebView,
                label: tr('Web'),
                tooltip: tr('Portail web'),
              ),
              const SizedBox(width: 8),
              _BannerIconButton(
                icon: Icons.calculate_outlined,
                onTap: onOpenCalculator,
                label: tr('Calculatrice'),
                tooltip: tr('Calculatrice'),
              ),
              const SizedBox(width: 8),
              _BannerIconButton(
                icon: Icons.logout,
                onTap: onLogout,
                label: tr('Sortir'),
                tooltip: tr('Déconnexion'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BannerIconButton extends StatelessWidget {
  const _BannerIconButton({
    required this.icon,
    required this.onTap,
    required this.label,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String label;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 84,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _posYellowBorder),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: _posYellow,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerDateTime extends StatelessWidget {
  const _BannerDateTime();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream<DateTime>.periodic(
        const Duration(seconds: 1),
        (_) => DateTime.now(),
      ),
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        final formatted = DateFormat('EEEE dd/MM/yyyy • HH:mm').format(now);
        return Text(
          formatted,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: const TextStyle(
            color: Color(0xFFF7C045),
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 11),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.imageUrl,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final initials = label.trim().isEmpty ? '?' : label.trim()[0].toUpperCase();
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF7C045) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFFF7C045) : const Color(0xFFE5E7EB),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty)
              AppNetworkImage(
                url: imageUrl,
                width: 48,
                height: 48,
                isCircle: true,
                backgroundColor:
                    selected ? Colors.white24 : const Color(0xFFF3F4F6),
                fallbackIcon: Icons.category_outlined,
                iconSize: 22,
                iconColor: selected ? Colors.white : const Color(0xFF6B7280),
              )
            else
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    selected ? Colors.white24 : const Color(0xFFF3F4F6),
                child: Text(
                  initials,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.black : const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopActionButtons extends StatefulWidget {
  const _TopActionButtons({
    required this.onRefresh,
    required this.onCashInHand,
    required this.onSync,
    required this.onReconnect,
    required this.offlineMode,
    required this.lastSyncAt,
    required this.onLogout,
  });

  final VoidCallback onRefresh;
  final VoidCallback onCashInHand;
  final VoidCallback onSync;
  final VoidCallback onReconnect;
  final bool offlineMode;
  final DateTime? lastSyncAt;
  final VoidCallback onLogout;

  @override
  State<_TopActionButtons> createState() => _TopActionButtonsState();
}

class _TopActionButtonsState extends State<_TopActionButtons> {
  bool _isFullScreen = false;

  bool get _isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  @override
  void initState() {
    super.initState();
    _syncFullScreenState();
  }

  Future<void> _syncFullScreenState() async {
    if (!_isDesktop) return;
    final value = await windowManager.isFullScreen();
    if (mounted) {
      setState(() => _isFullScreen = value);
    }
  }

  Future<void> _toggleFullScreen() async {
    if (!_isDesktop) {
      _showSnack(tr('Le plein écran est disponible uniquement sur desktop.'));
      return;
    }
    final nextValue = !_isFullScreen;
    await windowManager.setFullScreen(nextValue);
    if (mounted) {
      setState(() => _isFullScreen = nextValue);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
    );
  }

  Future<void> _openCalculator() async {
    await showDialog(
      context: context,
      builder: (_) => const _CalculatorDialog(),
    );
  }

  Future<void> _openOrderHistory() async {
    final pos = context.read<PosController>();
    final printer = context.read<PrinterSettingsController>();
    final auth = context.read<AuthController>();
    await showDialog(
      context: context,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider<PosController>.value(value: pos),
          ChangeNotifierProvider<PrinterSettingsController>.value(
            value: printer,
          ),
          ChangeNotifierProvider<AuthController>.value(value: auth),
        ],
        child: const _OrderHistoryDialog(),
      ),
    );
  }

  Future<void> _openAppearanceSettings() async {
    await showDialog(
      context: context,
      builder: (_) => const _AppearanceSettingsDialog(),
    );
  }

  Future<void> _openPosConfiguration() async {
    final pos = context.read<PosController>();
    await showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider<PosController>.value(
        value: pos,
        child: _PosConfigurationDialog(
          onTestReset: () => pos.resetHistoryStats(),
        ),
      ),
    );
  }

  Future<void> _openKioskPage() async {
    final appearance = context.read<AppearanceController>();
    if (!appearance.kioskEnabled) {
      _showSnack(tr('La borne est désactivée dans la configuration POS.'));
      return;
    }
    final pos = context.read<PosController>();
    final printer = context.read<PrinterSettingsController>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider<PosController>.value(value: pos),
            ChangeNotifierProvider<PrinterSettingsController>.value(
              value: printer,
            ),
          ],
          child: const KioskPage(),
        ),
      ),
    );
  }

  Future<void> _openWebViewPage() async {
    final appearance = context.read<AppearanceController>();
    final raw = appearance.webViewUrl.trim();
    final url = raw.isEmpty ? AppConfig.defaultWebViewUrl : raw;
    if (Uri.tryParse(url) == null) {
      _showSnack(tr('URL WebView invalide.'));
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PosWebViewPage(
          url: url,
          title: tr('Portail web'),
        ),
      ),
    );
  }

  Future<void> _openPrinterSettings() async {
    final printerController = context.read<PrinterSettingsController>();
    final posController = context.read<PosController>();
    printerController.syncServices(_resolvePrintingServices(posController));
    await showDialog(
      context: context,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider<PrinterSettingsController>.value(
            value: printerController,
          ),
          ChangeNotifierProvider<PosController>.value(value: posController),
        ],
        child: const _PrinterSettingsDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionMenuItem(
        icon: Icons.tune,
        label: tr('Apparence'),
        onTap: _openAppearanceSettings,
      ),
      _ActionMenuItem(
        icon: Icons.print_outlined,
        label: tr('Imprimante'),
        onTap: _openPrinterSettings,
      ),
      _ActionMenuItem(
        icon: Icons.settings_applications_outlined,
        label: tr('Config POS'),
        onTap: _openPosConfiguration,
      ),
      _ActionMenuItem(
        icon: Icons.public,
        label: tr('Portail web'),
        onTap: _openWebViewPage,
      ),
      if (context.read<AppearanceController>().kioskEnabled)
        _ActionMenuItem(
          icon: Icons.store_mall_directory_outlined,
          label: tr('Interface borne'),
          onTap: _openKioskPage,
        ),
    ];

    return Align(
      alignment: Alignment.centerRight,
      child: _ActionIcon(
        icon: Icons.menu,
        tooltip: tr('Menu actions'),
        onTap: () => _showActionMenu(context, actions),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.color,
    this.background,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final tile = Material(
      color: background ?? _posYellowSoft,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _posYellowBorder),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color ?? const Color(0xFF6B7280),
          ),
        ),
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: tile);
    }
    return tile;
  }
}

class _ActionMenuItem {
  const _ActionMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.background,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final Color? background;
}

Future<void> _showActionMenu(
  BuildContext context,
  List<_ActionMenuItem> items,
) async {
  if (items.isEmpty) return;
  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      const accent = _posYellow;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              const crossAxisCount = 4;
              final compactHeight = height < 700;
              final iconSize = compactHeight ? 36.0 : 42.0;
              final iconGlyphSize = compactHeight ? 24.0 : 28.0;
              final spacing = compactHeight ? 6.0 : 8.0;
              final childAspectRatio = compactHeight ? 1.02 : 0.96;

              return Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                decoration: BoxDecoration(
                  color: _posYellowSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _posYellowBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tr('Actions'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: height * 0.72,
                      ),
                      child: SingleChildScrollView(
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: spacing,
                            crossAxisSpacing: spacing,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final enabled = item.onTap != null;
                            final labelStyle =
                                theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: enabled
                                  ? const Color(0xFF111827)
                                  : const Color(0xFF9CA3AF),
                            );
                            return InkWell(
                              onTap: enabled
                                  ? () {
                                      Navigator.of(context).pop();
                                      item.onTap?.call();
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: item.background ??
                                      const Color(0xFFFFFBF1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _posYellowBorder,
                                  ),
                                ),
                                padding: EdgeInsets.all(compactHeight ? 4 : 5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: iconSize,
                                      height: iconSize,
                                      decoration: BoxDecoration(
                                        color: item.background ?? accent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        item.icon,
                                        size: iconGlyphSize,
                                        color: item.color ?? Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.label,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: labelStyle?.copyWith(
                                        fontSize: compactHeight ? 10 : 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

class _CartPanel extends StatelessWidget {
  const _CartPanel({
    required this.controller,
    required this.discountController,
    required this.shippingController,
    required this.taxController,
    required this.loyaltyController,
    required this.notesController,
  });

  final PosController controller;
  final TextEditingController discountController;
  final TextEditingController shippingController;
  final TextEditingController taxController;
  final TextEditingController loyaltyController;
  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    final symbolRight = controller.isCurrencySymbolRight;
    final cartItems = controller.cartItems;

    Future<void> confirmReset() async {
      final shouldClear = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(tr('Vider le panier')),
          content: Text(tr('Supprimer tous les articles du panier ?')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(tr('Annuler')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(tr('Vider')),
            ),
          ],
        ),
      );
      if (shouldClear == true) {
        controller.resetCart();
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEFEFEF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                tr('My cart'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: tr('Vider le panier'),
                onPressed: cartItems.isEmpty ? null : confirmReset,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Text(
                      tr('Votre panier est vide'),
                      style: TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                  )
                : ListView.separated(
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _CartItemTile(
                        item: item,
                        controller: controller,
                        currencySymbol: controller.currencySymbol,
                        currencySymbolRight: symbolRight,
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          _CartSummaryCard(
            controller: controller,
            discountController: discountController,
            shippingController: shippingController,
            taxController: taxController,
            loyaltyController: loyaltyController,
            notesController: notesController,
          ),
          const SizedBox(height: 12),
          _CartActions(
            controller: controller,
            notesController: notesController,
          ),
        ],
      ),
    );
  }
}

class _CartTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(flex: 6, child: Text(tr('PRODUCT'), style: style)),
          Expanded(
            flex: 3,
            child: Text(tr('QTY'), style: style, textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 3,
            child:
                Text(tr('SUB TOTAL'), style: style, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({
    required this.item,
    required this.controller,
    required this.currencySymbol,
    required this.currencySymbolRight,
  });

  final CartItem item;
  final PosController controller;
  final String currencySymbol;
  final bool currencySymbolRight;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600);
    final iconColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.8);
    final optionStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6));

    String formatOptions() {
      return item.options.map((option) {
        final qty = option.quantity;
        final qtyLabel = qty == qty.roundToDouble()
            ? qty.toStringAsFixed(0)
            : qty.toString();
        return qty <= 1 ? option.name : '${option.name} x$qtyLabel';
      }).join(', ');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Row(
              children: [
                IconButton(
                  tooltip: tr('Supprimer'),
                  onPressed: () => controller.removeFromCart(item.id),
                  icon: Icon(Icons.delete_outline, size: 18, color: iconColor),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: textStyle,
                        softWrap: true,
                      ),
                      if (item.options.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            formatOptions(),
                            style: optionStyle,
                            softWrap: true,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(child: Text('${item.quantity}', style: textStyle)),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                _formatCurrency(
                  item.subTotal,
                  currencySymbol,
                  currencySymbolRight,
                ),
                style: textStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.controller,
    required this.currencySymbol,
    required this.currencySymbolRight,
  });

  final CartItem item;
  final PosController controller;
  final String currencySymbol;
  final bool currencySymbolRight;

  @override
  Widget build(BuildContext context) {
    final optionStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF9CA3AF),
          fontSize: 11,
        );

    String formatOptions() {
      return item.options.map((option) {
        final qty = option.quantity;
        final qtyLabel = qty == qty.roundToDouble()
            ? qty.toStringAsFixed(0)
            : qty.toString();
        return qty <= 1 ? option.name : '${option.name} x$qtyLabel';
      }).join(', ');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          AppNetworkImage(
            url: item.product.imageUrl,
            width: 36,
            height: 36,
            isCircle: true,
            backgroundColor: const Color(0xFFF3F4F6),
            fallbackIcon: Icons.restaurant_menu,
            iconSize: 16,
            iconColor: Colors.black54,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.quantity} x ${item.product.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF111827),
                  ),
                ),
                if (item.options.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      formatOptions(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: optionStyle,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatCurrency(
              item.subTotal,
              currencySymbol,
              currencySymbolRight,
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 6),
          _QuantityAdjuster(
            quantity: item.quantity,
            onDecrease: () =>
                controller.updateQuantity(item.id, item.quantity - 1),
            onIncrease: () =>
                controller.updateQuantity(item.id, item.quantity + 1),
          ),
          IconButton(
            tooltip: tr('Supprimer'),
            onPressed: () => controller.removeFromCart(item.id),
            icon: const Icon(Icons.delete_outline, size: 18),
          ),
        ],
      ),
    );
  }
}

class _QuantityAdjuster extends StatelessWidget {
  const _QuantityAdjuster({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onDecrease,
            icon: const Icon(Icons.remove, size: 16),
          ),
          Text(
            '$quantity',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onIncrease,
            icon: const Icon(Icons.add, size: 16),
          ),
        ],
      ),
    );
  }
}

class _CartSummaryCard extends StatefulWidget {
  const _CartSummaryCard({
    required this.controller,
    required this.discountController,
    required this.shippingController,
    required this.taxController,
    required this.loyaltyController,
    required this.notesController,
  });

  final PosController controller;
  final TextEditingController discountController;
  final TextEditingController shippingController;
  final TextEditingController taxController;
  final TextEditingController loyaltyController;
  final TextEditingController notesController;

  @override
  State<_CartSummaryCard> createState() => _CartSummaryCardState();
}

class _CartSummaryCardState extends State<_CartSummaryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final symbol = controller.currencySymbol;
    final symbolRight = controller.isCurrencySymbolRight;
    final isPercent = controller.discountMode == DiscountMode.percentage;
    final discountLabel = tr('Discount');
    final allowLoyaltyRedeem = controller.allowLoyaltyRedeem;

    double parseInput(String value) {
      final sanitized = value.replaceAll(',', '.');
      return double.tryParse(sanitized) ?? 0;
    }

    Widget summaryRow(
      String label,
      String value, {
      Color labelColor = const Color(0xFF6B7280),
      Color valueColor = const Color(0xFF111827),
      FontWeight valueWeight = FontWeight.w600,
      double valueSize = 12,
    }) {
      return Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: labelColor),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: valueWeight,
              color: valueColor,
            ),
          ),
        ],
      );
    }

    Widget editableRow({
      required String label,
      required TextEditingController controller,
      required ValueChanged<String> onChanged,
      String? suffixText,
    }) {
      return Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const Spacer(),
          SizedBox(
            width: 90,
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              onChanged: onChanged,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFF7C045)),
                ),
                suffixText: suffixText,
              ),
            ),
          ),
        ],
      );
    }

    final shippingMethods = controller.shippingMethods;
    final hasShippingMethods = shippingMethods.isNotEmpty;
    ShippingMethod? selectedMethod = controller.selectedShippingMethod;
    if (selectedMethod != null &&
        shippingMethods.indexWhere((m) => m.id == selectedMethod!.id) == -1) {
      selectedMethod = null;
    }

    String formatAmount(double value) =>
        _formatCurrency(value, symbol, symbolRight);

    String shippingMethodCaption(ShippingMethod method) {
      if (method.isFree) return tr('Free');
      if (method.isManual) return tr('Manual');
      if (method.isOrderPercent) {
        return '${method.value.toStringAsFixed(0)} %';
      }
      if (method.isPerItem) {
        return '${formatAmount(method.value)} / ${tr('item')}';
      }
      return '';
    }

    Widget buildDiscountPresets() {
      final presets = controller.discountPresets;
      if (presets.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: presets.map((value) {
            final selected = (controller.discountInput - value).abs() < 0.001;
            final label = value == 0
                ? (isPercent ? tr('Aucun pourcentage') : tr('Aucune remise'))
                : (isPercent
                    ? '${value.toStringAsFixed(0)} %'
                    : formatAmount(value));
            return ChoiceChip(
              label: Text(label, style: const TextStyle(fontSize: 11)),
              selected: selected,
              onSelected: (_) => controller.updateDiscount(value),
              selectedColor: const Color(0xFFF7C045),
            );
          }).toList(),
        ),
      );
    }

    Widget buildShippingSelector() {
      if (!hasShippingMethods) return const SizedBox.shrink();
      return DropdownButtonFormField<ShippingMethod>(
        value: selectedMethod,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: tr('Shipping method'),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF7C045)),
          ),
        ),
        items: shippingMethods.map((method) {
          final caption = shippingMethodCaption(method);
          return DropdownMenuItem(
            value: method,
            child: Text(
              caption.isNotEmpty ? '${method.name} • $caption' : method.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF111827),
              ),
            ),
          );
        }).toList(),
        onChanged: controller.selectShippingMethod,
      );
    }

    final showManualShipping =
        !hasShippingMethods || (selectedMethod?.isManual ?? false);

    final expandedContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        summaryRow(
          tr('Subtotal'),
          formatAmount(controller.subTotal),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              discountLabel,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const Spacer(),
            ToggleButtons(
              isSelected: [!isPercent, isPercent],
              onPressed: (index) {
                final nextMode =
                    index == 1 ? DiscountMode.percentage : DiscountMode.fixed;
                controller.updateDiscountMode(nextMode);
              },
              borderRadius: BorderRadius.circular(10),
              constraints: const BoxConstraints(minHeight: 30, minWidth: 36),
              selectedColor: Colors.white,
              color: const Color(0xFF6B7280),
              fillColor: const Color(0xFFF7C045),
              children: [
                Text(tr('Amt'), style: TextStyle(fontSize: 11)),
                Text(tr('%'), style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 90,
              child: TextField(
                controller: widget.discountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.right,
                onChanged: (value) =>
                    controller.updateDiscount(parseInput(value)),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFF7C045)),
                  ),
                  suffixText: isPercent ? '%' : symbol,
                ),
              ),
            ),
          ],
        ),
        buildDiscountPresets(),
        if (controller.loyaltyEnabled &&
            (controller.selectedCustomer?.id ?? 0) > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              children: [
                summaryRow(
                  tr('Loyalty balance'),
                  '${controller.selectedCustomerPoints} ${tr('pts')} '
                  '(${formatAmount(controller.loyaltyAvailableAmount)})',
                ),
                if (allowLoyaltyRedeem) ...[
                  const SizedBox(height: 6),
                  editableRow(
                    label: tr('Use loyalty'),
                    controller: widget.loyaltyController,
                    onChanged: (value) => controller.updateLoyaltyRedeemAmount(
                      parseInput(value),
                    ),
                    suffixText: symbol,
                  ),
                ],
                if (controller.loyaltyEstimatedPoints > 0) ...[
                  const SizedBox(height: 6),
                  summaryRow(
                    tr('Points earned'),
                    '${controller.loyaltyEstimatedPoints} ${tr('pts')}',
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 6),
        editableRow(
          label: tr('Tax (%)'),
          controller: widget.taxController,
          onChanged: (value) => controller.updateTaxRate(parseInput(value)),
          suffixText: tr('%'),
        ),
        const SizedBox(height: 6),
        if (hasShippingMethods) buildShippingSelector(),
        if (hasShippingMethods) const SizedBox(height: 6),
        if (showManualShipping)
          editableRow(
            label: tr('Shipping'),
            controller: widget.shippingController,
            onChanged: (value) => controller.updateShipping(parseInput(value)),
            suffixText: symbol,
          )
        else
          summaryRow(
            tr('Shipping'),
            formatAmount(controller.shipping),
          ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.notesController,
          minLines: 2,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: tr('Notes'),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF7C045)),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF6D58F)),
        color: const Color(0xFFFFFBF1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                tr('Cart summary'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const Spacer(),
              Text(
                formatAmount(controller.grandTotal),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFF59E0B),
                ),
              ),
              IconButton(
                tooltip: _expanded ? tr('Réduire') : tr('Développer'),
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ),
            ],
          ),
          if (_expanded) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: SingleChildScrollView(
                child: expandedContent,
              ),
            ),
          ],
          summaryRow(
            tr('Final'),
            formatAmount(controller.grandTotal),
            labelColor: const Color(0xFF111827),
            valueColor: const Color(0xFFF59E0B),
            valueWeight: FontWeight.w800,
            valueSize: 16,
          ),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.controller,
    required this.discountController,
    required this.shippingController,
    required this.taxController,
    required this.loyaltyController,
    required this.notesController,
  });

  final PosController controller;
  final TextEditingController discountController;
  final TextEditingController shippingController;
  final TextEditingController taxController;
  final TextEditingController loyaltyController;
  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final symbolRight = controller.isCurrencySymbolRight;
    String format(double value) =>
        _formatCurrency(value, controller.currencySymbol, symbolRight);
    final allowLoyaltyRedeem = controller.allowLoyaltyRedeem;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surface,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 480;
          final spacing = isNarrow ? 10.0 : 14.0;
          final inputStyle = theme.textTheme.bodySmall;

          Widget labeledField(Widget field) => Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: field,
              );

          final totals = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('Sous-total'), style: theme.textTheme.bodySmall),
                  Text(
                    format(controller.subTotal),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('TVA'), style: theme.textTheme.bodySmall),
                  Text(
                    format(controller.taxTotal),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('Livraison'), style: theme.textTheme.bodySmall),
                  Text(
                    format(controller.shipping),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('Total'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    format(controller.grandTotal),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          );

          final discountLabel =
              controller.discountMode == DiscountMode.percentage
                  ? tr('Remise (%)')
                  : '${tr('Remise')} (${controller.currencySymbol})';

          Widget buildTextField({
            required String label,
            required TextEditingController controller,
            required ValueChanged<String> onChanged,
            TextInputType keyboardType = const TextInputType.numberWithOptions(
              decimal: true,
            ),
          }) {
            return labeledField(
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                decoration: _inputDecoration(context, label),
                onChanged: onChanged,
              ),
            );
          }

          double parseInput(String value) {
            final sanitized = value.replaceAll(',', '.');
            return double.tryParse(sanitized) ?? 0;
          }

          final presets = controller.discountPresets;
          final defaultPreset =
              presets.firstWhere((v) => v > 0, orElse: () => 0);
          final shippingMethods = controller.shippingMethods;
          final hasShippingMethods = shippingMethods.isNotEmpty;
          ShippingMethod? selectedMethod = controller.selectedShippingMethod;
          if (selectedMethod != null &&
              shippingMethods.indexWhere((m) => m.id == selectedMethod!.id) ==
                  -1) {
            selectedMethod = null;
          }
          final showManualShipping =
              !hasShippingMethods || (selectedMethod?.isManual ?? false);

          String shippingMethodCaption(ShippingMethod method) {
            if (method.isFree) return tr('Free');
            if (method.isManual) return tr('Manual');
            if (method.isOrderPercent) {
              return '${method.value.toStringAsFixed(0)} %';
            }
            if (method.isPerItem) {
              return '${format(method.value)} / ${tr('item')}';
            }
            return '';
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildTextField(
                  label: discountLabel,
                  controller: discountController,
                  onChanged: (value) =>
                      this.controller.updateDiscount(parseInput(value)),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: spacing),
                  child: SegmentedButton<DiscountMode>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: DiscountMode.fixed,
                        label: Text(tr('Montant')),
                      ),
                      ButtonSegment(
                        value: DiscountMode.percentage,
                        label: Text(tr('Pourcentage')),
                      ),
                    ],
                    selected: {this.controller.discountMode},
                    onSelectionChanged: (selection) {
                      if (selection.isNotEmpty) {
                        final nextMode = selection.first;
                        this.controller.updateDiscountMode(nextMode);
                        if (defaultPreset > 0 || presets.isNotEmpty) {
                          this.controller.updateDiscount(defaultPreset);
                        }
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: spacing),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presets.map((value) {
                      final selected =
                          (controller.discountInput - value).abs() < 0.001;
                      final label = value == 0
                          ? controller.discountMode == DiscountMode.percentage
                              ? tr('Aucun pourcentage')
                              : tr('Aucune remise')
                          : controller.discountMode == DiscountMode.percentage
                              ? '${value.toStringAsFixed(0)} %'
                              : format(value);
                      return ChoiceChip(
                        label: Text(label),
                        selected: selected,
                        onSelected: (_) =>
                            this.controller.updateDiscount(value),
                      );
                    }).toList(),
                  ),
                ),
                if (controller.loyaltyEnabled &&
                    (controller.selectedCustomer?.id ?? 0) > 0)
                  labeledField(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tr('Loyalty balance'),
                              style: inputStyle,
                            ),
                            Text(
                              '${controller.selectedCustomerPoints} ${tr('pts')} '
                              '(${format(controller.loyaltyAvailableAmount)})',
                              style: inputStyle,
                            ),
                          ],
                        ),
                        if (allowLoyaltyRedeem) ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: loyaltyController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: _inputDecoration(
                              context,
                              '${tr('Use loyalty')} (${controller.currencySymbol})',
                            ),
                            onChanged: (value) =>
                                this.controller.updateLoyaltyRedeemAmount(
                                      parseInput(value),
                                    ),
                          ),
                        ],
                        if (controller.loyaltyEstimatedPoints > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(tr('Points earned'), style: inputStyle),
                              Text(
                                '${controller.loyaltyEstimatedPoints} ${tr('pts')}',
                                style: inputStyle,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                buildTextField(
                  label: tr('TVA (%)'),
                  controller: taxController,
                  onChanged: (value) =>
                      this.controller.updateTaxRate(parseInput(value)),
                ),
                if (hasShippingMethods)
                  labeledField(
                    DropdownButtonFormField<ShippingMethod>(
                      value: selectedMethod,
                      isExpanded: true,
                      decoration: _inputDecoration(
                        context,
                        tr('Shipping method'),
                      ),
                      items: shippingMethods.map((method) {
                        final caption = shippingMethodCaption(method);
                        return DropdownMenuItem(
                          value: method,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(method.name),
                              if (caption.isNotEmpty)
                                Text(
                                  caption,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: controller.selectShippingMethod,
                    ),
                  ),
                if (showManualShipping)
                  buildTextField(
                    label: '${tr('Livraison')} (${controller.currencySymbol})',
                    controller: shippingController,
                    onChanged: (value) =>
                        this.controller.updateShipping(parseInput(value)),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  )
                else
                  labeledField(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tr('Livraison'), style: inputStyle),
                        Text(format(controller.shipping), style: inputStyle),
                      ],
                    ),
                  ),
                labeledField(
                  TextField(
                    controller: notesController,
                    decoration: _inputDecoration(context, tr('Notes')),
                    minLines: 2,
                    maxLines: 4,
                  ),
                ),
                const Divider(),
                totals,
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      border: _outlineInputBorder(context),
      enabledBorder: _outlineInputBorder(context),
      focusedBorder: _outlineInputBorder(context, width: 1.8),
    );
  }
}

class _CartActions extends StatelessWidget {
  const _CartActions({required this.controller, required this.notesController});

  final PosController controller;
  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    void showError(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
      );
    }

    final theme = Theme.of(context);
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
    );
    final appearance = context.watch<AppearanceController>();

    ButtonStyle outlineStyle(Color color) {
      return OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.2),
        shape: shape,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        backgroundColor: Colors.white,
        visualDensity: VisualDensity.compact,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      );
    }

    ButtonStyle filledStyle(Color color) {
      return ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: shape,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        visualDensity: VisualDensity.compact,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      );
    }

    final resetColor = Colors.red.shade600;
    final payColor = const Color(0xFF16A34A);
    final holdColor = const Color(0xFFF59E0B);

    final payButton = ElevatedButton.icon(
      style: filledStyle(payColor),
      onPressed: controller.isProcessingSale
          ? null
          : () async {
              if (controller.cartItems.isEmpty) {
                showError(tr('Ajoutez des articles avant de payer.'));
                return;
              }

              final printerController =
                  context.read<PrinterSettingsController>();
              final methods = controller.paymentMethods;
              if (methods.isEmpty) {
                showError(
                  tr('Aucune méthode de paiement configurée. Ajoutez-en une avant de payer.'),
                );
                return;
              }
              final defaultMethod = methods.firstWhere(
                (method) => method.isDefault,
                orElse: () => methods.first,
              );

              final result = await showDialog<_PaymentDialogResult>(
                context: context,
                builder: (_) => _PaymentDialog(
                  items: controller.cartItems,
                  grandTotal: controller.grandTotal,
                  discountAmount: controller.discountAmount,
                  shipping: controller.shipping,
                  taxRate: controller.taxRate,
                  loyaltyRedeemAmount: controller.loyaltyRedeemAmount,
                  currencySymbol: controller.currencySymbol,
                  currencyOnRight: controller.isCurrencySymbolRight,
                  paymentMethods: methods,
                  defaultPaymentMethodId: defaultMethod.id,
                ),
              );
              if (result == null) return;
              final shouldPrint = result.shouldPrint;
              final cartSnapshot = List<CartItem>.from(result.items);
              final selectedMethod = methods.firstWhere(
                (method) => method.id == result.paymentTypeId,
                orElse: () => defaultMethod,
              );
              final paymentStatusLabel = tr(
                _paymentStatuses
                    .firstWhere(
                      (status) => status.id == result.paymentStatusId,
                      orElse: () => _paymentStatuses.first,
                    )
                    .label,
              );

              final itemsSubTotal = cartSnapshot.fold<double>(
                0,
                (sum, item) => sum + item.subTotal,
              );
              final discount = result.discountAmount;
              final shipping = result.shipping;
              final double subTotal = (itemsSubTotal - discount)
                  .clamp(0, double.infinity)
                  .toDouble();
              final tax = subTotal * (result.taxRate / 100);
              final grandTotal = subTotal + tax + shipping;
              final services = _resolvePrintingServices(controller);
              printerController.syncServices(services);
              final posTargets = services.where((service) {
                final template = service.template.trim().toLowerCase();
                return printerController.shouldPrintTemplate(
                  fromKiosk: false,
                  template: template,
                );
              }).toList();

              await controller.checkout(
                notes: notesController.text.trim(),
                paymentTypeId: result.paymentTypeId,
                paymentStatusId: result.paymentStatusId,
                receivedAmount: result.receivedAmount,
                shouldPrint: shouldPrint,
                cartItemsOverride: cartSnapshot,
                discountAmountOverride: discount,
                shippingOverride: shipping,
                taxRateOverride: result.taxRate,
                grandTotalOverride: grandTotal,
              );
              if (!context.mounted || controller.errorMessage != null) return;

              if (shouldPrint) {
                for (final service in posTargets) {
                  await printerController.printSaleReceipt(
                    items: cartSnapshot,
                    subTotal: subTotal,
                    discount: discount,
                    tax: tax,
                    shipping: shipping,
                    grandTotal: grandTotal,
                    currencySymbol: controller.currencySymbol,
                    currencyOnRight: controller.isCurrencySymbolRight,
                    customerName: controller.selectedCustomer?.name,
                    customerPhone: controller.selectedCustomer?.phone,
                    customerEmail: controller.selectedCustomer?.email,
                    userLabel: context.read<AuthController>().userLabel,
                    companyName: controller.companyName,
                    companyAddress: controller.companyAddress,
                    companyEmail: controller.companyEmail,
                    companyPhone: controller.companyPhone,
                    warehouseName: controller.selectedWarehouse?.name,
                    companyLogoUrl: controller.companyLogo,
                    paymentType: selectedMethod.name,
                    paymentStatus: paymentStatusLabel,
                    receivedAmount: result.receivedAmount,
                    change: result.change,
                    serviceId: service.id,
                    template: service.template,
                  );
                }
              }
            },
      icon: controller.isProcessingSale
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.payments_outlined, size: 18),
      label: Text(tr('PAYER')),
    );

    final resetButton = OutlinedButton.icon(
      style: outlineStyle(resetColor),
      onPressed: controller.resetCart,
      icon: const Icon(Icons.restart_alt, size: 18),
      label: Text(tr('Reset')),
    );

    final holdButton = OutlinedButton.icon(
      style: outlineStyle(holdColor),
      onPressed: controller.isProcessingSale
          ? null
          : () async {
              if (controller.cartItems.isEmpty) {
                showError(
                    tr('Ajoutez des articles avant de mettre en attente.'));
                return;
              }
              await controller.checkout(
                notes: notesController.text.trim(),
                paymentTypeId: 0,
                paymentStatusId: 2,
                receivedAmount: 0,
                shouldPrint: false,
                saleStatus: 'onhold',
              );
            },
      icon: const Icon(Icons.pause_circle_outline, size: 18),
      label: Text(tr('Hold')),
    );

    final buttonsList = <Widget>[
      if (appearance.showCashButton) payButton,
      if (appearance.showResetButton) resetButton,
      if (appearance.showHoldButton) holdButton,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (appearance.showTotalsInCart) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${tr('Total')}: ${_formatCurrency(controller.grandTotal, controller.currencySymbol, controller.isCurrencySymbolRight)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              Text(
                '${tr('QTY')}: ${controller.totalQuantity}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (buttonsList.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 320;
              if (compact) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: buttonsList
                      .map(
                        (button) => SizedBox(
                          width: constraints.maxWidth,
                          child: button,
                        ),
                      )
                      .toList(),
                );
              }
              return Row(
                children: [
                  for (var i = 0; i < buttonsList.length; i++) ...[
                    Expanded(child: buttonsList[i]),
                  ],
                ],
              );
            },
          ),
      ],
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    this.embedded = false,
    this.listHeight = 360,
  });

  final bool embedded;
  final double listHeight;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PosController>();
    final printerController = context.read<PrinterSettingsController>();
    final auth = context.read<AuthController>();
    final theme = Theme.of(context);
    final pendingCount = controller.pendingOfflineSalesCount;
    final failedCount = controller.failedOfflineSalesCount;
    final totalCount = controller.offlineSales.length;
    final lastSync = controller.lastSyncAt;
    final orders = controller.filteredRecentOrders;

    Future<void> payAndPrintOrder(OrderSummary order) async {
      final methods = controller.paymentMethods;
      if (methods.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('Aucune méthode de paiement configurée.'))),
        );
        return;
      }
      final remaining = (order.grandTotal - order.paidAmount)
          .clamp(0, double.infinity)
          .toDouble();
      if (remaining <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('Cette commande est déjà payée.'))),
        );
        return;
      }
      final defaultMethod = methods.firstWhere(
        (method) => method.isDefault,
        orElse: () => methods.first,
      );
      final result = await showDialog<_SimplePaymentDialogResult>(
        context: context,
        builder: (_) => _SimplePaymentDialog(
          amountDue: remaining,
          currencySymbol: controller.currencySymbol,
          currencyOnRight: controller.isCurrencySymbolRight,
          paymentMethods: methods,
          defaultPaymentMethodId: defaultMethod.id,
        ),
      );
      if (result == null) return;
      final ok = await controller.payOrder(
        saleId: order.id,
        paymentTypeId: result.paymentTypeId,
        receivedAmount: result.receivedAmount,
      );
      if (!context.mounted || !ok) return;

      final selectedMethod = methods.firstWhere(
        (method) => method.id == result.paymentTypeId,
        orElse: () => defaultMethod,
      );
      final payload = await controller.repository.fetchSalePayload(order.id);
      final source = payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : payload;
      final itemsRaw =
          source['items'] is List ? source['items'] as List : const [];
      final noteText = (source['note'] ?? order.note ?? '').toString();
      final noteCustomerMatch =
          RegExp(r'CLIENT:\s*(.+)$', caseSensitive: false).firstMatch(noteText);
      final resolvedCustomerName =
          (source['customer_name']?.toString() ?? '').trim().isNotEmpty
              ? source['customer_name']?.toString()
              : noteCustomerMatch?.group(1)?.trim();

      double parseDouble(dynamic value) {
        if (value is num) return value.toDouble();
        return double.tryParse('$value') ?? 0;
      }

      final items = itemsRaw.whereType<Map>().map((raw) {
        final map = raw.cast<String, dynamic>();
        final product = Product(
          id: int.tryParse('${map['product_id'] ?? 0}') ?? 0,
          name: map['name']?.toString() ?? tr('Produit'),
          code: map['sku']?.toString() ?? '',
          price: parseDouble(map['unit_price']),
          cost: 0,
          stockQuantity: -1,
          taxValue: 0,
        );
        final optionsRaw =
            map['options'] is List ? map['options'] as List : const [];
        final options = optionsRaw.whereType<Map>().map((option) {
          return ProductOption.fromJson(option.cast<String, dynamic>());
        }).toList();
        return CartItem(
          product: product,
          quantity: parseDouble(map['quantity']).round(),
          options: options,
        );
      }).toList();

      final services = _resolvePrintingServices(controller);
      printerController.syncServices(services);
      final posTargets = services.where((service) {
        final template = service.template.trim().toLowerCase();
        return printerController.shouldPrintTemplate(
          fromKiosk: false,
          template: template,
        );
      }).toList();
      for (final service in posTargets) {
        await printerController.printSaleReceipt(
          items: items,
          subTotal: parseDouble(source['subtotal']),
          discount: parseDouble(source['discount_total']),
          tax: parseDouble(source['tax_total']),
          shipping: 0,
          grandTotal: parseDouble(source['grand_total']),
          currencySymbol: controller.currencySymbol,
          currencyOnRight: controller.isCurrencySymbolRight,
          customerName: resolvedCustomerName,
          customerPhone: source['customer_phone']?.toString(),
          customerEmail: source['customer_email']?.toString(),
          userLabel: auth.userLabel,
          companyName: controller.companyName,
          companyAddress: controller.companyAddress,
          companyEmail: controller.companyEmail,
          companyPhone: controller.companyPhone,
          warehouseName: controller.selectedWarehouse?.name,
          companyLogoUrl: controller.companyLogo,
          paymentType: selectedMethod.name,
          paymentStatus: tr('Payée'),
          receivedAmount: result.receivedAmount,
          change: (result.receivedAmount - remaining)
              .clamp(0, double.infinity)
              .toDouble(),
          serviceId: service.id,
          template: service.template,
        );
      }
    }

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Etat de synchronisation'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text('${tr('Commandes locales')}: $totalCount'),
              Text('${tr('En attente')}: $pendingCount'),
              Text('${tr('En erreur')}: $failedCount'),
              Text(
                lastSync == null
                    ? tr('Derniere synchronisation: jamais')
                    : '${tr('Derniere synchronisation')}: ${DateFormat('dd/MM/yyyy HH:mm').format(lastSync.toLocal())}',
              ),
              if (controller.isSyncingOfflineSales) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: controller.offlineSales.isEmpty ||
                    controller.isProcessingSale ||
                    controller.isSyncingOfflineSales
                ? null
                : () async {
                    await controller.syncOfflineQueue();
                  },
            icon:
                controller.isProcessingSale || controller.isSyncingOfflineSales
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
            label: Text(
              controller.offlineSales.isEmpty
                  ? tr('Aucune commande locale à envoyer')
                  : '${tr('Envoyer')} ${controller.offlineSales.length} '
                      '${tr('commande(s) locales')}',
            ),
          ),
        ),
        const SizedBox(height: 12),
        _HistoryHeader(
          register: controller.displayRegisterDetails,
          formatAmount: (value) => _formatCurrency(
            value,
            controller.currencySymbol,
            controller.isCurrencySymbolRight,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(tr('Toutes sources')),
              selected: controller.historySourceFilter == null,
              onSelected: (_) => controller.updateHistorySourceFilter(null),
            ),
            ChoiceChip(
              label: Text(tr('POS')),
              selected: controller.historySourceFilter == 'pos',
              onSelected: (_) => controller.updateHistorySourceFilter('pos'),
            ),
            ChoiceChip(
              label: Text(tr('Borne')),
              selected: controller.historySourceFilter == 'kiosk',
              onSelected: (_) => controller.updateHistorySourceFilter('kiosk'),
            ),
            ChoiceChip(
              label: Text(tr('Tous statuts')),
              selected: controller.historyStatusFilter == null,
              onSelected: (_) => controller.updateHistoryStatusFilter(null),
            ),
            for (final status in controller.availableHistoryStatuses)
              ChoiceChip(
                label: Text(status),
                selected: controller.historyStatusFilter?.toLowerCase() ==
                    status.toLowerCase(),
                onSelected: (_) => controller.updateHistoryStatusFilter(status),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(tr('Aucune commande trouvée pour ce filtre.')),
          )
        else
          SizedBox(
            height: listHeight,
            child: ListView.separated(
              itemCount: orders.length,
              separatorBuilder: (_, __) => const Divider(height: 12),
              itemBuilder: (_, index) => _OrderHistoryRow(
                order: orders[index],
                formatAmount: (value) => _formatCurrency(
                  value,
                  controller.currencySymbol,
                  controller.isCurrencySymbolRight,
                ),
                onPayAndPrint: orders[index].isKioskOrder &&
                        orders[index].status.toLowerCase() == 'pos'
                    ? () => payAndPrintOrder(orders[index])
                    : null,
              ),
            ),
          ),
        const SizedBox(height: 12),
        _ProductSummarySection(orders: orders),
        const SizedBox(height: 12),
        if (controller.offlineSales.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              tr('Aucune commande locale a synchroniser.'),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          )
        else
          SizedBox(
            height: listHeight,
            width: double.infinity,
            child: ListView.separated(
              itemCount: controller.offlineSales.length,
              separatorBuilder: (_, __) => const Divider(height: 12),
              itemBuilder: (_, index) {
                final sale = controller.offlineSales[index];
                final createdAt = DateFormat(
                  'dd/MM/yyyy HH:mm',
                ).format(sale.createdAt.toLocal());
                final status = sale.status == OfflineSaleStatus.failed
                    ? tr('Erreur')
                    : (sale.status == OfflineSaleStatus.synced
                        ? tr('Synchronisee')
                        : tr('En attente'));
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: sale.status == OfflineSaleStatus.failed
                        ? const Color(0xFFFEE2E2)
                        : const Color(0xFFFEF3C7),
                    child: Icon(
                      sale.status == OfflineSaleStatus.failed
                          ? Icons.error_outline
                          : Icons.sync,
                      color: sale.status == OfflineSaleStatus.failed
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF92400E),
                    ),
                  ),
                  title: Text(sale.id),
                  subtitle: Text(
                    '$createdAt\n${sale.errorMessage ?? status}',
                  ),
                  isThreeLine: true,
                  trailing: Text(status),
                );
              },
            ),
          ),
      ],
    );

    if (!embedded) {
      return SingleChildScrollView(child: content);
    }
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(child: content),
      ),
    );
  }
}

class _ProductPanel extends StatelessWidget {
  const _ProductPanel({
    required this.controller,
    required this.searchController,
    required this.customGridColumns,
    required this.onSelectProduct,
  });

  final PosController controller;
  final TextEditingController searchController;
  final int customGridColumns;
  final void Function(Product product) onSelectProduct;
  @override
  Widget build(BuildContext context) {
    final appearance = context.watch<AppearanceController>();
    final showSearch = appearance.showSearchInput;
    final showCategory = appearance.showCategoryFilter;
    final showClient = appearance.showClientField;
    final showWarehouse = appearance.showWarehouseField;
    final selectorWidgets = <Widget>[];
    final filterWidgets = <Widget>[];

    if (showClient) {
      selectorWidgets.add(
        _DropdownField<Customer>(
          label: tr('Client'),
          value: controller.selectedCustomer,
          items: controller.customers,
          display: (customer) => customer.name,
          onChanged: controller.selectCustomer,
        ),
      );
      if (controller.loyaltyEnabled &&
          (controller.selectedCustomer?.id ?? 0) > 0) {
        selectorWidgets.add(const SizedBox(height: 8));
        selectorWidgets.add(
          Text(
            '${tr('Loyalty balance')}: ${controller.selectedCustomerPoints} ${tr('pts')} '
            '(${_formatCurrency(controller.loyaltyAvailableAmount, controller.currencySymbol, controller.isCurrencySymbolRight)})',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        );
      }
    }

    if (showWarehouse) {
      if (selectorWidgets.isNotEmpty) {
        selectorWidgets.add(const SizedBox(height: 12));
      }
      void handleWarehouseChange(Warehouse? warehouse) {
        unawaited(() async {
          await controller.selectWarehouse(warehouse);
          final printer = context.read<PrinterSettingsController>();
          printer.syncServices(_resolvePrintingServices(controller));
        }());
      }

      selectorWidgets.add(
        _DropdownField<Warehouse>(
          label: tr('Magasin'),
          value: controller.selectedWarehouse,
          items: controller.warehouses,
          display: (warehouse) => warehouse.name,
          onChanged: handleWarehouseChange,
        ),
      );
    }

    void addSpacing(double height) {
      if (filterWidgets.isNotEmpty) {
        filterWidgets.add(SizedBox(height: height));
      }
    }

    if (showSearch) {
      filterWidgets.add(_buildSearchBar(context));
    }

    if (showCategory) {
      addSpacing(16);
      filterWidgets.add(
        _FilterChips<ProductCategory>(
          title: tr('All Categories'),
          items: controller.categories,
          selectedId: controller.selectedCategoryId,
          onSelected: controller.selectCategory,
          labelFor: (category) => category.name,
          idFor: (category) => category.id,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...selectorWidgets,
          if (selectorWidgets.isNotEmpty) const SizedBox(height: 16),
          ...filterWidgets,
          if (selectorWidgets.isNotEmpty || filterWidgets.isNotEmpty)
            const SizedBox(height: 12),
          Expanded(
            child: appearance.showProductList
                ? ProductGrid(
                    products: controller.products,
                    categories: controller.categories,
                    isLoading: controller.isLoading,
                    onRefresh: () =>
                        controller.refreshProducts(skipSyncOffline: true),
                    onAdd: onSelectProduct,
                    currencySymbol: controller.currencySymbol,
                    currencySymbolRight: controller.isCurrencySymbolRight,
                    customColumns: customGridColumns,
                  )
                : (appearance.showHistoryPanel
                    ? _HistorySection(
                        embedded: true,
                        listHeight: 420,
                      )
                    : Center(
                        child: Text(
                          tr('Section produits masquée dans les paramètres.'),
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      )),
          ),
          if (appearance.showProductList && appearance.showHistoryPanel) ...[
            const SizedBox(height: 16),
            Flexible(
              fit: FlexFit.loose,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: _HistorySection(
                  embedded: true,
                  listHeight: 260,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: tr('Scan/Search Product by Code Name'),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchController.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  searchController.clear();
                  controller.searchProducts('');
                },
                icon: const Icon(Icons.clear),
              ),
        border: _outlineInputBorder(context, radius: 16),
        enabledBorder: _outlineInputBorder(context, radius: 16),
        focusedBorder: _outlineInputBorder(context, radius: 16, width: 1.8),
      ),
      onChanged: controller.searchProducts,
    );
  }
}

class _HeaderIconToolbar extends StatefulWidget {
  const _HeaderIconToolbar({
    required this.onRefresh,
    required this.onLogout,
    required this.userLabel,
    required this.onCashInHand,
    required this.offlineMode,
    required this.onSync,
    required this.lastSyncAt,
    required this.onReconnect,
  });

  final VoidCallback onRefresh;
  final VoidCallback onLogout;
  final String? userLabel;
  final VoidCallback onCashInHand;
  final bool offlineMode;
  final VoidCallback onSync;
  final DateTime? lastSyncAt;
  final VoidCallback onReconnect;

  @override
  State<_HeaderIconToolbar> createState() => _HeaderIconToolbarState();
}

class _HeaderIconToolbarState extends State<_HeaderIconToolbar> {
  bool _isFullScreen = false;

  bool get _isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  @override
  void initState() {
    super.initState();
    _syncFullScreenState();
  }

  Future<void> _syncFullScreenState() async {
    if (!_isDesktop) return;
    final value = await windowManager.isFullScreen();
    if (mounted) {
      setState(() => _isFullScreen = value);
    }
  }

  Future<void> _toggleFullScreen() async {
    if (!_isDesktop) {
      _showSnack(tr('Le plein écran est disponible uniquement sur desktop.'));
      return;
    }
    final nextValue = !_isFullScreen;
    await windowManager.setFullScreen(nextValue);
    if (mounted) {
      setState(() => _isFullScreen = nextValue);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
    );
  }

  Future<void> _openCalculator() async {
    await showDialog(
      context: context,
      builder: (_) => const _CalculatorDialog(),
    );
  }

  Future<void> _openOrderHistory() async {
    final pos = context.read<PosController>();
    final printer = context.read<PrinterSettingsController>();
    final auth = context.read<AuthController>();
    await showDialog(
      context: context,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider<PosController>.value(value: pos),
          ChangeNotifierProvider<PrinterSettingsController>.value(
            value: printer,
          ),
          ChangeNotifierProvider<AuthController>.value(value: auth),
        ],
        child: const _OrderHistoryDialog(),
      ),
    );
  }

  Future<void> _openAppearanceSettings() async {
    await showDialog(
      context: context,
      builder: (_) => const _AppearanceSettingsDialog(),
    );
  }

  Future<void> _openPosConfiguration() async {
    final pos = context.read<PosController>();
    await showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider<PosController>.value(
        value: pos,
        child: _PosConfigurationDialog(
          onTestReset: () => pos.resetHistoryStats(),
        ),
      ),
    );
  }

  Future<void> _openKioskPage() async {
    final appearance = context.read<AppearanceController>();
    if (!appearance.kioskEnabled) {
      _showSnack(tr('La borne est désactivée dans la configuration POS.'));
      return;
    }
    final pos = context.read<PosController>();
    final printer = context.read<PrinterSettingsController>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider<PosController>.value(value: pos),
            ChangeNotifierProvider<PrinterSettingsController>.value(
              value: printer,
            ),
          ],
          child: const KioskPage(),
        ),
      ),
    );
  }

  Future<void> _openWebViewPage() async {
    final appearance = context.read<AppearanceController>();
    final raw = appearance.webViewUrl.trim();
    final url = raw.isEmpty ? AppConfig.defaultWebViewUrl : raw;
    if (Uri.tryParse(url) == null) {
      _showSnack(tr('URL WebView invalide.'));
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PosWebViewPage(
          url: url,
          title: tr('Portail web'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionMenuItem(
        icon: Icons.tune,
        label: tr('Apparence'),
        onTap: _openAppearanceSettings,
      ),
      _ActionMenuItem(
        icon: Icons.print_outlined,
        label: tr('Imprimante'),
        onTap: _openPrinterSettings,
      ),
      _ActionMenuItem(
        icon: Icons.settings_applications_outlined,
        label: tr('Config POS'),
        onTap: _openPosConfiguration,
      ),
      _ActionMenuItem(
        icon: Icons.public,
        label: tr('Portail web'),
        onTap: _openWebViewPage,
      ),
      if (context.read<AppearanceController>().kioskEnabled)
        _ActionMenuItem(
          icon: Icons.store_mall_directory_outlined,
          label: tr('Interface borne'),
          onTap: _openKioskPage,
        ),
    ];

    final greeting = widget.userLabel != null
        ? Text(
            '${tr('Bonjour')} ${widget.userLabel}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          )
        : null;

    final toggleButton = FloatingActionButton.small(
      heroTag: 'header-actions-toggle',
      backgroundColor: Theme.of(context).colorScheme.primary,
      onPressed: () => _showActionMenu(context, actions),
      child: const Icon(Icons.menu),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            toggleButton,
            const SizedBox(width: 10),
            if (greeting != null) greeting,
          ],
        ),
        const SizedBox(height: 12),
        if (widget.offlineMode)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  backgroundColor: Colors.orange.withOpacity(0.15),
                  avatar: const Icon(Icons.cloud_off, color: Colors.orange),
                  label: Text(tr('Mode hors ligne')),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: Text(tr('Synchroniser')),
                  onPressed: widget.onReconnect,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _openPrinterSettings() async {
    final printerController = context.read<PrinterSettingsController>();
    final posController = context.read<PosController>();
    printerController.syncServices(_resolvePrintingServices(posController));
    await showDialog(
      context: context,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider<PrinterSettingsController>.value(
            value: printerController,
          ),
          ChangeNotifierProvider<PosController>.value(value: posController),
        ],
        child: const _PrinterSettingsDialog(),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final tile = Material(
      color: primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: color ?? primary, size: 20),
        ),
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: tile);
    }
    return tile;
  }
}

class _ConnectionStatusIcon extends StatefulWidget {
  const _ConnectionStatusIcon({super.key});

  @override
  State<_ConnectionStatusIcon> createState() => _ConnectionStatusIconState();
}

class _ConnectionStatusIconState extends State<_ConnectionStatusIcon> {
  String _status = tr('Inconnu');
  IconData _icon = Icons.help_outline;
  Color _color = Colors.grey;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      // Cheap check: try resolving a DNS lookup; you can replace with connectivity_plus if available.
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 2));
      final hasNet = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      setState(() {
        _status = hasNet ? tr('Connecté') : tr('Hors ligne');
        _icon = hasNet ? Icons.wifi : Icons.wifi_off;
        _color = hasNet ? Colors.green : Colors.red;
      });
    } catch (_) {
      setState(() {
        _status = tr('Hors ligne');
        _icon = Icons.wifi_off;
        _color = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _IconTile(
      icon: _icon,
      color: _color,
      tooltip:
          '${tr('Statut réseau')}: $_status (${tr('tap pour rafraîchir')})',
      onTap: _refresh,
    );
  }
}

class _CashInHandDialog extends StatefulWidget {
  const _CashInHandDialog({this.initial = 0});

  final double initial;

  @override
  State<_CashInHandDialog> createState() => _CashInHandDialogState();
}

class _CashInHandDialogState extends State<_CashInHandDialog> {
  late TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initial > 0 ? widget.initial.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_controller.text.replaceAll(',', '.'));
    if (value == null) {
      setState(() => _error = tr('Montant invalide'));
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(tr('Cash en caisse')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: tr('Montant initial'),
              prefixIcon: const Icon(Icons.attach_money),
              errorText: _error,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 8),
          Text(
            tr('Saisissez le cash initial avant d\'utiliser le POS.'),
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('Annuler')),
        ),
        FilledButton(onPressed: _submit, child: Text(tr('Valider'))),
      ],
    );
  }
}

class _CalculatorDialog extends StatefulWidget {
  const _CalculatorDialog();

  @override
  State<_CalculatorDialog> createState() => _CalculatorDialogState();
}

class _CalculatorDialogState extends State<_CalculatorDialog> {
  String _display = '0';
  double? _firstValue;
  String? _operator;
  bool _awaitingSecond = false;

  void _appendValue(String value) {
    setState(() {
      if (_awaitingSecond) {
        _display = value == '.' ? '0.' : value;
        _awaitingSecond = false;
        return;
      }
      if (value == '.') {
        if (_display.contains('.')) return;
        _display = '$_display.';
        return;
      }
      if (_display == '0') {
        _display = value;
      } else {
        _display += value;
      }
    });
  }

  void _setOperator(String op) {
    final currentValue = double.tryParse(_display) ?? 0;
    setState(() {
      if (_operator != null && !_awaitingSecond) {
        final result = _applyOperator(
          _firstValue ?? currentValue,
          currentValue,
          _operator!,
        );
        _display = _formatResult(result);
        _firstValue = result;
      } else {
        _firstValue = currentValue;
      }
      _operator = op;
      _awaitingSecond = true;
    });
  }

  void _clear([bool soft = false]) {
    setState(() {
      if (soft) {
        _display = '0';
      } else {
        _display = '0';
        _firstValue = null;
        _operator = null;
        _awaitingSecond = false;
      }
    });
  }

  void _delete() {
    if (_awaitingSecond) return;
    setState(() {
      if (_display.length <= 1) {
        _display = '0';
      } else {
        _display = _display.substring(0, _display.length - 1);
      }
    });
  }

  void _calculate() {
    final op = _operator;
    if (op == null) return;
    final first = _firstValue ?? 0;
    final second = double.tryParse(_display) ?? 0;
    double result = _applyOperator(first, second, op);
    if (result.isNaN) return;
    setState(() {
      _display = _formatResult(result);
      _firstValue = result;
      _awaitingSecond = true;
    });
  }

  double _applyOperator(double first, double second, String op) {
    switch (op) {
      case '+':
        return first + second;
      case '-':
        return first - second;
      case '×':
        return first * second;
      case '÷':
        if (second == 0) {
          _showError();
          return double.nan;
        }
        return first / second;
      default:
        return second;
    }
  }

  String _formatResult(double value) {
    if (value == value.truncateToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('Division par zéro impossible.')),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ['7', '8', '9', '÷'],
      ['4', '5', '6', '×'],
      ['1', '2', '3', '-'],
      ['0', '.', '⌫', '+'],
    ];

    return AlertDialog(
      title: Text(tr('Calculatrice')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _display,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          const SizedBox(height: 12),
          ...buttons.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: row.map((value) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        onPressed: () {
                          if (value == '⌫') {
                            _delete();
                          } else if (['+', '-', '×', '÷'].contains(value)) {
                            _setOperator(value);
                          } else if (value == '.') {
                            _appendValue(value);
                          } else {
                            _appendValue(value);
                          }
                        },
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _clear(),
                  child: Text(tr('AC')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _clear(true),
                  child: Text(tr('C')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: _calculate,
                  child: Text(tr('=')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionSelectionDialog extends StatefulWidget {
  const _OptionSelectionDialog({required this.product});

  final Product product;

  @override
  State<_OptionSelectionDialog> createState() => _OptionSelectionDialogState();
}

class _OptionSelectionDialogState extends State<_OptionSelectionDialog> {
  late final List<_OptionChoice> _choices;

  double _stepFor(double qty) {
    if (qty >= 1) {
      return 0.5;
    }
    return 0.1;
  }

  double _roundQty(double value) {
    return (value * 100).round() / 100;
  }

  @override
  void initState() {
    super.initState();
    _choices = widget.product.options.map((option) {
      final qty = option.quantity;
      return _OptionChoice(
        option: option,
        enabled: qty > 0,
        quantity: qty,
        step: _stepFor(qty),
      );
    }).toList();
  }

  String _formatQty(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product.name),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tr('Options'),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 320,
              child: ListView.separated(
                itemCount: _choices.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final choice = _choices[index];
                  return Row(
                    children: [
                      Switch(
                        value: choice.enabled,
                        onChanged: (value) {
                          setState(() {
                            choice.enabled = value;
                            if (!value) {
                              choice.quantity = 0;
                            } else if (choice.quantity <= 0) {
                              choice.quantity = _roundQty(choice.step);
                            }
                          });
                        },
                      ),
                      Expanded(
                        child: Text(choice.option.name),
                      ),
                      IconButton(
                        onPressed: choice.enabled
                            ? () {
                                setState(() {
                                  final next = choice.quantity - choice.step;
                                  if (next <= 0) {
                                    choice.quantity = 0;
                                    choice.enabled = false;
                                  } else {
                                    choice.quantity = _roundQty(next);
                                  }
                                });
                              }
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      SizedBox(
                        width: 64,
                        child: Text(
                          _formatQty(choice.quantity),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: choice.enabled
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (!choice.enabled) {
                              choice.enabled = true;
                              choice.quantity = choice.quantity > 0
                                  ? choice.quantity
                                  : _roundQty(choice.step);
                              return;
                            }
                            choice.quantity =
                                _roundQty(choice.quantity + choice.step);
                          });
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('Annuler')),
        ),
        FilledButton(
          onPressed: () {
            final selected = <ProductOption>[];
            for (final choice in _choices) {
              final qty = choice.quantity;
              if (choice.enabled && qty > 0) {
                selected.add(choice.option.copyWith(quantity: qty));
              }
            }
            Navigator.of(context).pop(selected);
          },
          child: Text(tr('Ajouter')),
        ),
      ],
    );
  }
}

class _OptionChoice {
  _OptionChoice({
    required this.option,
    required this.enabled,
    required this.quantity,
    required this.step,
  });

  final ProductOption option;
  bool enabled;
  double quantity;
  final double step;
}

class _AppearanceSettingsDialog extends StatefulWidget {
  const _AppearanceSettingsDialog();

  @override
  State<_AppearanceSettingsDialog> createState() =>
      _AppearanceSettingsDialogState();
}

class _AppearanceSettingsDialogState extends State<_AppearanceSettingsDialog> {
  late Color _accentColor;
  late int _gridColumns;
  late bool _darkMode;
  final List<Color> _palette = const [
    Color(0xFF0F9A8A),
    Colors.blue,
    Colors.deepPurple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.redAccent,
    Colors.brown,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    final appearance = context.read<AppearanceController>();
    _accentColor = appearance.accentColor;
    _gridColumns = appearance.productGridColumns;
    _darkMode = appearance.useDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(tr('Personnalisation POS')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('Couleur principale'),
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _palette
                  .map(
                    (color) => GestureDetector(
                      onTap: () => setState(() => _accentColor = color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _accentColor == color
                                ? Colors.black
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            Text(
              '${tr('Produits par rangée')}: $_gridColumns',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Slider(
              value: _gridColumns.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$_gridColumns',
              onChanged: (value) =>
                  setState(() => _gridColumns = value.round()),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _darkMode,
              onChanged: (value) => setState(() => _darkMode = value),
              title: Text(tr('Mode sombre')),
              subtitle: Text(tr('Bascule entre thème clair et sombre')),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('Annuler')),
        ),
        FilledButton(
          onPressed: () {
            final appearance = context.read<AppearanceController>();
            appearance.updateAccentColor(_accentColor);
            appearance.updateGridColumns(_gridColumns);
            appearance.toggleDarkMode(_darkMode);
            Navigator.of(context).pop();
          },
          child: Text(tr('Enregistrer')),
        ),
      ],
    );
  }
}

class _KioskConfigurationDialog extends StatefulWidget {
  const _KioskConfigurationDialog();

  @override
  State<_KioskConfigurationDialog> createState() =>
      _KioskConfigurationDialogState();
}

class _KioskConfigurationDialogState extends State<_KioskConfigurationDialog> {
  late String _background;
  static const _assetBackground = 'lib/features/pos/presentation/1.png';

  @override
  void initState() {
    super.initState();
    _background = context.read<AppearanceController>().backgroundImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(tr('Config borne')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Image de fond POS / Borne'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(tr('Aucune')),
                selected: _background.trim().isEmpty,
                onSelected: (_) => setState(() => _background = ''),
              ),
              ChoiceChip(
                label: Text(tr('Image par défaut')),
                selected: _background.trim() == _assetBackground,
                onSelected: (_) =>
                    setState(() => _background = _assetBackground),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _background,
            decoration: InputDecoration(
              labelText: tr('URL image (http/https) ou asset'),
            ),
            onChanged: (value) => _background = value,
          ),
          const SizedBox(height: 8),
          Text(
            tr('Ex: https://site.com/bg.jpg ou lib/features/pos/presentation/1.png'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('Annuler')),
        ),
        FilledButton(
          onPressed: () {
            context.read<AppearanceController>().updateBackgroundImageUrl(
                  _background,
                );
            Navigator.of(context).pop();
          },
          child: Text(tr('Enregistrer')),
        ),
      ],
    );
  }
}

class _PosConfigurationDialog extends StatefulWidget {
  const _PosConfigurationDialog({required this.onTestReset});

  final Future<void> Function() onTestReset;

  @override
  State<_PosConfigurationDialog> createState() =>
      _PosConfigurationDialogState();
}

class _PosConfigurationDialogState extends State<_PosConfigurationDialog> {
  late bool _showClient;
  late bool _showWarehouse;
  late bool _showSearch;
  late bool _showCategory;
  late bool _showAddToCart;
  late bool _showStock;
  late double _uiScale;
  late bool _showTotalsInCart;
  late bool _showProductList;
  late bool _showCashButton;
  late bool _showResetButton;
  late bool _showHoldButton;
  late bool _showHistoryPanel;
  late int _gridColumns;
  late bool _resetHistoryAt4;
  late int _resetHour;
  late bool _swapSidePanels;
  late bool _kioskEnabled;
  late String _webViewUrl;
  Currency? _selectedCurrency;
  bool _currencyOnRight = true;
  bool _loadingCurrencies = false;
  bool _isSavingCurrency = false;

  @override
  void initState() {
    super.initState();
    final appearance = context.read<AppearanceController>();
    _showClient = appearance.showClientField;
    _showWarehouse = appearance.showWarehouseField;
    _showSearch = appearance.showSearchInput;
    _showCategory = appearance.showCategoryFilter;
    _showAddToCart = appearance.showAddToCartButton;
    _showStock = appearance.showStockInfo;
    _uiScale = appearance.uiScale;
    _showTotalsInCart = appearance.showTotalsInCart;
    _showProductList = appearance.showProductList;
    _showCashButton = appearance.showCashButton;
    _showResetButton = appearance.showResetButton;
    _showHoldButton = appearance.showHoldButton;
    _showHistoryPanel = appearance.showHistoryPanel;
    _gridColumns = appearance.productGridColumns.clamp(3, 5);
    _resetHistoryAt4 = appearance.resetHistoryAt4Am;
    _resetHour = appearance.historyResetHour;
    _swapSidePanels = appearance.swapSidePanels;
    _kioskEnabled = appearance.kioskEnabled;
    _webViewUrl = appearance.webViewUrl;
    final pos = context.read<PosController>();
    _currencyOnRight = pos.isCurrencySymbolRight;
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    setState(() => _loadingCurrencies = true);
    final pos = context.read<PosController>();
    await pos.loadCurrencies();
    if (!mounted) return;
    final currencies = pos.currencies;
    Currency? selected;
    if (pos.currencyId != null) {
      for (final currency in currencies) {
        if (currency.id == pos.currencyId) {
          selected = currency;
          break;
        }
      }
    }
    if (selected == null && currencies.isNotEmpty) {
      for (final currency in currencies) {
        if (currency.symbol == pos.currencySymbol) {
          selected = currency;
          break;
        }
      }
    }
    selected ??= currencies.isNotEmpty ? currencies.first : null;
    setState(() {
      _selectedCurrency = selected;
      _loadingCurrencies = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.watch<PosController>();
    return AlertDialog(
      title: Text(tr('Configuration POS')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Builder(
                builder: (_) {
                  final duration = pos.planDurationDays;
                  final remaining = pos.planRemainingDays;
                  final expiresAt = pos.planExpiresAt;
                  final durationLabel =
                      duration == null ? '-' : '$duration ${tr('jours')}';
                  String remainingLabel = '-';
                  if (remaining != null) {
                    if (remaining < 0) {
                      remainingLabel =
                          '${tr('Expiré')} (${remaining.abs()} ${tr('jours')})';
                    } else {
                      remainingLabel = '$remaining ${tr('jours')}';
                    }
                  }
                  final expiryDateLabel = expiresAt == null
                      ? '-'
                      : DateFormat('dd/MM/yyyy').format(expiresAt.toLocal());
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('Plan'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tr('Durée')}: $durationLabel | ${tr('Reste')}: $remainingLabel',
                      ),
                      Text('${tr('Expire le')}: $expiryDateLabel'),
                    ],
                  );
                },
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('Afficher le champ Client')),
              subtitle: Text(
                tr('Masque simplement le champ tout en conservant le client actuel.'),
              ),
              value: _showClient,
              onChanged: (value) => setState(() => _showClient = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('Afficher le champ Magasin')),
              subtitle: Text(
                tr('Cache l\'entrée visuelle mais garde vos sélections.'),
              ),
              value: _showWarehouse,
              onChanged: (value) => setState(() => _showWarehouse = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('Afficher la barre de recherche')),
              subtitle: Text(
                tr('Permet de masquer l\'input tout en conservant la recherche active.'),
              ),
              value: _showSearch,
              onChanged: (value) => setState(() => _showSearch = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('Afficher les filtres Catégorie')),
              subtitle: Text(
                tr('Masque les boutons de catégories si vous ne les utilisez pas.'),
              ),
              value: _showCategory,
              onChanged: (value) => setState(() => _showCategory = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('Réinitialiser les stats automatiquement')),
              subtitle: Text(
                tr('Quand activé, les indicateurs ventes/articles/caisse repartent à zéro à l\'heure choisie.'),
              ),
              value: _resetHistoryAt4,
              onChanged: (value) => setState(() => _resetHistoryAt4 = value),
            ),
            if (_resetHistoryAt4)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tr('Heure de réinitialisation'),
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        DropdownButton<int>(
                          value: _resetHour,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _resetHour = value);
                            }
                          },
                          items: List.generate(
                            24,
                            (index) => DropdownMenuItem(
                              value: index,
                              child: Text(
                                '${index.toString().padLeft(2, '0')}h',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await widget.onTestReset();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tr('Réinitialisation test effectuée.'),
                            ),
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(tr('Tester la réinitialisation')),
                    ),
                  ],
                ),
              ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('Activer la borne')),
              subtitle: Text(
                tr('Affiche/masque l’accès interface borne dans la bannière.'),
              ),
              value: _kioskEnabled,
              onChanged: (value) => setState(() => _kioskEnabled = value),
            ),
            TextFormField(
              initialValue: _webViewUrl,
              decoration: InputDecoration(
                labelText: tr('URL WebView'),
                hintText: AppConfig.defaultWebViewUrl,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => _webViewUrl = value,
            ),
            const SizedBox(height: 12),
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tr('Devise'),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            if (_loadingCurrencies)
              const LinearProgressIndicator()
            else if (pos.currencies.isEmpty)
              Text(tr('Aucune devise disponible.'))
            else
              DropdownButtonFormField<Currency>(
                value: _selectedCurrency,
                decoration: InputDecoration(
                  labelText: tr('Devise'),
                  border: OutlineInputBorder(),
                ),
                items: pos.currencies
                    .map(
                      (currency) => DropdownMenuItem(
                        value: currency,
                        child: Text(
                          '${currency.symbol} • ${currency.code} • ${currency.name}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedCurrency = value),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('Symbole a droite')),
              subtitle: Text(
                tr('Affiche la devise apres le montant.'),
              ),
              value: _currencyOnRight,
              onChanged: (value) => setState(() => _currencyOnRight = value),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('Produits par ligne'),
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [3, 4, 5].map((value) {
                      final isSelected = _gridColumns == value;
                      return ChoiceChip(
                        label: Text('$value'),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _gridColumns = value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tr('Taille de l\'interface')} (${(_uiScale * 100).round()} %)',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Slider(
                  value: _uiScale,
                  min: 0.6,
                  max: 1.2,
                  divisions: 12,
                  label: '${(_uiScale * 100).round()} %',
                  onChanged: (value) => setState(() => _uiScale = value),
                ),
                Text(
                  tr('Réduit ou agrandit les textes, icônes et boutons (utile sur Android).'),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('Afficher le bouton Ajouter au panier')),
              subtitle: Text(
                tr('Permet de masquer le bouton tout en gardant l\'action sur clic.'),
              ),
              value: _showAddToCart,
              onChanged: (value) => setState(() => _showAddToCart = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('Afficher le stock dans la vignette')),
              subtitle: Text(
                tr('Affiche la pastille avec la quantité disponible.'),
              ),
              value: _showStock,
              onChanged: (value) => setState(() => _showStock = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('Afficher total et QTY (cart)')),
              subtitle: Text(tr('Masque les totaux si espace limité.')),
              value: _showTotalsInCart,
              onChanged: (value) => setState(() => _showTotalsInCart = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('Afficher la section produits')),
              subtitle: Text(
                tr('Masque totalement la grille produits si vous utilisez uniquement le scanner.'),
              ),
              value: _showProductList,
              onChanged: (value) => setState(() => _showProductList = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('Afficher l\'historique rapide')),
              subtitle: Text(
                tr('Ajoute un aperçu des dernières commandes sous la grille.'),
              ),
              value: _showHistoryPanel,
              onChanged: (value) => setState(() => _showHistoryPanel = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('Inverser les panneaux')),
              subtitle: Text(
                tr('Place les produits a gauche et le panier a droite.'),
              ),
              value: _swapSidePanels,
              onChanged: (value) => setState(() => _swapSidePanels = value),
            ),
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tr('Boutons actions'),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('Bouton Espèce')),
              value: _showCashButton,
              onChanged: (value) => setState(() => _showCashButton = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('Bouton Reset')),
              value: _showResetButton,
              onChanged: (value) => setState(() => _showResetButton = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('Bouton Hold')),
              value: _showHoldButton,
              onChanged: (value) => setState(() => _showHoldButton = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('Annuler')),
        ),
        FilledButton(
          onPressed: _isSavingCurrency
              ? null
              : () async {
                  final appearance = context.read<AppearanceController>();
                  appearance.updateClientFieldVisibility(_showClient);
                  appearance.updateWarehouseFieldVisibility(_showWarehouse);
                  appearance.updateSearchInputVisibility(_showSearch);
                  appearance.updateCategoryFilterVisibility(_showCategory);
                  appearance.updateAddToCartVisibility(_showAddToCart);
                  appearance.updateStockInfoVisibility(_showStock);
                  appearance.updateUiScale(_uiScale);
                  appearance.updateCartTotalsVisibility(_showTotalsInCart);
                  appearance.updateProductListVisibility(_showProductList);
                  appearance.updateCashButtonVisibility(_showCashButton);
                  appearance.updateResetButtonVisibility(_showResetButton);
                  appearance.updateHoldButtonVisibility(_showHoldButton);
                  appearance.updateHistoryPanelVisibility(_showHistoryPanel);
                  appearance.updateHistoryReset(_resetHistoryAt4);
                  appearance.updateHistoryResetHour(_resetHour);
                  appearance.updateGridColumns(_gridColumns);
                  appearance.updateSidePanelsSwap(_swapSidePanels);
                  appearance.updateKioskEnabled(_kioskEnabled);
                  appearance.updateWebViewUrl(_webViewUrl);
                  if (_selectedCurrency != null) {
                    setState(() => _isSavingCurrency = true);
                    final ok = await pos.updateCurrencySetting(
                      currencyId: _selectedCurrency!.id,
                      symbolOnRight: _currencyOnRight,
                      currencySymbol: _selectedCurrency!.symbol,
                    );
                    if (!mounted) return;
                    setState(() => _isSavingCurrency = false);
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(tr('Mise a jour de la devise impossible.')),
                        ),
                      );
                      return;
                    }
                  }
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
          child: _isSavingCurrency
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(tr('Enregistrer')),
        ),
      ],
    );
  }
}

class _OrderSummaryPills extends StatelessWidget {
  const _OrderSummaryPills();

  @override
  Widget build(BuildContext context) {
    return Consumer<PosController>(
      builder: (_, controller, __) {
        String formatAmount(double v) => _formatCurrency(
              v,
              controller.currencySymbol,
              controller.isCurrencySymbolRight,
            );
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SummaryPill(
              icon: Icons.receipt_long,
              label: tr('Cmd'),
              value: controller.ordersCount.toString(),
            ),
            _SummaryPill(
              icon: Icons.shopping_bag_outlined,
              label: tr('Articles'),
              value: controller.itemsSold.toString(),
            ),
            _SummaryPill(
              icon: Icons.account_balance_wallet_outlined,
              label: tr('Caisse'),
              value: formatAmount(controller.registerDetails.totalCashAmount),
            ),
          ],
        );
      },
    );
  }
}

class _PrinterSettingsDialog extends StatelessWidget {
  const _PrinterSettingsDialog();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrinterSettingsController>();
    return AlertDialog(
      title: Text(tr('Paramètres imprimante')),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.services.isNotEmpty) ...[
                Text(
                  tr('Service d\'impression'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.services.map((service) {
                    return ChoiceChip(
                      label: Text(service.name),
                      selected: controller.activeServiceId == service.id,
                      onSelected: (_) => controller.selectService(service.id),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: controller.selectedDevice == null ||
                            controller.isTesting
                        ? null
                        : controller.testPrintAllServices,
                    icon: controller.isTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.print_outlined),
                    label: Text(tr('Impression globale')),
                  ),
                ),
                const SizedBox(height: 12),
                ...controller.services.map(
                  (service) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ServiceExamplePrintTile(
                      service: service,
                      isActive: controller.activeServiceId == service.id,
                      isBusy: controller.isTesting,
                      onPressed: controller.selectedDevice == null ||
                              controller.isTesting
                          ? null
                          : () => controller.testPrint(serviceId: service.id),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                tr('Connexion imprimante'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _PrinterTypeSelector(controller: controller),
              if (!controller.currentTypeSupported)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _PrinterStatusBanner(
                    message: tr(
                      'Ce type de connexion n\'est pas supporté sur cette plateforme.',
                    ),
                    isError: true,
                  ),
                ),
              const SizedBox(height: 12),
              _ConnectedPrinterCard(controller: controller),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    onPressed: controller.canDiscover
                        ? controller.discoverPrinters
                        : null,
                    icon: controller.isScanning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(
                      controller.isScanning
                          ? tr('Scan en cours...')
                          : tr('Chercher des imprimantes'),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: controller.showPrinterDiscovery,
                    icon: const Icon(Icons.tune),
                    label: Text(tr('Modifier la sélection')),
                  ),
                  if (controller.canUseManualEntry)
                    OutlinedButton.icon(
                      onPressed: controller.manualAddress.trim().isEmpty
                          ? null
                          : controller.addManualNetworkPrinter,
                      icon: const Icon(Icons.add),
                      label: Text(tr('Ajouter manuellement')),
                    ),
                ],
              ),
              if (controller.showDiscoveredPrinters) ...[
                if (controller.canUseManualEntry) ...[
                  const SizedBox(height: 12),
                  _ManualNetworkFields(controller: controller),
                ],
                const SizedBox(height: 16),
                _PrinterDeviceList(controller: controller),
              ],
              const Divider(height: 32),
              Text(
                tr('Configuration papier et coupe'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _PaperOptions(controller: controller),
              const SizedBox(height: 8),
              Text(
                tr('Taille du texte (%)'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: controller.fontScale,
                      min: 0.5,
                      max: 1.5,
                      divisions: 10,
                      label:
                          '${(controller.fontScale * 100).toStringAsFixed(0)}%',
                      onChanged: (v) => controller.updateFontScale(v),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      '${(controller.fontScale * 100).toStringAsFixed(0)}%',
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                value: controller.autoCut,
                onChanged: controller.toggleAutoCut,
                title: Text(tr('Activer le cutter')),
                subtitle: Text(
                  controller.autoCut
                      ? tr('La coupe sera envoyée après impression.')
                      : tr('Le ticket sortira sans commande de coupe.'),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              Text(
                tr('Gestion des tickets'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _TicketContentSection(controller: controller),
              const SizedBox(height: 12),
              _AutoPrintRoutingSection(controller: controller),
              if (controller.statusMessage != null) ...[
                const SizedBox(height: 8),
                _PrinterStatusBanner(
                  message: controller.statusMessage!,
                  isError: controller.statusIsError,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('Fermer')),
        ),
        TextButton.icon(
          onPressed: controller.persistSettings,
          icon: const Icon(Icons.save_outlined),
          label: Text(tr('Sauvegarder')),
        ),
        TextButton.icon(
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (_) => _PrinterTemplatePreviewDialog(
                template: (controller.activeService?.template ?? 'receipt')
                    .trim()
                    .toLowerCase(),
                paperWidthMm: controller.paperWidth,
                header: controller.ticketHeader,
                footer: controller.ticketFooter,
                showCustomerInfo: controller.showCustomerInfo,
                showCustomerPhone: controller.showCustomerPhone,
                showCustomerEmail: controller.showCustomerEmail,
              ),
            );
          },
          icon: const Icon(Icons.preview_outlined),
          label: Text(tr('Preview ticket')),
        ),
        FilledButton.icon(
          onPressed: controller.isTestEnabled
              ? () =>
                  controller.testPrint(serviceId: controller.activeServiceId)
              : null,
          icon: controller.isTesting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Icon(Icons.print),
          label: Text(tr('Ticket exemple')),
        ),
      ],
    );
  }
}

class _AutoPrintRoutingSection extends StatelessWidget {
  const _AutoPrintRoutingSection({required this.controller});

  final PrinterSettingsController controller;

  @override
  Widget build(BuildContext context) {
    final templates = {
      'receipt',
      'kitchen',
      'bar',
      'kiosk',
      ...controller.services
          .map((service) => service.template.trim().toLowerCase())
          .where((value) => value.isNotEmpty),
    }.toList()
      ..sort();

    Widget buildTemplateChips({
      required bool fromKiosk,
      required Set<String> selected,
    }) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: templates.map((template) {
          final enabled = selected.contains(template);
          return FilterChip(
            label: Text(template),
            selected: enabled,
            onSelected: (value) => controller.toggleTemplateForSource(
              fromKiosk: fromKiosk,
              template: template,
              enabled: value,
            ),
          );
        }).toList(),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Déclenchement automatique des impressions'),
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: controller.autoPrintFromPos,
            onChanged: controller.toggleAutoPrintFromPos,
            title: Text(tr('Imprimer quand la vente vient du POS')),
          ),
          buildTemplateChips(
            fromKiosk: false,
            selected: controller.posTemplates,
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: controller.autoPrintFromKiosk,
            onChanged: controller.toggleAutoPrintFromKiosk,
            title: Text(tr('Imprimer quand la commande vient de la borne')),
          ),
          buildTemplateChips(
            fromKiosk: true,
            selected: controller.kioskTemplates,
          ),
        ],
      ),
    );
  }
}

class _ServiceExamplePrintTile extends StatelessWidget {
  const _ServiceExamplePrintTile({
    required this.service,
    required this.isActive,
    required this.isBusy,
    required this.onPressed,
  });

  final PrintingService service;
  final bool isActive;
  final bool isBusy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isActive
            ? scheme.primaryContainer.withOpacity(0.35)
            : scheme.surfaceVariant.withOpacity(0.25),
        border: Border.all(
          color: isActive
              ? scheme.primary.withOpacity(0.35)
              : scheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Template: ${service.template}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onPressed,
            icon: isBusy
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.print_outlined),
            label: Text(tr('Imprimer exemple')),
          ),
        ],
      ),
    );
  }
}

class _PrinterTypeSelector extends StatelessWidget {
  const _PrinterTypeSelector({required this.controller});

  final PrinterSettingsController controller;

  @override
  Widget build(BuildContext context) {
    final types = controller.availableTypes;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types
          .map(
            (type) => ChoiceChip(
              label: Text(type.label),
              selected: controller.connectionType == type,
              onSelected: (_) => controller.selectType(type),
            ),
          )
          .toList(),
    );
  }
}

class _ConnectedPrinterCard extends StatelessWidget {
  const _ConnectedPrinterCard({required this.controller});

  final PrinterSettingsController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedDevice;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (selected == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            const Icon(Icons.print_disabled_outlined),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                tr('Aucune imprimante connectée pour ce service.'),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.print, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tr('Imprimante connectée'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  selected.type.label,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            selected.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(selected.details),
        ],
      ),
    );
  }
}

class _PrinterDeviceList extends StatelessWidget {
  const _PrinterDeviceList({required this.controller});

  final PrinterSettingsController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.devices.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          tr('Aucune imprimante sélectionnée. Lancez une recherche ou ajoutez une adresse manuellement.'),
        ),
      );
    }
    return Column(
      children: controller.devices
          .map(
            (device) => RadioListTile<PrinterDeviceInfo>(
              value: device,
              groupValue: controller.selectedDevice,
              onChanged: (value) {
                if (value != null) controller.selectDevice(value);
              },
              title: Text(device.name),
              subtitle: Text(device.details),
            ),
          )
          .toList(),
    );
  }
}

class _TicketContentSection extends StatelessWidget {
  const _TicketContentSection({required this.controller});

  final PrinterSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Contenu imprimé sur les tickets'),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            tr(
              'Ces textes sont partagés sur cette caisse et seront utilisés pour tous les utilisateurs.',
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('ticket-header-${controller.ticketHeader}'),
            initialValue: controller.ticketHeader,
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: tr('Entête du ticket'),
              hintText: tr('Ex: Bienvenue chez nous'),
              border: _outlineInputBorder(context),
              enabledBorder: _outlineInputBorder(context),
              focusedBorder: _outlineInputBorder(context, width: 1.8),
            ),
            onChanged: controller.updateTicketHeader,
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('ticket-footer-${controller.ticketFooter}'),
            initialValue: controller.ticketFooter,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: tr('Bas de ticket'),
              hintText: tr('Ex: Merci pour votre visite'),
              border: _outlineInputBorder(context),
              enabledBorder: _outlineInputBorder(context),
              focusedBorder: _outlineInputBorder(context, width: 1.8),
            ),
            onChanged: controller.updateTicketFooter,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(tr('Afficher infos client')),
            subtitle: Text(tr('Nom client imprimé sur le ticket.')),
            value: controller.showCustomerInfo,
            onChanged: controller.toggleShowCustomerInfo,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(tr('Afficher téléphone client')),
            subtitle: Text(tr('Numéro client imprimé si disponible.')),
            value: controller.showCustomerPhone,
            onChanged: controller.toggleShowCustomerPhone,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(tr('Afficher email client')),
            subtitle: Text(tr('Email client imprimé si disponible.')),
            value: controller.showCustomerEmail,
            onChanged: controller.toggleShowCustomerEmail,
          ),
        ],
      ),
    );
  }
}

class _PrinterTemplatePreviewDialog extends StatelessWidget {
  const _PrinterTemplatePreviewDialog({
    required this.template,
    required this.paperWidthMm,
    required this.header,
    required this.footer,
    required this.showCustomerInfo,
    required this.showCustomerPhone,
    required this.showCustomerEmail,
  });

  final String template;
  final double paperWidthMm;
  final String header;
  final String footer;
  final bool showCustomerInfo;
  final bool showCustomerPhone;
  final bool showCustomerEmail;

  @override
  Widget build(BuildContext context) {
    final widthPx = paperWidthMm <= 58 ? 250.0 : 320.0;
    final title = template == 'kitchen'
        ? tr('Ticket cuisine')
        : template == 'kiosk'
            ? tr('Ticket borne')
            : tr('Ticket caisse');
    final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final lines = <String>[
      'POS SAAS',
      now,
      if (header.trim().isNotEmpty) header.trim(),
      '------------------------------',
      if (template == 'kitchen') ...[
        'Commande cuisine',
        if (showCustomerInfo) 'Client: Client exemple',
        '2 x Burger maison',
        '1 x Boisson',
      ] else if (template == 'kiosk') ...[
        'Commande borne',
        'Numero 152',
      ] else ...[
        if (showCustomerInfo) 'Client: Client exemple',
        if (showCustomerPhone) 'Tel client: 0600000000',
        if (showCustomerEmail) 'Email client: client@example.com',
        '2 x Burger maison',
        '1 x Boisson',
        '------------------------------',
        'Total: 99.50 DH',
      ],
      if (footer.trim().isNotEmpty) footer.trim(),
    ];

    return AlertDialog(
      title: Text(tr('Prévisualisation ticket')),
      content: Container(
        width: widthPx,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            ...lines.map(
              (line) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Text(
                  line,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('Fermer')),
        ),
      ],
    );
  }
}

class _ManualNetworkFields extends StatelessWidget {
  const _ManualNetworkFields({required this.controller});

  final PrinterSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${tr('Adresse manuelle')} (${controller.connectionType.label})',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                key: ValueKey('addr-${controller.manualAddress}'),
                initialValue: controller.manualAddress,
                decoration: InputDecoration(
                  labelText: tr('Adresse IP / Nom d\'hôte'),
                  border: _outlineInputBorder(context),
                  enabledBorder: _outlineInputBorder(context),
                  focusedBorder: _outlineInputBorder(context, width: 1.8),
                ),
                onChanged: controller.updateManualAddress,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: TextFormField(
                key: ValueKey('port-${controller.manualPort}'),
                initialValue: controller.manualPort,
                decoration: InputDecoration(
                  labelText: tr('Port'),
                  border: _outlineInputBorder(context),
                  enabledBorder: _outlineInputBorder(context),
                  focusedBorder: _outlineInputBorder(context, width: 1.8),
                ),
                keyboardType: TextInputType.number,
                onChanged: controller.updateManualPort,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PaperOptions extends StatelessWidget {
  const _PaperOptions({required this.controller});

  final PrinterSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('Taille du papier'),
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.paperWidthOptions
              .map(
                (size) => ChoiceChip(
                  label: Text('${size.toStringAsFixed(0)} mm'),
                  selected: controller.paperWidth == size,
                  onSelected: (_) => controller.updatePaperWidth(size),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                key: ValueKey('width-${controller.paperWidth}'),
                initialValue: controller.paperWidth == 0
                    ? ''
                    : '${controller.paperWidth}',
                decoration: InputDecoration(
                  labelText: tr('Largeur (mm)'),
                  border: _outlineInputBorder(context),
                  enabledBorder: _outlineInputBorder(context),
                  focusedBorder: _outlineInputBorder(context, width: 1.8),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: controller.updatePaperWidthFromInput,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                key: ValueKey('height-${controller.paperHeight}'),
                initialValue: controller.paperHeight == 0
                    ? ''
                    : '${controller.paperHeight}',
                decoration: InputDecoration(
                  labelText: tr('Hauteur (mm)'),
                  border: _outlineInputBorder(context),
                  enabledBorder: _outlineInputBorder(context),
                  focusedBorder: _outlineInputBorder(context, width: 1.8),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: controller.updatePaperHeight,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrinterStatusBanner extends StatelessWidget {
  const _PrinterStatusBanner({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.red : Colors.green;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _FilterChips<T> extends StatelessWidget {
  const _FilterChips({
    required this.title,
    required this.items,
    required this.selectedId,
    required this.onSelected,
    required this.labelFor,
    required this.idFor,
  });

  final String title;
  final List<T> items;
  final int? selectedId;
  final ValueChanged<int?> onSelected;
  final String Function(T value) labelFor;
  final int Function(T value) idFor;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: Text(title),
            selected: selectedId == null,
            onSelected: (_) => onSelected(null),
          ),
          const SizedBox(width: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(labelFor(item)),
                selected: selectedId == idFor(item),
                onSelected: (_) => onSelected(idFor(item)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderHistoryDialog extends StatefulWidget {
  const _OrderHistoryDialog();

  @override
  State<_OrderHistoryDialog> createState() => _OrderHistoryDialogState();
}

class _OrderHistoryDialogState extends State<_OrderHistoryDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(tr('Synchronisation des commandes')),
      content: SizedBox(
        width: 640,
        child: _HistorySection(
          embedded: false,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('Fermer')),
        ),
      ],
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.register, required this.formatAmount});

  final RegisterDetails register;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _SummaryPill(
                icon: Icons.receipt_long,
                label: tr('Commandes'),
                value: register.salesCount.toString(),
              ),
              _SummaryPill(
                icon: Icons.shopping_bag_outlined,
                label: tr('Articles vendus'),
                value: register.itemsCount.toString(),
              ),
              _SummaryPill(
                icon: Icons.account_balance_wallet_outlined,
                label: tr('Cash en main'),
                value: formatAmount(register.cashInHand),
              ),
              _SummaryPill(
                icon: Icons.account_balance,
                label: tr('Cash total'),
                value: formatAmount(register.totalCashAmount),
              ),
              _SummaryPill(
                icon: Icons.trending_up,
                label: tr('Ventes du jour'),
                value: formatAmount(register.salesAmount),
              ),
              _SummaryPill(
                icon: Icons.undo,
                label: tr('Retours'),
                value: formatAmount(register.salesReturnAmount),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductSummarySection extends StatelessWidget {
  const _ProductSummarySection({required this.orders});

  final List<OrderSummary> orders;

  @override
  Widget build(BuildContext context) {
    final Map<String, double> totals = {};
    for (final order in orders) {
      if (order.itemsDetail.isNotEmpty) {
        for (final item in order.itemsDetail) {
          totals[item.name] = (totals[item.name] ?? 0) + item.quantity;
        }
      } else {
        for (final name in order.productNames) {
          totals[name] = (totals[name] ?? 0) + 1;
        }
      }
    }
    if (totals.isEmpty) return const SizedBox.shrink();
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Produits vendus (période)'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ...entries.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(e.key, overflow: TextOverflow.ellipsis)),
                  Text(e.value.toStringAsFixed(0)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryPrintPreviewDialog extends StatelessWidget {
  const _HistoryPrintPreviewDialog({
    required this.orders,
    required this.register,
    required this.currencySymbol,
    required this.currencyOnRight,
  });

  final List<OrderSummary> orders;
  final RegisterDetails register;
  final String currencySymbol;
  final bool currencyOnRight;

  @override
  Widget build(BuildContext context) {
    String formatAmount(double v) =>
        _formatCurrency(v, currencySymbol, currencyOnRight);
    final productTotals = _aggregateProducts(orders);
    final userLabel = orders.isNotEmpty ? (orders.first.userName ?? '') : '';
    return AlertDialog(
      title: Text(tr('Aperçu avant impression')),
      content: SizedBox(
        width: 520,
        height: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HistoryHeader(register: register, formatAmount: formatAmount),
              const SizedBox(height: 12),
              if (userLabel.isNotEmpty)
                Text('${tr('Filtre utilisateur :')} $userLabel'),
              if (productTotals.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(tr('Produits (total sur la période)')),
                const SizedBox(height: 4),
                ...productTotals.entries.map(
                  (e) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(e.key, overflow: TextOverflow.ellipsis),
                      ),
                      Text(e.value.toStringAsFixed(0)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (orders.isEmpty)
                Text(tr('Aucune commande à imprimer.'))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (_, index) => _OrderHistoryRow(
                    order: orders[index],
                    formatAmount: formatAmount,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(tr('Annuler')),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.print_outlined),
          label: Text(tr('Imprimer')),
        ),
      ],
    );
  }

  Map<String, double> _aggregateProducts(List<OrderSummary> orders) {
    final Map<String, double> totals = {};
    for (final order in orders) {
      if (order.itemsDetail.isNotEmpty) {
        for (final item in order.itemsDetail) {
          totals[item.name] = (totals[item.name] ?? 0) + item.quantity;
        }
      } else {
        for (final name in order.productNames) {
          totals[name] = (totals[name] ?? 0) + 1;
        }
      }
    }
    return totals;
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderHistoryRow extends StatelessWidget {
  const _OrderHistoryRow({
    required this.order,
    required this.formatAmount,
    this.onPayAndPrint,
  });

  final OrderSummary order;
  final String Function(double) formatAmount;
  final VoidCallback? onPayAndPrint;

  @override
  Widget build(BuildContext context) {
    final date = order.createdAt != null
        ? DateFormat('dd/MM HH:mm').format(order.createdAt!)
        : '-';
    final itemsText = order.itemsDetail.isNotEmpty
        ? order.itemsDetail.map((i) {
            final qtyLabel = i.quantity.toStringAsFixed(0);
            if (i.options.isEmpty) {
              return '${i.name} x$qtyLabel';
            }
            final optionsLabel = i.options.map((option) {
              final qty = option.quantity;
              final qtyText = qty == qty.roundToDouble()
                  ? qty.toStringAsFixed(0)
                  : qty.toString();
              return qty <= 1 ? option.name : '${option.name} x$qtyText';
            }).join(', ');
            return '${i.name} x$qtyLabel ($optionsLabel)';
          }).join(', ')
        : (order.productNames.isNotEmpty
            ? order.productNames.join(', ')
            : tr('Produits indisponibles'));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      itemsText.isNotEmpty
                          ? itemsText
                          : '${tr('Commande')} #${order.id}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (order.isLocal)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tr('Local'),
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (order.isKioskOrder)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Text(
                        tr('Commande borne'),
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(date, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusChip(
                    label: _statusLabel(order.status),
                    color: _statusColor(order.status),
                  ),
                  _StatusChip(
                    label: _paymentStatusLabel(order.paymentStatus),
                    color: _statusColor(order.paymentStatus),
                  ),
                ],
              ),
              if (order.userName != null && order.userName!.isNotEmpty)
                Text(
                  '${tr('Utilisateur')}: ${order.userName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatAmount(order.grandTotal)),
              Text(
                '${tr('Payé')}: ${formatAmount(order.paidAmount)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (onPayAndPrint != null) ...[
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: onPayAndPrint,
                  icon: const Icon(Icons.print_outlined, size: 18),
                  label: Text(tr('Payer & imprimer')),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _statusLabel(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'paid') return tr('Payée');
    if (normalized == 'partial') return tr('Partielle');
    if (normalized == 'unpaid') return tr('Impayée');
    if (normalized == 'onhold') return tr('En attente');
    if (normalized == 'pos') return tr('POS');
    switch (status) {
      case '1':
        return tr('Complétée');
      case '2':
        return tr('En attente');
      case '3':
        return tr('Commandée');
      default:
        return status.isEmpty ? tr('N/A') : status;
    }
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'paid') return Colors.green.shade200;
    if (normalized == 'partial') return Colors.orange.shade200;
    if (normalized == 'unpaid') return Colors.red.shade200;
    if (normalized == 'onhold') return const Color(0xFFFDE68A);
    if (normalized == 'pos') return const Color(0xFFBFDBFE);
    switch (status) {
      case '1':
        return Colors.green.shade200;
      case '2':
        return Colors.orange.shade200;
      case '3':
        return Colors.blue.shade200;
      default:
        return Colors.grey.shade300;
    }
  }

  String _paymentStatusLabel(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'paid') return tr('Payée');
    if (normalized == 'partial') return tr('Partielle');
    if (normalized == 'unpaid') return tr('Impayée');
    switch (status) {
      case '1':
        return tr('Payée');
      case '2':
        return tr('Impayée');
      case '3':
        return tr('Partielle');
      default:
        return status.isEmpty ? tr('N/A') : status;
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color, this.textColor});

  final String label;
  final Color color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor ?? Colors.black87,
        ),
      ),
    );
  }
}

class _PaymentDialogResult {
  _PaymentDialogResult({
    required this.paymentTypeId,
    required this.paymentStatusId,
    required this.receivedAmount,
    required this.shouldPrint,
    required this.change,
    required this.items,
    required this.discountAmount,
    required this.shipping,
    required this.taxRate,
  });

  final int paymentTypeId;
  final int paymentStatusId;
  final double receivedAmount;
  final bool shouldPrint;
  final double change;
  final List<CartItem> items;
  final double discountAmount;
  final double shipping;
  final double taxRate;
}

class _SimplePaymentDialogResult {
  const _SimplePaymentDialogResult({
    required this.paymentTypeId,
    required this.receivedAmount,
  });

  final int paymentTypeId;
  final double receivedAmount;
}

class _SimplePaymentDialog extends StatefulWidget {
  const _SimplePaymentDialog({
    required this.amountDue,
    required this.currencySymbol,
    required this.currencyOnRight,
    required this.paymentMethods,
    required this.defaultPaymentMethodId,
  });

  final double amountDue;
  final String currencySymbol;
  final bool currencyOnRight;
  final List<PaymentMethod> paymentMethods;
  final int defaultPaymentMethodId;

  @override
  State<_SimplePaymentDialog> createState() => _SimplePaymentDialogState();
}

class _SimplePaymentDialogState extends State<_SimplePaymentDialog> {
  late final TextEditingController _receivedController;
  late int _paymentTypeId;

  @override
  void initState() {
    super.initState();
    _receivedController =
        TextEditingController(text: widget.amountDue.toStringAsFixed(2));
    _paymentTypeId = widget.defaultPaymentMethodId;
  }

  @override
  void dispose() {
    _receivedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(tr('Payer la commande')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _receivedController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: tr('Montant reçu'),
              prefixText: widget.currencyOnRight ? null : widget.currencySymbol,
              suffixText: widget.currencyOnRight ? widget.currencySymbol : null,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _paymentTypeId,
            decoration: InputDecoration(labelText: tr('Type de paiement')),
            items: widget.paymentMethods
                .map(
                  (method) => DropdownMenuItem(
                    value: method.id,
                    child: Text(method.name),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                setState(() => _paymentTypeId = value ?? _paymentTypeId),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('Annuler')),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(
            _SimplePaymentDialogResult(
              paymentTypeId: _paymentTypeId,
              receivedAmount:
                  double.tryParse(_receivedController.text) ?? widget.amountDue,
            ),
          ),
          icon: const Icon(Icons.print_outlined),
          label: Text(tr('Payer & imprimer')),
        ),
      ],
    );
  }
}

class _NewCustomerPayload {
  const _NewCustomerPayload({
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.note,
  });

  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? note;
}

class _NewCustomerDialog extends StatefulWidget {
  const _NewCustomerDialog();

  @override
  State<_NewCustomerDialog> createState() => _NewCustomerDialogState();
}

class _NewCustomerDialogState extends State<_NewCustomerDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _noteController;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = tr('Nom requis'));
      return;
    }
    Navigator.of(context).pop(
      _NewCustomerPayload(
        name: name,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(tr('Nouveau client')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: tr('Nom (requis)'),
                errorText: _nameError,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: tr('Téléphone')),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: tr('Email')),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: tr('Adresse')),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(labelText: tr('Note')),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('Annuler')),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(tr('Enregistrer')),
        ),
      ],
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({
    required this.items,
    required this.grandTotal,
    required this.discountAmount,
    required this.shipping,
    required this.taxRate,
    required this.loyaltyRedeemAmount,
    required this.currencySymbol,
    required this.currencyOnRight,
    required this.paymentMethods,
    required this.defaultPaymentMethodId,
  });

  final List<CartItem> items;
  final double grandTotal;
  final double discountAmount;
  final double shipping;
  final double taxRate;
  final double loyaltyRedeemAmount;
  final String currencySymbol;
  final bool currencyOnRight;
  final List<PaymentMethod> paymentMethods;
  final int defaultPaymentMethodId;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  late TextEditingController _receivedController;
  late TextEditingController _discountController;
  late TextEditingController _shippingController;
  late TextEditingController _taxController;
  late List<CartItem> _items;
  double _change = 0;
  int _paymentTypeId = 1;
  int _paymentStatusId = 1;

  @override
  void initState() {
    super.initState();
    _items = widget.items.map((item) => item.copyWith()).toList();
    _receivedController = TextEditingController(
      text: widget.grandTotal.toStringAsFixed(2),
    );
    _discountController = TextEditingController(
      text: widget.discountAmount.toStringAsFixed(2),
    );
    _shippingController = TextEditingController(
      text: widget.shipping.toStringAsFixed(2),
    );
    _taxController = TextEditingController(
      text: widget.taxRate.toStringAsFixed(2),
    );
    _paymentTypeId = widget.defaultPaymentMethodId;
    _syncReceivedWithTotal();
  }

  @override
  void dispose() {
    _receivedController.dispose();
    _discountController.dispose();
    _shippingController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  double get _itemsSubTotal =>
      _items.fold<double>(0, (sum, item) => sum + item.subTotal);

  double get _discountAmount =>
      double.tryParse(_discountController.text) ?? widget.discountAmount;

  double get _shippingAmount =>
      double.tryParse(_shippingController.text) ?? widget.shipping;

  double get _taxRate => double.tryParse(_taxController.text) ?? widget.taxRate;

  double get _taxableBase =>
      (_itemsSubTotal - _discountAmount).clamp(0, double.infinity);

  double get _grandTotal =>
      _taxableBase + (_taxableBase * (_taxRate / 100)) + _shippingAmount;

  void _syncChange() {
    final received = double.tryParse(_receivedController.text) ?? _grandTotal;
    _change = received - _grandTotal;
  }

  void _syncReceivedWithTotal() {
    _receivedController.text = _grandTotal.toStringAsFixed(2);
    _syncChange();
  }

  void _updateItemUnitPrice(int index, String value) {
    final parsed = double.tryParse(value);
    if (parsed == null || parsed < 0) return;
    setState(() {
      _items[index] = _items[index].copyWith(customUnitPrice: parsed);
      _syncReceivedWithTotal();
    });
  }

  InputDecoration _fieldDecoration(
    String label,
    IconData icon, {
    bool useCurrencyAffixes = true,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      prefixText: useCurrencyAffixes && !widget.currencyOnRight
          ? widget.currencySymbol
          : null,
      suffixText: useCurrencyAffixes && widget.currencyOnRight
          ? widget.currencySymbol
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFF7C045)),
      ),
    );
  }

  Widget _priceEditor(BuildContext context, int index) {
    final item = _items[index];
    return Row(
      children: [
        Expanded(
          child: Text(
            '${item.quantity} x ${item.product.name}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 110,
          child: TextFormField(
            initialValue: item.unitPrice.toStringAsFixed(2),
            decoration: _fieldDecoration(tr('Prix'), Icons.edit_outlined),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) => _updateItemUnitPrice(index, value),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxDialogHeight = MediaQuery.of(context).size.height - 48;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFDFB),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEFEFEF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: 520, maxHeight: maxDialogHeight),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      tr('Paiement'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (var i = 0; i < _items.length; i++) ...[
                          _priceEditor(context, i),
                          if (i != _items.length - 1)
                            const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _discountController,
                        decoration:
                            _fieldDecoration(tr('Remise'), Icons.sell_outlined),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (_) => setState(_syncReceivedWithTotal),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _shippingController,
                        decoration: _fieldDecoration(
                            tr('Livraison'), Icons.local_shipping_outlined),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (_) => setState(_syncReceivedWithTotal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _taxController,
                  decoration: _fieldDecoration(
                    tr('Taxe %'),
                    Icons.percent_outlined,
                    useCurrencyAffixes: false,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(_syncReceivedWithTotal),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _receivedController,
                  decoration: _fieldDecoration(
                    tr('Montant reçu'),
                    Icons.payments_outlined,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {
                    setState(_syncChange);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: _fieldDecoration(
                    tr('Montant à payer'),
                    Icons.request_quote_outlined,
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: _grandTotal.toStringAsFixed(2),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: _fieldDecoration(
                      tr('Rendu'), Icons.change_circle_outlined),
                  readOnly: true,
                  controller: TextEditingController(
                    text: _change.toStringAsFixed(2),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _paymentTypeId,
                  decoration: InputDecoration(
                    labelText: tr('Type de paiement'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: widget.paymentMethods
                      .map(
                        (method) => DropdownMenuItem(
                          value: method.id,
                          child: Text(method.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _paymentTypeId = value ?? 1),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _paymentStatusId,
                  decoration: InputDecoration(
                    labelText: tr('Statut'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: _paymentStatuses
                      .map(
                        (option) => DropdownMenuItem(
                          value: option.id,
                          child: Text(tr(option.label)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _paymentStatusId = value ?? 1),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(
                          _PaymentDialogResult(
                            paymentTypeId: _paymentTypeId,
                            paymentStatusId: _paymentStatusId,
                            receivedAmount:
                                double.tryParse(_receivedController.text) ??
                                    _grandTotal,
                            shouldPrint: false,
                            change: _change,
                            items: _items,
                            discountAmount: _discountAmount,
                            shipping: _shippingAmount,
                            taxRate: _taxRate,
                          ),
                        ),
                        child: Text(tr('Payer')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).pop(
                          _PaymentDialogResult(
                            paymentTypeId: _paymentTypeId,
                            paymentStatusId: _paymentStatusId,
                            receivedAmount:
                                double.tryParse(_receivedController.text) ??
                                    _grandTotal,
                            shouldPrint: true,
                            change: _change,
                            items: _items,
                            discountAmount: _discountAmount,
                            shipping: _shippingAmount,
                            taxRate: _taxRate,
                          ),
                        ),
                        icon: const Icon(Icons.receipt_long),
                        label: Text(tr('Payer & imprimer')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptPreviewDialog extends StatelessWidget {
  const _ReceiptPreviewDialog({
    required this.items,
    required this.currencySymbol,
    required this.currencyOnRight,
    required this.companyName,
    required this.companyAddress,
    required this.companyEmail,
    required this.companyPhone,
    required this.warehouseName,
    required this.subTotal,
    required this.discount,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.paymentType,
    required this.paymentStatus,
    required this.received,
    required this.change,
    required this.paperWidthMm,
  });

  final List<CartItem> items;
  final String currencySymbol;
  final bool currencyOnRight;
  final String companyName;
  final String companyAddress;
  final String companyEmail;
  final String companyPhone;
  final String? warehouseName;
  final double subTotal;
  final double discount;
  final double tax;
  final double shipping;
  final double total;
  final String paymentType;
  final String paymentStatus;
  final double received;
  final double change;
  final double paperWidthMm;

  @override
  Widget build(BuildContext context) {
    String format(double value) =>
        _formatCurrency(value, currencySymbol, currencyOnRight);
    final widthPx = paperWidthMm <= 58 ? 260.0 : 320.0;
    return AlertDialog(
      title: Text(tr('Prévisualisation ticket')),
      content: SizedBox(
        width: widthPx,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (companyName.isNotEmpty)
                Text(
                  companyName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              if (companyAddress.isNotEmpty)
                Text(companyAddress, textAlign: TextAlign.center),
              if (companyEmail.isNotEmpty)
                Text(
                  '${tr('Email')}: $companyEmail',
                  textAlign: TextAlign.center,
                ),
              if (companyPhone.isNotEmpty)
                Text(
                  '${tr('Tél')}: $companyPhone',
                  textAlign: TextAlign.center,
                ),
              if (warehouseName != null && warehouseName!.isNotEmpty)
                Text(
                  '${tr('Magasin')}: $warehouseName',
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${tr('Date')} : '
                  '${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Divider(),
              ...items.map(
                (item) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (item.options.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.options.map((option) {
                            final qty = option.quantity;
                            final qtyText = qty == qty.roundToDouble()
                                ? qty.toStringAsFixed(0)
                                : qty.toString();
                            return qty <= 1
                                ? option.name
                                : '${option.name} x$qtyText';
                          }).join(', '),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Text(
                            '${item.quantity} x ${format(item.unitPrice)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            format(item.subTotal),
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              const Divider(),
              _previewLine(tr('Sous-total'), format(subTotal)),
              if (discount != 0) _previewLine(tr('Remise'), format(discount)),
              _previewLine(tr('Taxe'), format(tax)),
              if (shipping != 0)
                _previewLine(tr('Livraison'), format(shipping)),
              const SizedBox(height: 4),
              _previewLine(tr('Total'), format(total), isBold: true),
              const Divider(),
              _previewLine(tr('Paiement'), paymentType),
              _previewLine(tr('Statut'), paymentStatus),
              _previewLine(tr('Reçu'), format(received)),
              _previewLine(tr('Rendu'), format(change)),
              const SizedBox(height: 8),
              Text(
                tr('Merci pour votre achat.'),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(tr('Annuler')),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.print_outlined),
          label: Text(tr('Payer & imprimer')),
        ),
      ],
    );
  }

  Widget _previewLine(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : null),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

class _PaymentOption {
  const _PaymentOption(this.id, this.label);
  final int id;
  final String label;
}

const List<_PaymentOption> _paymentStatuses = [
  _PaymentOption(1, 'Paid'),
  _PaymentOption(2, 'Unpaid'),
  _PaymentOption(3, 'Partial'),
];
