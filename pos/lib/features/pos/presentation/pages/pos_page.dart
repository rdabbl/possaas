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
import '../../../../core/models/payment_method.dart';
import '../../../../core/models/warehouse.dart';
import '../../../../core/models/product_ingredient.dart';
import '../../../../core/api/api_client.dart';
import '../../../auth/state/auth_controller.dart';
import '../../state/appearance_controller.dart';
import '../../state/pos_controller.dart';
import '../../state/printer_controller.dart';
import 'kiosk_page.dart';
import '../widgets/product_grid.dart';

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
      return '12h';
    case 24:
      return '24h';
    case 48:
      return '48h';
    case 168:
      return '7j';
    case 360:
      return '15j';
    case 720:
      return '1 mois';
    default:
      return '${hours}h';
  }
}

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

  double _lastDiscount = 0;
  double _lastShipping = 0;
  double _lastTax = 0;
  bool _messageClearScheduled = false;
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
      await printerController.attachToUser(auth.userLabel);
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

  Future<void> _attemptReconnect() async {
    final auth = context.read<AuthController>();
    final pos = context.read<PosController>();
    pos.clearMessages();
    // Essayer de repasser en ligne et relancer une authentification si possible.
    final ok = await auth.tryReauthenticate();
    if (!ok) {
      pos.setOfflineMode(true);
      _showReconnectSnack(
        'Impossible de se reconnecter. Mode hors ligne conserve.',
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
        _showReconnectSnack('Session expiree. Utilisation du mode hors ligne.');
        return;
      }
      pos.setOfflineMode(true);
      _showReconnectSnack(
        'Rafraichissement impossible (${e.message}). Mode hors ligne conserve.',
      );
    } catch (_) {
      pos.setOfflineMode(true);
      _showReconnectSnack(
        'Rafraichissement impossible. Mode hors ligne conserve.',
      );
    }
  }

  void _showReconnectSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    _discountController.dispose();
    _shippingController.dispose();
    _taxController.dispose();
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
        final body = controller.isLoading && controller.products.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (controller.errorMessage != null)
                    _StatusBanner(
                      message: controller.errorMessage!,
                      isError: true,
                      onDismiss: controller.clearMessages,
                    ),
                  if (controller.successMessage != null)
                    _StatusBanner(
                      message: controller.successMessage!,
                      isError: false,
                      onDismiss: controller.clearMessages,
                    ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 1100;
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDFDFB),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 24,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: isNarrow
                              ? Column(
                                  children: [
                                    Expanded(
                                      child: _CatalogPanel(
                                        controller: controller,
                                        searchController: _searchController,
                                        onOpenMenu: _openQuickMenu,
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
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 520,
                                      child: _CartPanel(
                                        controller: controller,
                                        discountController:
                                            _discountController,
                                        shippingController:
                                            _shippingController,
                                        taxController: _taxController,
                                        notesController: _notesController,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      flex: 7,
                                      child: _CatalogPanel(
                                        controller: controller,
                                        searchController: _searchController,
                                        onOpenMenu: _openQuickMenu,
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
                                    const SizedBox(width: 24),
                                    SizedBox(
                                      width: 360,
                                      child: _CartPanel(
                                        controller: controller,
                                        discountController:
                                            _discountController,
                                        shippingController:
                                            _shippingController,
                                        taxController: _taxController,
                                        notesController: _notesController,
                                      ),
                                    ),
                                  ],
                                ),
                        );
                      },
                    ),
                  ),
                ],
              );

        return Scaffold(
          backgroundColor: const Color(0xFFF8F1D7),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: body,
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
    if (product.ingredients.isEmpty) {
      controller.addProduct(product);
      return;
    }
    final selected = await showDialog<List<ProductIngredient>>(
      context: context,
      builder: (_) => _IngredientSelectionDialog(product: product),
    );
    if (selected == null) return;
    controller.addProduct(product, ingredients: selected);
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
      _taxController.text = controller.taxRate == 0
          ? ''
          : controller.taxRate.toString();
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

  Future<void> _openQuickMenu() async {
    final controller = context.read<PosController>();
    final auth = context.read<AuthController>();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Actualiser les produits'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await controller.refreshProducts(skipSyncOffline: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Historique des ventes'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openOrderHistory();
                },
              ),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Apparence'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openAppearanceSettings();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Se déconnecter'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await auth.logout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _maybeScheduleBannerClear(PosController controller) {
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
    required this.isError,
    required this.onDismiss,
  });

  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.red : Colors.green;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
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
          IconButton(onPressed: onDismiss, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }
}

class _CatalogPanel extends StatelessWidget {
  const _CatalogPanel({
    required this.controller,
    required this.searchController,
    required this.onOpenMenu,
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
    final storeName =
        controller.selectedWarehouse?.name ??
        controller.companyName ??
        'Store';
    final categories = <ProductCategory>[
      ProductCategory(id: 0, name: 'All'),
      ...controller.categories,
    ];
    final selectedCategoryId = controller.selectedCategoryId ?? 0;
    final userLabel = (context.read<AuthController>().userLabel ?? '').trim();
    final displayName = userLabel.isEmpty ? 'User' : userLabel;
    final initials = userLabel.trim().isEmpty
        ? 'U'
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
          hintText: 'Search',
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
          fillColor: const Color(0xFFF3F4F6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      );
    }

    Widget buildIconTile(
      IconData icon, {
      VoidCallback? onTap,
      Color? background,
      Widget? badge,
    }) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: background ?? const Color(0xFFF7C045),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white),
            ),
          ),
          if (badge != null) Positioned(top: -6, right: -6, child: badge),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 980;
        final topActions = _TopActionButtons(
          onRefresh: onRefresh,
          onCashInHand: onCashInHand,
          onSync: onSync,
          onReconnect: onReconnect,
          offlineMode: offlineMode,
          lastSyncAt: lastSyncAt,
          onLogout: onLogout,
        );

        Widget cartIcon() {
          return buildIconTile(
            Icons.shopping_bag_outlined,
            onTap: () {},
            background: Colors.white,
            badge: controller.totalQuantity > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      controller.totalQuantity.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : null,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isTight) ...[
              Row(
                children: [
                  buildIconTile(Icons.menu, onTap: onOpenMenu),
                  const SizedBox(width: 12),
                  Expanded(child: buildSearch()),
                  const SizedBox(width: 12),
                  cartIcon(),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFF3F4F6),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: topActions),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  buildIconTile(Icons.menu, onTap: onOpenMenu),
                  const SizedBox(width: 12),
                  Expanded(child: buildSearch()),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFF3F4F6),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: topActions),
                  const SizedBox(width: 12),
                  cartIcon(),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Store • $storeName',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),
            _HeroBanner(
              title: storeName,
              totalItems: controller.products.length,
              categories: controller.categories.length,
              outlets: controller.warehouses.length,
            ),
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
                    selected: selected,
                    onTap: () => controller.selectCategory(category.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Popular Dish',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ProductGrid(
                products: controller.products,
                isLoading: controller.isLoading,
                onRefresh: () =>
                    controller.refreshProducts(skipSyncOffline: true),
                onAdd: onSelectProduct,
                currencySymbol: controller.currencySymbol,
                currencySymbolRight: controller.isCurrencySymbolRight,
                customColumns: appearance.productGridColumns,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.title,
    required this.totalItems,
    required this.categories,
    required this.outlets,
  });

  final String title;
  final int totalItems;
  final int categories;
  final int outlets;

  @override
  Widget build(BuildContext context) {
    final initials = title.trim().isEmpty ? 'S' : title.trim()[0].toUpperCase();
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF374151)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFF7C045),
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
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Fresh & healthy food recipe',
                  style: TextStyle(color: Color(0xFFE5E7EB), fontSize: 12),
                ),
              ],
            ),
          ),
          _MetricTile(label: 'Total item', value: totalItems),
          const SizedBox(width: 12),
          _MetricTile(label: 'Category', value: categories),
          const SizedBox(width: 12),
          _MetricTile(label: 'Outlet', value: outlets),
        ],
      ),
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
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

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
            color:
                selected ? const Color(0xFFF7C045) : const Color(0xFFE5E7EB),
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
      _showSnack('Le plein écran est disponible uniquement sur desktop.');
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
    final pos = context.read<PosController>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<PosController>.value(
          value: pos,
          child: const KioskPage(),
        ),
      ),
    );
  }

  Future<void> _openPrinterSettings() async {
    final printerController = context.read<PrinterSettingsController>();
    final posController = context.read<PosController>();
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
    final accent = const Color(0xFFF7C045);
    final actions = [
      _ActionMenuItem(
        icon: Icons.refresh,
        label: 'Actualiser',
        onTap: widget.onRefresh,
      ),
      _ActionMenuItem(
        icon: Icons.history,
        label: 'Historique',
        onTap: _openOrderHistory,
      ),
      _ActionMenuItem(
        icon: Icons.calculate_outlined,
        label: 'Calculatrice',
        onTap: _openCalculator,
      ),
      _ActionMenuItem(
        icon: _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
        label: _isFullScreen ? 'Quitter plein écran' : 'Plein écran',
        onTap: _toggleFullScreen,
      ),
      _ActionMenuItem(
        icon: Icons.attach_money,
        label: 'Cash en caisse',
        onTap: widget.onCashInHand,
      ),
      _ActionMenuItem(
        icon: Icons.tune,
        label: 'Apparence',
        onTap: _openAppearanceSettings,
      ),
      _ActionMenuItem(
        icon: Icons.sync,
        label: 'Synchroniser',
        onTap: widget.onSync,
      ),
      _ActionMenuItem(
        icon: Icons.print_outlined,
        label: 'Imprimante',
        onTap: _openPrinterSettings,
      ),
      _ActionMenuItem(
        icon: Icons.settings_applications_outlined,
        label: 'Config POS',
        onTap: _openPosConfiguration,
      ),
      _ActionMenuItem(
        icon: Icons.store_mall_directory_outlined,
        label: 'Interface borne',
        onTap: _openKioskPage,
      ),
      _ActionMenuItem(
        icon: widget.offlineMode ? Icons.cloud_off : Icons.cloud_done,
        label: widget.offlineMode ? 'Mode hors ligne' : 'Connecté',
        onTap: widget.offlineMode ? widget.onReconnect : null,
        color: widget.offlineMode ? Colors.orange : const Color(0xFF22C55E),
        background: widget.offlineMode ? accent : const Color(0xFFF3F4F6),
      ),
      _ActionMenuItem(
        icon: Icons.logout,
        label: 'Déconnexion',
        onTap: widget.onLogout,
      ),
    ];

    return Align(
      alignment: Alignment.centerRight,
      child: _ActionIcon(
        icon: Icons.menu,
        tooltip: 'Menu actions',
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
      color: background ?? Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
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
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final enabled = item.onTap != null;
                  final labelStyle = theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withOpacity(0.4),
                  );
                  return InkWell(
                    onTap: enabled
                        ? () {
                            Navigator.of(context).pop();
                            item.onTap?.call();
                          }
                        : null,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: item.background ??
                            theme.colorScheme.surfaceVariant.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: item.background ??
                                  theme.colorScheme.primary.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              size: 30,
                              color:
                                  item.color ?? theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.label,
                            textAlign: TextAlign.center,
                            style: labelStyle,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
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
    required this.notesController,
  });

  final PosController controller;
  final TextEditingController discountController;
  final TextEditingController shippingController;
  final TextEditingController taxController;
  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    final symbolRight = controller.isCurrencySymbolRight;
    final cartItems = controller.cartItems;

    Future<void> confirmReset() async {
      final shouldClear = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Vider le panier'),
          content: const Text('Supprimer tous les articles du panier ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Vider'),
            ),
          ],
        ),
      );
      if (shouldClear == true) {
        controller.resetCart();
      }
    }

    void openAdjustments() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _CartSummary(
            controller: controller,
            discountController: discountController,
            shippingController: shippingController,
            taxController: taxController,
            notesController: notesController,
          ),
        ),
      );
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
              const Text(
                'My cart',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Vider le panier',
                onPressed: cartItems.isEmpty ? null : confirmReset,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                    child: Text(
                      'Votre panier est vide',
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
            onEdit: openAdjustments,
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
          Expanded(flex: 6, child: Text('PRODUCT', style: style)),
          Expanded(
            flex: 3,
            child: Text('QTY', style: style, textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 3,
            child: Text('SUB TOTAL', style: style, textAlign: TextAlign.end),
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
    final ingredientStyle = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6));

    String formatIngredients() {
      return item.ingredients.map((ingredient) {
        final qty = ingredient.quantity;
        final qtyLabel = qty == qty.roundToDouble()
            ? qty.toStringAsFixed(0)
            : qty.toString();
        return qty <= 1 ? ingredient.name : '${ingredient.name} x$qtyLabel';
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
                  tooltip: 'Supprimer',
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
                      if (item.ingredients.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            formatIngredients(),
                            style: ingredientStyle,
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
    final ingredientStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF9CA3AF),
          fontSize: 11,
        );

    String formatIngredients() {
      return item.ingredients.map((ingredient) {
        final qty = ingredient.quantity;
        final qtyLabel =
            qty == qty.roundToDouble() ? qty.toStringAsFixed(0) : qty.toString();
        return qty <= 1 ? ingredient.name : '${ingredient.name} x$qtyLabel';
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
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFF3F4F6),
            backgroundImage: item.product.imageUrl != null
                ? NetworkImage(item.product.imageUrl!)
                : null,
            child: item.product.imageUrl == null
                ? const Icon(Icons.restaurant_menu, size: 16, color: Colors.black54)
                : null,
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
                if (item.ingredients.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      formatIngredients(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ingredientStyle,
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
          IconButton(
            tooltip: 'Supprimer',
            onPressed: () => controller.removeFromCart(item.id),
            icon: const Icon(Icons.delete_outline, size: 18),
          ),
        ],
      ),
    );
  }
}

class _CartSummaryCard extends StatelessWidget {
  const _CartSummaryCard({
    required this.controller,
    required this.discountController,
    required this.shippingController,
    required this.taxController,
    required this.onEdit,
  });

  final PosController controller;
  final TextEditingController discountController;
  final TextEditingController shippingController;
  final TextEditingController taxController;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final symbol = controller.currencySymbol;
    final symbolRight = controller.isCurrencySymbolRight;
    final isPercent = controller.discountMode == DiscountMode.percentage;
    final discountLabel = isPercent ? 'Discount' : 'Discount';

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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF6D58F)),
        color: const Color(0xFFFFFBF1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Cart summary',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Edit',
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 18),
              ),
            ],
          ),
          summaryRow(
            'Subtotal',
            _formatCurrency(controller.subTotal, symbol, symbolRight),
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
                  this.controller.updateDiscountMode(nextMode);
                },
                borderRadius: BorderRadius.circular(10),
                constraints: const BoxConstraints(minHeight: 30, minWidth: 36),
                selectedColor: Colors.white,
                color: const Color(0xFF6B7280),
                fillColor: const Color(0xFFF7C045),
                children: const [
                  Text('Amt', style: TextStyle(fontSize: 11)),
                  Text('%', style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: discountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.right,
                  onChanged: (value) =>
                      this.controller.updateDiscount(parseInput(value)),
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
          const SizedBox(height: 6),
          editableRow(
            label: 'Tax (%)',
            controller: taxController,
            onChanged: (value) =>
                this.controller.updateTaxRate(parseInput(value)),
            suffixText: '%',
          ),
          const SizedBox(height: 6),
          editableRow(
            label: 'Shipping',
            controller: shippingController,
            onChanged: (value) =>
                this.controller.updateShipping(parseInput(value)),
            suffixText: symbol,
          ),
          const SizedBox(height: 6),
          summaryRow(
            'Final',
            _formatCurrency(controller.grandTotal, symbol, symbolRight),
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
    required this.notesController,
  });

  final PosController controller;
  final TextEditingController discountController;
  final TextEditingController shippingController;
  final TextEditingController taxController;
  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final symbolRight = controller.isCurrencySymbolRight;
    String format(double value) =>
        _formatCurrency(value, controller.currencySymbol, symbolRight);
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
                  Text('Sous-total', style: theme.textTheme.bodySmall),
                  Text(
                    format(controller.subTotal),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TVA', style: theme.textTheme.bodySmall),
                  Text(
                    format(controller.taxTotal),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Livraison', style: theme.textTheme.bodySmall),
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
                    'Total',
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

          final discountLabel = controller.discountMode == DiscountMode.percentage
              ? 'Remise (%)'
              : 'Remise (${controller.currencySymbol})';

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

          const percentDefault = 5.0;
          const fixedDefault = 100.0;
          final percentPresets = <double>[0, 5, 10, 15, 20];
          final fixedPresets = <double>[0, 100, 500, 1000, 2000];
          final presets = controller.discountMode == DiscountMode.percentage
              ? percentPresets
              : fixedPresets;

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
                    segments: const [
                      ButtonSegment(
                        value: DiscountMode.fixed,
                        label: Text('Montant'),
                      ),
                      ButtonSegment(
                        value: DiscountMode.percentage,
                        label: Text('Pourcentage'),
                      ),
                    ],
                    selected: {this.controller.discountMode},
                    onSelectionChanged: (selection) {
                      if (selection.isNotEmpty) {
                        final nextMode = selection.first;
                        this.controller.updateDiscountMode(nextMode);
                        final nextDefault =
                            nextMode == DiscountMode.percentage
                                ? percentDefault
                                : fixedDefault;
                        this.controller.updateDiscount(nextDefault);
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
                      final label =
                          value == 0
                              ? controller.discountMode ==
                                      DiscountMode.percentage
                                  ? 'Aucun pourcentage'
                                  : 'Aucune remise'
                              : controller.discountMode ==
                                      DiscountMode.percentage
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
                buildTextField(
                  label: 'TVA (%)',
                  controller: taxController,
                  onChanged: (value) =>
                      this.controller.updateTaxRate(parseInput(value)),
                ),
                buildTextField(
                  label: 'Livraison (${controller.currencySymbol})',
                  controller: shippingController,
                  onChanged: (value) =>
                      this.controller.updateShipping(parseInput(value)),
                ),
                labeledField(
                  TextField(
                    controller: notesController,
                    decoration: _inputDecoration(context, 'Notes'),
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
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    final appearance = context.watch<AppearanceController>();

    ButtonStyle outlineStyle(Color color) {
      return OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.2),
        shape: shape,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        backgroundColor: Colors.white,
      );
    }

    ButtonStyle filledStyle(Color color) {
      return ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: shape,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
                showError('Ajoutez des articles avant de payer.');
                return;
              }

              final printerController = context
                  .read<PrinterSettingsController>();
              final methods = controller.paymentMethods.isNotEmpty
                  ? controller.paymentMethods
                  : [PaymentMethod.fallback()];
              final defaultMethod = methods.firstWhere(
                (method) => method.isDefault,
                orElse: () => methods.first,
              );

              final result = await showDialog<_PaymentDialogResult>(
                context: context,
                builder: (_) => _PaymentDialog(
                  grandTotal: controller.grandTotal,
                  currencySymbol: controller.currencySymbol,
                  currencyOnRight: controller.isCurrencySymbolRight,
                  paymentMethods: methods,
                  defaultPaymentMethodId: defaultMethod.id,
                ),
              );
              if (result == null) return;
              final selectedMethod = methods.firstWhere(
                (method) => method.id == result.paymentTypeId,
                orElse: () => defaultMethod,
              );
              final paymentStatusLabel = _paymentStatuses
                  .firstWhere(
                    (status) => status.id == result.paymentStatusId,
                    orElse: () => _paymentStatuses.first,
                  )
                  .label;

              final cartSnapshot = List<CartItem>.from(controller.cartItems);
              final subTotal = controller.subTotal;
              final discount = controller.discountAmount;
              final tax = controller.taxTotal;
              final shipping = controller.shipping;
              final grandTotal = controller.grandTotal;

              await controller.checkout(
                notes: notesController.text.trim(),
                paymentTypeId: result.paymentTypeId,
                paymentStatusId: result.paymentStatusId,
                receivedAmount: result.receivedAmount,
                shouldPrint: true,
              );
              if (!context.mounted || controller.errorMessage != null) return;

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
              );
            },
      icon: controller.isProcessingSale
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.payments_outlined),
      label: const Text('PAYER'),
    );

    final resetButton = OutlinedButton.icon(
      style: outlineStyle(resetColor),
      onPressed: controller.resetCart,
      icon: const Icon(Icons.restart_alt),
      label: const Text('Reset'),
    );

    final holdButton = OutlinedButton.icon(
      style: outlineStyle(holdColor),
      onPressed: () => showError('Hold non disponible pour le moment.'),
      icon: const Icon(Icons.pause_circle_outline),
      label: const Text('Hold'),
    );

    final buttonsList = <Widget>[
      if (appearance.showCashButton) payButton,
      if (appearance.showResetButton) resetButton,
      if (appearance.showHoldButton) holdButton,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 640;
        Widget buttons;
        if (buttonsList.isEmpty) {
          buttons = const SizedBox.shrink();
        } else if (isTight) {
          buttons = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < buttonsList.length; i++) ...[
                buttonsList[i],
                if (i < buttonsList.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        } else {
          buttons = Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < buttonsList.length; i++) ...[
                Flexible(child: buttonsList[i]),
                if (i < buttonsList.length - 1) const SizedBox(width: 12),
              ],
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (appearance.showTotalsInCart) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Total : ${_formatCurrency(controller.grandTotal, controller.currencySymbol, controller.isCurrencySymbolRight)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'QTY : ${controller.totalQuantity}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            buttons,
          ],
        );
      },
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
    final theme = Theme.of(context);
    String formatAmount(double v) => _formatCurrency(
          v,
          controller.currencySymbol,
          controller.isCurrencySymbolRight,
        );
    final orders = controller.filteredRecentOrders;
    final combinedUsers = controller.historyUsers;
    final shouldShowUserFilter = combinedUsers.isNotEmpty;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Période:'),
              ..._historyPresetHours.map((h) {
                final selected = controller.historyHours == h;
                return ChoiceChip(
                  label: Text(_historyLabelForHours(h)),
                  selected: selected,
                  onSelected: (_) {
                    controller.loadOrderHistory(hours: h);
                  },
                );
              }),
            ],
          ),
        ),
        if (shouldShowUserFilter) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Utilisateur:'),
              const SizedBox(width: 8),
              DropdownButton<int?>(
                value: controller.historyUserIdFilter,
                hint: const Text('Tous'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Tous'),
                  ),
                  ...combinedUsers
                      .map((u) => DropdownMenuItem(value: u.id, child: Text(u.label)))
                      .toList(),
                ],
                onChanged: controller.updateHistoryUserFilter,
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: controller.offlineSales.isEmpty ||
                    controller.isProcessingSale
                ? null
                : () async {
                    await controller.syncOfflineQueue();
                  },
            icon: controller.isProcessingSale
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(
              controller.offlineSales.isEmpty
                  ? 'Aucune commande locale à envoyer'
                  : 'Envoyer ${controller.offlineSales.length} commande(s) locales',
            ),
          ),
        ),
        const SizedBox(height: 12),
        _HistoryHeader(
          register: controller.displayRegisterDetails,
          formatAmount: formatAmount,
        ),
        const SizedBox(height: 12),
        if (orders.isNotEmpty)
          _ProductSummarySection(orders: orders),
        const SizedBox(height: 12),
        if (controller.isHistoryLoading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (orders.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Aucune commande sur les ${_historyLabelForHours(controller.historyHours)}.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          )
        else
          SizedBox(
            height: listHeight,
            width: double.infinity,
            child: ListView.separated(
              itemCount: orders.length,
              separatorBuilder: (_, __) => const Divider(height: 12),
              itemBuilder: (_, index) => _OrderHistoryRow(
                order: orders[index],
                formatAmount: formatAmount,
              ),
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
          label: 'Client',
          value: controller.selectedCustomer,
          items: controller.customers,
          display: (customer) => customer.name,
          onChanged: controller.selectCustomer,
        ),
      );
    }

    if (showWarehouse) {
      if (selectorWidgets.isNotEmpty) {
        selectorWidgets.add(const SizedBox(height: 12));
      }
      selectorWidgets.add(
        _DropdownField<Warehouse>(
          label: 'Magasin',
          value: controller.selectedWarehouse,
          items: controller.warehouses,
          display: (warehouse) => warehouse.name,
          onChanged: (warehouse) => controller.selectWarehouse(warehouse),
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
          title: 'All Categories',
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
                          'Section produits masquée dans les paramètres.',
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
        hintText: 'Scan/Search Product by Code Name',
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
      _showSnack('Le plein écran est disponible uniquement sur desktop.');
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
    final pos = context.read<PosController>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<PosController>.value(
          value: pos,
          child: const KioskPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionMenuItem(
        icon: Icons.refresh,
        label: 'Actualiser',
        onTap: widget.onRefresh,
      ),
      _ActionMenuItem(
        icon: Icons.history,
        label: 'Historique',
        onTap: _openOrderHistory,
      ),
      _ActionMenuItem(
        icon: Icons.calculate_outlined,
        label: 'Calculatrice',
        onTap: _openCalculator,
      ),
      _ActionMenuItem(
        icon: _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
        label: _isFullScreen ? 'Quitter plein écran' : 'Plein écran',
        onTap: _toggleFullScreen,
      ),
      _ActionMenuItem(
        icon: Icons.attach_money,
        label: 'Cash en caisse',
        onTap: widget.onCashInHand,
      ),
      _ActionMenuItem(
        icon: Icons.tune,
        label: 'Apparence',
        onTap: _openAppearanceSettings,
      ),
      _ActionMenuItem(
        icon: Icons.sync,
        label: 'Synchroniser',
        onTap: widget.onSync,
      ),
      _ActionMenuItem(
        icon: Icons.print_outlined,
        label: 'Imprimante',
        onTap: _openPrinterSettings,
      ),
      _ActionMenuItem(
        icon: Icons.settings_applications_outlined,
        label: 'Config POS',
        onTap: _openPosConfiguration,
      ),
      _ActionMenuItem(
        icon: Icons.store_mall_directory_outlined,
        label: 'Interface borne',
        onTap: _openKioskPage,
      ),
      _ActionMenuItem(
        icon: widget.offlineMode ? Icons.cloud_off : Icons.cloud_done,
        label: widget.offlineMode ? 'Mode hors ligne' : 'Connecté',
        onTap: widget.offlineMode ? widget.onReconnect : null,
        color: widget.offlineMode ? Colors.orange : const Color(0xFF22C55E),
        background: widget.offlineMode
            ? const Color(0xFFFFF7ED)
            : const Color(0xFFF3F4F6),
      ),
      _ActionMenuItem(
        icon: Icons.logout,
        label: 'Déconnexion',
        onTap: widget.onLogout,
      ),
    ];

    final greeting = widget.userLabel != null
        ? Text(
            'Bonjour ${widget.userLabel}',
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
                  label: const Text('Mode hors ligne'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Synchroniser'),
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
  String _status = 'inconnu';
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
        _status = hasNet ? 'Connecté' : 'Hors ligne';
        _icon = hasNet ? Icons.wifi : Icons.wifi_off;
        _color = hasNet ? Colors.green : Colors.red;
      });
    } catch (_) {
      setState(() {
        _status = 'Hors ligne';
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
      tooltip: 'Statut réseau: $_status (tap pour rafraîchir)',
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
      setState(() => _error = 'Montant invalide');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cash en caisse'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Montant initial',
              prefixIcon: const Icon(Icons.attach_money),
              errorText: _error,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 8),
          const Text(
            'Saisissez le cash initial avant d\'utiliser le POS.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Valider')),
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
      const SnackBar(
        content: Text('Division par zéro impossible.'),
        duration: Duration(seconds: 5),
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
      title: const Text('Calculatrice'),
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
                  child: const Text('AC'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _clear(true),
                  child: const Text('C'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: _calculate,
                  child: const Text('='),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IngredientSelectionDialog extends StatefulWidget {
  const _IngredientSelectionDialog({required this.product});

  final Product product;

  @override
  State<_IngredientSelectionDialog> createState() =>
      _IngredientSelectionDialogState();
}

class _IngredientSelectionDialogState
    extends State<_IngredientSelectionDialog> {
  late final List<_IngredientChoice> _choices;

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
    _choices = widget.product.ingredients.map((ingredient) {
      final qty = ingredient.quantity;
      return _IngredientChoice(
        ingredient: ingredient,
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ingrédients',
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
                        child: Text(choice.ingredient.name),
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
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                : Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (!choice.enabled) {
                              choice.enabled = true;
                              choice.quantity =
                                  choice.quantity > 0 ? choice.quantity : _roundQty(choice.step);
                              return;
                            }
                            choice.quantity = _roundQty(choice.quantity + choice.step);
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
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            final selected = <ProductIngredient>[];
            for (final choice in _choices) {
              final qty = choice.quantity;
              if (choice.enabled && qty > 0) {
                selected.add(choice.ingredient.copyWith(quantity: qty));
              }
            }
            Navigator.of(context).pop(selected);
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}

class _IngredientChoice {
  _IngredientChoice({
    required this.ingredient,
    required this.enabled,
    required this.quantity,
    required this.step,
  });

  final ProductIngredient ingredient;
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
      title: const Text('Personnalisation POS'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Couleur principale',
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
              'Produits par rangée : $_gridColumns',
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
              title: const Text('Mode sombre'),
              subtitle: const Text('Bascule entre thème clair et sombre'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            final appearance = context.read<AppearanceController>();
            appearance.updateAccentColor(_accentColor);
            appearance.updateGridColumns(_gridColumns);
            appearance.toggleDarkMode(_darkMode);
            Navigator.of(context).pop();
          },
          child: const Text('Enregistrer'),
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
  late bool _showSlug;
  late bool _showStock;
  late double _uiScale;
  late bool _showCartSummary;
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
    _showSlug = appearance.showProductCode;
    _showStock = appearance.showStockInfo;
    _uiScale = appearance.uiScale;
    _showCartSummary = appearance.showCartSummary;
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
      title: const Text('Configuration POS'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Afficher le champ Client'),
              subtitle: const Text(
                'Masque simplement le champ tout en conservant le client actuel.',
              ),
              value: _showClient,
              onChanged: (value) => setState(() => _showClient = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Afficher le champ Magasin'),
              subtitle: const Text(
                'Cache l\'entrée visuelle mais garde vos sélections.',
              ),
              value: _showWarehouse,
              onChanged: (value) => setState(() => _showWarehouse = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Afficher la barre de recherche'),
              subtitle: const Text(
                'Permet de masquer l\'input tout en conservant la recherche active.',
              ),
              value: _showSearch,
              onChanged: (value) => setState(() => _showSearch = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Afficher les filtres Catégorie'),
              subtitle: const Text(
                'Masque les boutons de catégories si vous ne les utilisez pas.',
              ),
              value: _showCategory,
              onChanged: (value) => setState(() => _showCategory = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Réinitialiser les stats automatiquement'),
              subtitle: const Text(
                'Quand activé, les indicateurs ventes/articles/caisse repartent à zéro à l\'heure choisie.',
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
                        const Expanded(
                          child: Text(
                            'Heure de réinitialisation',
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
                          const SnackBar(
                            content: Text('Réinitialisation test effectuée.'),
                            duration: Duration(seconds: 5),
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tester la réinitialisation'),
                    ),
                  ],
                ),
              ),
            const Divider(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Devise',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            if (_loadingCurrencies)
              const LinearProgressIndicator()
            else if (pos.currencies.isEmpty)
              const Text('Aucune devise disponible.')
            else
              DropdownButtonFormField<Currency>(
                value: _selectedCurrency,
                decoration: const InputDecoration(
                  labelText: 'Devise',
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
                onChanged: (value) =>
                    setState(() => _selectedCurrency = value),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Symbole a droite'),
              subtitle: const Text(
                'Affiche la devise apres le montant.',
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
                  const Text(
                    'Produits par ligne',
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
                  'Taille de l\'interface (${(_uiScale * 100).round()} %)',
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
                const Text(
                  'Réduit ou agrandit les textes, icônes et boutons (utile sur Android).',
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Afficher le bouton Ajouter au panier'),
              subtitle: const Text(
                'Permet de masquer le bouton tout en gardant l\'action sur clic.',
              ),
              value: _showAddToCart,
              onChanged: (value) => setState(() => _showAddToCart = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Afficher le code produit (slug)'),
              subtitle: const Text(
                'Cache ou affiche le code sous le nom du produit.',
              ),
              value: _showSlug,
              onChanged: (value) => setState(() => _showSlug = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Afficher le stock dans la vignette'),
              subtitle: const Text(
                'Affiche la pastille avec la quantité disponible.',
              ),
              value: _showStock,
              onChanged: (value) => setState(() => _showStock = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Afficher total et QTY (cart)'),
              subtitle: const Text('Masque les totaux si espace limité.'),
              value: _showTotalsInCart,
              onChanged: (value) => setState(() => _showTotalsInCart = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Afficher le résumé panier'),
              subtitle: const Text(
                'Permet d\'afficher le bloc de totaux/remises.',
              ),
              value: _showCartSummary,
              onChanged: (value) => setState(() => _showCartSummary = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Afficher la section produits'),
              subtitle: const Text(
                'Masque totalement la grille produits si vous utilisez uniquement le scanner.',
              ),
              value: _showProductList,
              onChanged: (value) => setState(() => _showProductList = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Afficher l\'historique rapide'),
              subtitle: const Text(
                'Ajoute un aperçu des dernières commandes sous la grille.',
              ),
              value: _showHistoryPanel,
              onChanged: (value) => setState(() => _showHistoryPanel = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Inverser les panneaux'),
              subtitle: const Text(
                'Place les produits a gauche et le panier a droite.',
              ),
              value: _swapSidePanels,
              onChanged: (value) => setState(() => _swapSidePanels = value),
            ),
            const Divider(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Boutons actions',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Bouton Espèce'),
              value: _showCashButton,
              onChanged: (value) => setState(() => _showCashButton = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Bouton Reset'),
              value: _showResetButton,
              onChanged: (value) => setState(() => _showResetButton = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Bouton Hold'),
              value: _showHoldButton,
              onChanged: (value) => setState(() => _showHoldButton = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
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
            appearance.updateProductCodeVisibility(_showSlug);
            appearance.updateStockInfoVisibility(_showStock);
            appearance.updateUiScale(_uiScale);
            appearance.updateCartSummaryVisibility(_showCartSummary);
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
                  const SnackBar(
                    content: Text('Mise a jour de la devise impossible.'),
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
              : const Text('Enregistrer'),
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
              label: 'Cmd',
              value: controller.ordersCount.toString(),
            ),
            _SummaryPill(
              icon: Icons.shopping_bag_outlined,
              label: 'Articles',
              value: controller.itemsSold.toString(),
            ),
            _SummaryPill(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Caisse',
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
      title: const Text('Paramètres imprimante'),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _PrinterTypeSelector(controller: controller),
              if (!controller.currentTypeSupported)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _PrinterStatusBanner(
                    message:
                        'Ce type de connexion n\'est pas supporté sur cette plateforme.',
                    isError: true,
                  ),
                ),
              const SizedBox(height: 12),
              Row(
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
                          ? 'Scan en cours...'
                          : 'Chercher des imprimantes',
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (controller.canUseManualEntry)
                    OutlinedButton.icon(
                      onPressed: controller.manualAddress.trim().isEmpty
                          ? null
                          : controller.addManualNetworkPrinter,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter manuellement'),
                    ),
                ],
              ),
              if (controller.canUseManualEntry) ...[
                const SizedBox(height: 12),
                _ManualNetworkFields(controller: controller),
              ],
              const SizedBox(height: 16),
              _PrinterDeviceList(controller: controller),
              const Divider(height: 32),
              _PaperOptions(controller: controller),
              const SizedBox(height: 8),
              const _PrintPreviewSection(),
              const SizedBox(height: 12),
              Text(
                'Taille du texte (%)',
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
                title: const Text('Activer le cutter'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              Text(
                'Infos Wi-Fi (pour ticket)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              TextFormField(
                key: ValueKey('ssid-${controller.wifiSsid}'),
                initialValue: controller.wifiSsid,
                decoration: InputDecoration(
                  labelText: 'SSID',
                  border: _outlineInputBorder(context),
                  enabledBorder: _outlineInputBorder(context),
                  focusedBorder: _outlineInputBorder(context, width: 1.8),
                ),
                onChanged: controller.updateWifiSsid,
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: ValueKey('wifipass-${controller.wifiPassword}'),
                initialValue: controller.wifiPassword,
                decoration: InputDecoration(
                  labelText: 'Mot de passe Wi-Fi',
                  border: _outlineInputBorder(context),
                  enabledBorder: _outlineInputBorder(context),
                  focusedBorder: _outlineInputBorder(context, width: 1.8),
                ),
                onChanged: controller.updateWifiPassword,
              ),
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
          child: const Text('Fermer'),
        ),
        TextButton.icon(
          onPressed: controller.persistSettings,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Sauvegarder'),
        ),
        FilledButton.icon(
          onPressed: controller.isTestEnabled
              ? () => controller.testPrint()
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
          label: const Text('Test print'),
        ),
      ],
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
        child: const Text(
          'Aucune imprimante sélectionnée. Lancez une recherche ou ajoutez une adresse manuellement.',
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

class _ManualNetworkFields extends StatelessWidget {
  const _ManualNetworkFields({required this.controller});

  final PrinterSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adresse manuelle (${controller.connectionType.label})',
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
                  labelText: 'Adresse IP / Nom d\'hôte',
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
                  labelText: 'Port',
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
        Text('Taille du papier', style: Theme.of(context).textTheme.titleSmall),
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
                  labelText: 'Largeur (mm)',
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
                  labelText: 'Hauteur (mm)',
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

class _PrintPreviewSection extends StatelessWidget {
  const _PrintPreviewSection();

  @override
  Widget build(BuildContext context) {
    // Use the nearest provider inside the dialog tree (it is provided by the parent PosPage).
    final pos = context.read<PosController>();
    final currency = pos.currencySymbol;
    final previewItems = pos.cartItems.isNotEmpty
        ? pos.cartItems.take(3).toList()
        : pos.products
              .take(3)
              .map((p) => CartItem(product: p, quantity: 1, ingredients: p.ingredients))
              .toList();

    String _formatAmount(double value) =>
        _formatCurrency(value, currency, pos.isCurrencySymbolRight);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prévisualisation avant impression',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _PreviewCard(
                title: 'Ticket de vente',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Client: ${pos.selectedCustomer?.name ?? 'Walk-in'}'),
                    const SizedBox(height: 4),
                    ...previewItems.map(
                      (item) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.product.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text('x${item.quantity.toStringAsFixed(0)}'),
                          Text(
                            _formatAmount(item.product.price * item.quantity),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    _previewLine('Total', _formatAmount(pos.subTotal)),
                    _previewLine('TVA', _formatAmount(pos.taxTotal)),
                    _previewLine('Livraison', _formatAmount(pos.shipping)),
                    const Divider(),
                    _previewLine(
                      'À payer',
                      _formatAmount(pos.grandTotal),
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PreviewCard(
                title: 'Historique (dernier)',
                content: Builder(
                  builder: (_) {
                    final last = pos.recentOrders.isNotEmpty
                        ? pos.recentOrders.first
                        : null;
                    if (last == null) {
                      return const Text('Aucune commande encore enregistrée.');
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          last.referenceCode,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(last.customerName),
                        const SizedBox(height: 4),
                        _previewLine('Montant', _formatAmount(last.grandTotal)),
                        _previewLine('Payé', _formatAmount(last.paidAmount)),
                        _previewLine('Articles', last.itemCount.toString()),
                        if (last.createdAt != null)
                          Text(
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(last.createdAt!.toLocal()),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _previewLine(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.title, required this.content});

  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.print_outlined, size: 18),
              const SizedBox(width: 6),
              Text(title, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 8),
          content,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pos = context.read<PosController>();
      pos.loadOrderHistory(hours: pos.historyHours);
      pos.loadHistoryUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PosController>();
    final filteredOrders = controller.filteredRecentOrders;
    final auth = context.read<AuthController>();

    return AlertDialog(
      title: const Text('Historique des commandes'),
      content: SizedBox(
        width: 640,
        child: _HistorySection(
          embedded: false,
        ),
      ),
      actions: [
        OutlinedButton.icon(
          onPressed: () async {
            final posController = context.read<PosController>();
            final printerController = context.read<PrinterSettingsController>();
            final ordersWithNames =
                await posController.loadProductNamesForOrders(filteredOrders);
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => _HistoryPrintPreviewDialog(
                orders: ordersWithNames,
                register: posController.displayRegisterDetails,
                currencySymbol: posController.currencySymbol,
                currencyOnRight: posController.isCurrencySymbolRight,
              ),
            );
            if (confirm != true) return;
            await printerController.printSalesHistory(
              orders: ordersWithNames,
              register: posController.displayRegisterDetails,
              currencySymbol: posController.currencySymbol,
              currencyOnRight: posController.isCurrencySymbolRight,
              userLabel: auth.userLabel,
            );
            await posController.resetHistoryStats();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Historique réinitialisé après impression.'),
                duration: Duration(seconds: 5),
              ),
            );
          },
          icon: const Icon(Icons.print_outlined),
          label: const Text('Imprimer'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
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
                label: 'Commandes',
                value: register.salesCount.toString(),
              ),
              _SummaryPill(
                icon: Icons.shopping_bag_outlined,
                label: 'Articles vendus',
                value: register.itemsCount.toString(),
              ),
              _SummaryPill(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Cash en main',
                value: formatAmount(register.cashInHand),
              ),
              _SummaryPill(
                icon: Icons.account_balance,
                label: 'Cash total',
                value: formatAmount(register.totalCashAmount),
              ),
              _SummaryPill(
                icon: Icons.trending_up,
                label: 'Ventes du jour',
                value: formatAmount(register.salesAmount),
              ),
              _SummaryPill(
                icon: Icons.undo,
                label: 'Retours',
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
            'Produits vendus (période)',
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
      title: const Text('Aperçu avant impression'),
      content: SizedBox(
        width: 520,
        height: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HistoryHeader(register: register, formatAmount: formatAmount),
              const SizedBox(height: 12),
              if (userLabel.isNotEmpty) Text('Filtre utilisateur : $userLabel'),
              if (productTotals.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Produits (total sur la période)'),
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
                const Text('Aucune commande à imprimer.')
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
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.print_outlined),
          label: const Text('Imprimer'),
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
  const _OrderHistoryRow({required this.order, required this.formatAmount});

  final OrderSummary order;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    final date = order.createdAt != null
        ? DateFormat('dd/MM HH:mm').format(order.createdAt!)
        : '-';
    final itemsText = order.itemsDetail.isNotEmpty
        ? order.itemsDetail
              .map((i) {
                final qtyLabel = i.quantity.toStringAsFixed(0);
                if (i.ingredients.isEmpty) {
                  return '${i.name} x$qtyLabel';
                }
                final ingredientsLabel = i.ingredients.map((ingredient) {
                  final qty = ingredient.quantity;
                  final qtyText = qty == qty.roundToDouble()
                      ? qty.toStringAsFixed(0)
                      : qty.toString();
                  return qty <= 1
                      ? ingredient.name
                      : '${ingredient.name} x$qtyText';
                }).join(', ');
                return '${i.name} x$qtyLabel ($ingredientsLabel)';
              })
              .join(', ')
        : (order.productNames.isNotEmpty
              ? order.productNames.join(', ')
              : 'Produits indisponibles');
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
                          : 'Commande #${order.id}',
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
                      child: const Text(
                        'Local',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(date, style: Theme.of(context).textTheme.bodySmall),
              if (order.userName != null && order.userName!.isNotEmpty)
                Text(
                  'Utilisateur: ${order.userName}',
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
                'Payé : ${formatAmount(order.paidAmount)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _statusLabel(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'paid') return 'Payée';
    if (normalized == 'partial') return 'Partielle';
    if (normalized == 'unpaid') return 'Impayée';
    switch (status) {
      case '1':
        return 'Complétée';
      case '2':
        return 'En attente';
      case '3':
        return 'Commandée';
      default:
        return status.isEmpty ? 'N/A' : status;
    }
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'paid') return Colors.green.shade200;
    if (normalized == 'partial') return Colors.orange.shade200;
    if (normalized == 'unpaid') return Colors.red.shade200;
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
    if (normalized == 'paid') return 'Payée';
    if (normalized == 'partial') return 'Partielle';
    if (normalized == 'unpaid') return 'Impayée';
    switch (status) {
      case '1':
        return 'Payée';
      case '2':
        return 'Impayée';
      case '3':
        return 'Partielle';
      default:
        return status.isEmpty ? 'N/A' : status;
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
  });

  final int paymentTypeId;
  final int paymentStatusId;
  final double receivedAmount;
  final bool shouldPrint;
  final double change;
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({
    required this.grandTotal,
    required this.currencySymbol,
    required this.currencyOnRight,
    required this.paymentMethods,
    required this.defaultPaymentMethodId,
  });

  final double grandTotal;
  final String currencySymbol;
  final bool currencyOnRight;
  final List<PaymentMethod> paymentMethods;
  final int defaultPaymentMethodId;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  late TextEditingController _receivedController;
  double _change = 0;
  int _paymentTypeId = 1;
  int _paymentStatusId = 1;

  @override
  void initState() {
    super.initState();
    _receivedController = TextEditingController(
      text: widget.grandTotal.toStringAsFixed(2),
    );
    _change =
        (double.tryParse(_receivedController.text) ?? widget.grandTotal) -
        widget.grandTotal;
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
      title: const Text('Paiement'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _receivedController,
              decoration: InputDecoration(
                labelText: 'Montant reçu',
                prefixIcon: const Icon(Icons.payments_outlined),
                prefixText: widget.currencyOnRight
                    ? null
                    : widget.currencySymbol,
                suffixText: widget.currencyOnRight
                    ? widget.currencySymbol
                    : null,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) {
                final parsed = double.tryParse(value) ?? widget.grandTotal;
                setState(() => _change = parsed - widget.grandTotal);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Montant à payer',
                prefixIcon: const Icon(Icons.request_quote_outlined),
                prefixText: widget.currencyOnRight
                    ? null
                    : widget.currencySymbol,
                suffixText: widget.currencyOnRight
                    ? widget.currencySymbol
                    : null,
              ),
              readOnly: true,
              controller: TextEditingController(
                text: widget.grandTotal.toStringAsFixed(2),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Rendu',
                prefixIcon: const Icon(Icons.change_circle_outlined),
                prefixText: widget.currencyOnRight
                    ? null
                    : widget.currencySymbol,
                suffixText: widget.currencyOnRight
                    ? widget.currencySymbol
                    : null,
              ),
              readOnly: true,
              controller: TextEditingController(
                text: _change.toStringAsFixed(2),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _paymentTypeId,
              decoration: const InputDecoration(labelText: 'Type de paiement'),
              items: widget.paymentMethods
                  .map(
                    (method) => DropdownMenuItem(
                      value: method.id,
                      child: Text(method.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _paymentTypeId = value ?? 1),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _paymentStatusId,
              decoration: const InputDecoration(labelText: 'Statut'),
              items: _paymentStatuses
                  .map(
                    (option) => DropdownMenuItem(
                      value: option.id,
                      child: Text(option.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _paymentStatusId = value ?? 1),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(
            _PaymentDialogResult(
              paymentTypeId: _paymentTypeId,
              paymentStatusId: _paymentStatusId,
              receivedAmount:
                  double.tryParse(_receivedController.text) ??
                  widget.grandTotal,
              shouldPrint: true,
              change: _change,
            ),
          ),
          icon: const Icon(Icons.receipt_long),
          label: const Text('Confirmer & imprimer'),
        ),
      ],
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
    required this.tax,
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
  final double tax;
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
      title: const Text('Prévisualisation ticket'),
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
                Text('Email : $companyEmail', textAlign: TextAlign.center),
              if (companyPhone.isNotEmpty)
                Text('Tél : $companyPhone', textAlign: TextAlign.center),
              if (warehouseName != null && warehouseName!.isNotEmpty)
                Text('Magasin : $warehouseName', textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Date : ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
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
                    if (item.ingredients.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.ingredients.map((ingredient) {
                            final qty = ingredient.quantity;
                            final qtyText = qty == qty.roundToDouble()
                                ? qty.toStringAsFixed(0)
                                : qty.toString();
                            return qty <= 1
                                ? ingredient.name
                                : '${ingredient.name} x$qtyText';
                          }).join(', '),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Text(
                            '${item.quantity} x ${format(item.product.price)}',
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
              _previewLine('Sous-total', format(subTotal)),
              _previewLine('Taxe', format(tax)),
              const SizedBox(height: 4),
              _previewLine('Total', format(total), isBold: true),
              const Divider(),
              _previewLine('Paiement', paymentType),
              _previewLine('Statut', paymentStatus),
              _previewLine('Reçu', format(received)),
              _previewLine('Rendu', format(change)),
              const SizedBox(height: 8),
              const Text(
                'Merci pour votre achat.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.print_outlined),
          label: const Text('Payer & imprimer'),
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
