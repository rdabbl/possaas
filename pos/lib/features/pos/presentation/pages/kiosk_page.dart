import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/cart_item.dart';
import '../../../../core/models/product.dart';
import '../../../../core/models/product_category.dart';
import '../../../../core/i18n/translation_controller.dart';
import '../../state/pos_controller.dart';
import '../../state/printer_controller.dart';
import '../../models/printing_service.dart';
import '../../../../core/widgets/app_network_image.dart';
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
  return symbolOnRight ? '$formatted $trimmedSymbol' : '$trimmedSymbol $formatted';
}

class _KioskStrings {
  const _KioskStrings();

  String get backToPos => tr('Retour POS');
  String get kioskMenu => tr('Menu borne');
  String get all => tr('All');
  String get noProducts => tr('Aucun produit disponible.');
  String get selectProduct => tr('Sélectionnez un produit');
  String get extras => tr('Extras');
  String get notes => tr('Notes');
  String cartSummary(int count) {
    return '${tr('Panier')}: $count ${tr('article(s)')}';
  }

  String get addToCart => tr('Ajouter au panier');
  String get checkout => tr('Commander et payer');
  String get order => tr('Commander à la caisse');
  String get addRequired => tr('Ajoutez un produit d\'abord.');
}

class KioskPage extends StatefulWidget {
  const KioskPage({super.key});

  @override
  State<KioskPage> createState() => _KioskPageState();
}

class _KioskPageState extends State<KioskPage> {
  Product? _selectedProduct;
  final List<CartItem> _cart = [];
  _KioskStrings get _strings => const _KioskStrings();

  Product? _resolveSelected(List<Product> products) {
    if (products.isEmpty) {
      return null;
    }
    if (_selectedProduct == null) {
      return products.first;
    }
    return products.firstWhere(
      (product) => product.id == _selectedProduct!.id,
      orElse: () => products.first,
    );
  }

  int get _cartCount =>
      _cart.fold<int>(0, (sum, item) => sum + item.quantity);

  double get _cartTotal =>
      _cart.fold<double>(0, (sum, item) => sum + item.subTotal);

  void _addToCart(Product product) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index == -1) {
      _cart.add(CartItem(product: product));
    } else {
      final current = _cart[index];
      _cart[index] = current.copyWith(quantity: current.quantity + 1);
    }
    setState(() {});
  }

  void _clearCart() {
    _cart.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PosController>(
      builder: (context, pos, _) {
        final i18n = context.watch<TranslationController>();
        final isFrench = i18n.locale.startsWith('fr');
        final categories = pos.categories;
        final products = pos.products;
        final selectedProduct = _resolveSelected(products);
        final strings = _strings;

        return Scaffold(
          backgroundColor: const Color(0xFFF1F3F7),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 1000;
                final isCompact = constraints.maxWidth < 720;
                final panelSpacing = isWide ? 28.0 : 20.0;
                final outerPadding = isCompact ? 12.0 : 20.0;
                final content = isWide
                    ? Row(
                        children: [
                          Expanded(
                            child: _KioskMenuPanel(
                              categories: categories,
                              selectedCategoryId: pos.selectedCategoryId,
                              products: products,
                              isLoading: pos.isLoading,
                              onCategorySelected: (categoryId) async {
                                await pos.selectCategory(categoryId);
                              },
                              onProductSelected: (product) {
                                setState(() => _selectedProduct = product);
                              },
                              strings: strings,
                            ),
                          ),
                          SizedBox(width: panelSpacing),
                          Expanded(
                            child: _KioskDetailPanel(
                              product: selectedProduct,
                              currencySymbol: pos.currencySymbol,
                              symbolOnRight: pos.isCurrencySymbolRight,
                              cartCount: _cartCount,
                              cartTotal: _cartTotal,
                              strings: strings,
                              onAdd: () {
                                final selected = selectedProduct;
                                if (selected != null) {
                                  _addToCart(selected);
                                }
                              },
                              onCheckout: () => _handleSubmit(
                                pos,
                                selectedProduct,
                                markUnpaid: false,
                              ),
                              onOrder: () => _handleSubmit(
                                pos,
                                selectedProduct,
                                markUnpaid: true,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _KioskMenuPanel(
                            categories: categories,
                            selectedCategoryId: pos.selectedCategoryId,
                            products: products,
                            isLoading: pos.isLoading,
                            onCategorySelected: (categoryId) async {
                              await pos.selectCategory(categoryId);
                            },
                            onProductSelected: (product) {
                              setState(() => _selectedProduct = product);
                            },
                            strings: strings,
                          ),
                          SizedBox(height: panelSpacing),
                          _KioskDetailPanel(
                            product: selectedProduct,
                            currencySymbol: pos.currencySymbol,
                            symbolOnRight: pos.isCurrencySymbolRight,
                            cartCount: _cartCount,
                            cartTotal: _cartTotal,
                            strings: strings,
                            onAdd: () {
                              final selected = selectedProduct;
                              if (selected != null) {
                                _addToCart(selected);
                              }
                            },
                            onCheckout: () => _handleSubmit(
                              pos,
                              selectedProduct,
                              markUnpaid: false,
                            ),
                            onOrder: () => _handleSubmit(
                              pos,
                              selectedProduct,
                              markUnpaid: true,
                            ),
                          ),
                        ],
                      );

                return Padding(
                  padding: EdgeInsets.all(outerPadding),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back),
                            label: Text(strings.backToPos),
                          ),
                          const Spacer(),
                          ToggleButtons(
                            isSelected: [!isFrench, isFrench],
                            onPressed: (index) {
                              final locale = index == 1 ? 'fr' : 'en';
                              context.read<TranslationController>().setLocale(
                                locale,
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 36,
                            ),
                            children: [
                              Text(tr('EN')),
                              Text(tr('FR')),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(child: content),
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

  Future<void> _handleSubmit(
    PosController pos,
    Product? selected,
    {required bool markUnpaid}
  ) async {
    if (_cart.isEmpty && selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.addRequired)),
      );
      return;
    }

    if (_cart.isEmpty && selected != null) {
      _addToCart(selected);
    }

    final queueNumber = pos.kioskQueueNumber;
    final taxTotal = _cartTotal * (pos.taxRate / 100);
    final totalWithTax = _cartTotal + taxTotal;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _KioskReceiptPreviewDialog(
        items: List<CartItem>.from(_cart),
        currencySymbol: pos.currencySymbol,
        currencyOnRight: pos.isCurrencySymbolRight,
        companyName: pos.companyName,
        queueNumber: queueNumber,
        total: totalWithTax,
        confirmLabel:
            markUnpaid ? tr('Confirmer la commande') : tr('Payer & imprimer'),
      ),
    );
    if (confirmed != true) return;

    final ok = await pos.submitKioskOrder(
      items: List<CartItem>.from(_cart),
      markUnpaid: markUnpaid,
      queueNumber: queueNumber,
      receivedAmount: markUnpaid ? 0 : totalWithTax,
      paymentTypeId: 1,
    );
    if (!mounted) return;
    if (!ok) {
      final message = pos.errorMessage ?? tr('Erreur lors de la commande.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      pos.clearMessages();
      return;
    }

    final printer = context.read<PrinterSettingsController>();
    final services = pos.activePrintingServices;
    final resolved = services.isNotEmpty
        ? services
        : [PrintingService.fallback(storeId: pos.selectedWarehouse?.id ?? 0)];
    printer.syncServices(resolved);
    for (final service in resolved) {
      await printer.printSaleReceipt(
        items: List<CartItem>.from(_cart),
        subTotal: _cartTotal,
        discount: 0,
        tax: taxTotal,
        shipping: 0,
        grandTotal: totalWithTax,
        currencySymbol: pos.currencySymbol,
        currencyOnRight: pos.isCurrencySymbolRight,
        customerName: null,
        userLabel: null,
        companyName: pos.companyName,
        companyAddress: pos.companyAddress,
        companyEmail: pos.companyEmail,
        companyPhone: pos.companyPhone,
        warehouseName: pos.selectedWarehouse?.name,
        companyLogoUrl: pos.companyLogo,
        paymentType: tr('Espèce'),
        paymentStatus: markUnpaid ? tr('Impayée') : tr('Payée'),
        receivedAmount: markUnpaid ? 0 : totalWithTax,
        change: 0,
        serviceId: service.id,
        template: service.template,
      );
    }

    _clearCart();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr('Commande confirmée')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tr('Merci pour votre commande.'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              markUnpaid
                  ? tr('Vous pouvez prendre votre place à la caisse.')
                  : tr('Votre paiement est confirmé.'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '${tr('Votre numéro est')} $queueNumber',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr('OK')),
          ),
        ],
      ),
    );
  }
}

class _KioskPanelShell extends StatelessWidget {
  const _KioskPanelShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: child,
      ),
    );
  }
}

class _KioskMenuPanel extends StatelessWidget {
  const _KioskMenuPanel({
    required this.categories,
    required this.selectedCategoryId,
    required this.products,
    required this.isLoading,
    required this.onCategorySelected,
    required this.onProductSelected,
    required this.strings,
  });

  final List<ProductCategory> categories;
  final int? selectedCategoryId;
  final List<Product> products;
  final bool isLoading;
  final ValueChanged<int?> onCategorySelected;
  final ValueChanged<Product> onProductSelected;
  final _KioskStrings strings;

  @override
  Widget build(BuildContext context) {
    final palette = <Color>[
      const Color(0xFFFFE8A3),
      const Color(0xFFFFE0D6),
      const Color(0xFFE8F3FF),
      const Color(0xFFFFF0C9),
      const Color(0xFFE9E3FF),
      const Color(0xFFDDF7E3),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final padding = isCompact ? 16.0 : 24.0;
        final spacing = 14.0;
        final minCardWidth = isCompact ? 150.0 : 180.0;
        int columns =
            (constraints.maxWidth / (minCardWidth + spacing)).floor();
        if (columns < 1) columns = 1;
        if (columns > 3) columns = 3;
        final cardWidth = ((constraints.maxWidth -
                    (columns - 1) * spacing) /
                columns)
            .clamp(minCardWidth, 220.0)
            .toDouble();

        return _KioskPanelShell(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4D6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          tr('M'),
                          style: TextStyle(
                            color: Color(0xFFE8A700),
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _CategoryChip(
                      label: strings.all,
                      selected: selectedCategoryId == null,
                      onTap: () => onCategorySelected(null),
                    ),
                    for (final category in categories)
                      _CategoryChip(
                        label: category.name,
                        selected: selectedCategoryId == category.id,
                        onTap: () => onCategorySelected(category.id),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: isLoading && products.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : products.isEmpty
                          ? Center(child: Text(strings.noProducts))
                          : SingleChildScrollView(
                              child: Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                children: [
                                  for (var i = 0; i < products.length; i++)
                                    _MenuCard(
                                      width: cardWidth,
                                      title: products[i].name,
                                      price: products[i].price,
                                      imageUrl: products[i].imageUrl,
                                      accent: palette[i % palette.length],
                                      onTap: () =>
                                          onProductSelected(products[i]),
                                    ),
                                ],
                              ),
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _KioskDetailPanel extends StatelessWidget {
  const _KioskDetailPanel({
    required this.product,
    required this.currencySymbol,
    required this.symbolOnRight,
    required this.cartCount,
    required this.cartTotal,
    required this.onAdd,
    required this.onCheckout,
    required this.onOrder,
    required this.strings,
  });

  final Product? product;
  final String currencySymbol;
  final bool symbolOnRight;
  final int cartCount;
  final double cartTotal;
  final VoidCallback onAdd;
  final VoidCallback onCheckout;
  final VoidCallback onOrder;
  final _KioskStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasProduct = product != null;
    final priceLabel = hasProduct
        ? _formatCurrency(product!.price, currencySymbol, symbolOnRight)
        : '--';
    final canSubmit = cartCount > 0 || hasProduct;

    return _KioskPanelShell(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shortestSide =
              math.min(constraints.maxWidth, constraints.maxHeight);
          final imageSize =
              (shortestSide * 0.4).clamp(160.0, 220.0).toDouble();
          final iconSize = (imageSize * 0.5).clamp(80.0, 110.0).toDouble();
          final isCompact = constraints.maxWidth < 520;
          final verticalPadding = isCompact ? 14.0 : 16.0;
          final chipPadding = isCompact ? 14.0 : 18.0;
          final panelPadding = EdgeInsets.fromLTRB(
            isCompact ? 18.0 : 24.0,
            isCompact ? 14.0 : 18.0,
            isCompact ? 18.0 : 24.0,
            isCompact ? 18.0 : 24.0,
          );

          return Padding(
            padding: panelPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppNetworkImage(
                  url: product?.imageUrl,
                  width: imageSize,
                  height: imageSize,
                  isCircle: true,
                  backgroundColor: const Color(0xFFFFE0D6),
                  fallbackIcon: Icons.lunch_dining,
                  iconSize: iconSize,
                  iconColor: Colors.black54,
                ),
                const SizedBox(height: 18),
                Text(
                  product?.name ?? strings.selectProduct,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: chipPadding,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    priceLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const Spacer(),
                if (cartCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(strings.cartSummary(cartCount),
                                  style: theme.textTheme.bodyMedium),
                              Text(
                                _formatCurrency(
                                  cartTotal,
                                  currencySymbol,
                                  symbolOnRight,
                                ),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4C62F),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF4C62F),
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: verticalPadding),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: hasProduct ? onAdd : null,
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: Text(
                      strings.addToCart,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: canSubmit ? onOrder : null,
                        icon: const Icon(Icons.receipt_long),
                        label: Text(strings.order),
                        style: OutlinedButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(vertical: verticalPadding),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: canSubmit ? onCheckout : null,
                        icon: const Icon(Icons.payments_outlined),
                        label: Text(strings.checkout),
                        style: FilledButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(vertical: verticalPadding),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF111111) : Colors.white;
    final textColor = selected ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.width,
    required this.title,
    required this.price,
    required this.accent,
    required this.onTap,
    this.imageUrl,
  });

  final double width;
  final String title;
  final double price;
  final Color accent;
  final String? imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageHeight =
        (width * 0.55).clamp(90.0, 130.0).toDouble();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppNetworkImage(
              url: imageUrl,
              width: double.infinity,
              height: imageHeight,
              borderRadius: BorderRadius.circular(16),
              backgroundColor: Colors.white,
              fallbackIcon: Icons.fastfood,
              iconSize: 46,
              iconColor: Colors.black45,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              price.toStringAsFixed(2),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _KioskReceiptPreviewDialog extends StatelessWidget {
  const _KioskReceiptPreviewDialog({
    required this.items,
    required this.currencySymbol,
    required this.currencyOnRight,
    required this.companyName,
    required this.queueNumber,
    required this.total,
    required this.confirmLabel,
  });

  final List<CartItem> items;
  final String currencySymbol;
  final bool currencyOnRight;
  final String companyName;
  final int queueNumber;
  final double total;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    String format(double value) =>
        _formatCurrency(value, currencySymbol, currencyOnRight);
    return AlertDialog(
      title: Text(tr('Prévisualisation ticket')),
      content: SizedBox(
        width: 320,
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
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF5D8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF6D58F)),
                ),
                child: Text(
                  '${tr('Numéro')} $queueNumber',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity} x ${item.product.name}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        format(item.subTotal),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(child: Text(tr('Total'))),
                  Text(
                    format(total),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
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
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
