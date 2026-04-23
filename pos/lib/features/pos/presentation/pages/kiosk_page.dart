import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/translation_controller.dart';
import '../../../../core/models/cart_item.dart';
import '../../../../core/models/product.dart';
import '../../../../core/models/product_category.dart';
import '../../../../core/models/product_option.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../models/printing_service.dart';
import '../../state/pos_controller.dart';
import '../../state/printer_controller.dart';
import 'package:pos_nimirik/core/i18n/i18n.dart';

const Color _kioskYellow = Color(0xFFF7C045);
const Color _kioskYellowSoft = Color(0xFFFFF6DE);
const Color _kioskYellowBorder = Color(0xFFF6D58F);

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

class _KioskStrings {
  const _KioskStrings();

  String get backToPos => tr('Retour POS');
  String get all => tr('All');
  String get noProducts => tr('Aucun produit disponible.');
  String get addRequired => tr('Ajoutez un produit d\'abord.');
}

class KioskPage extends StatefulWidget {
  const KioskPage({super.key});

  @override
  State<KioskPage> createState() => _KioskPageState();
}

class _KioskPageState extends State<KioskPage> {
  final List<CartItem> _cart = [];
  bool _showLanding = true;
  String _serviceMode = 'sur place';
  String _customerName = '';
  bool _isSubmitting = false;

  _KioskStrings get _strings => const _KioskStrings();

  int get _cartCount => _cart.fold<int>(0, (sum, item) => sum + item.quantity);

  double get _cartTotal =>
      _cart.fold<double>(0, (sum, item) => sum + item.subTotal);

  bool _sameOptions(List<ProductOption> a, List<ProductOption> b) {
    if (a.length != b.length) return false;
    final aSorted = [...a]..sort((x, y) => x.id.compareTo(y.id));
    final bSorted = [...b]..sort((x, y) => x.id.compareTo(y.id));
    for (var i = 0; i < aSorted.length; i++) {
      if (aSorted[i].id != bSorted[i].id) return false;
      if ((aSorted[i].quantity - bSorted[i].quantity).abs() > 0.0001) {
        return false;
      }
    }
    return true;
  }

  void _addToCart(Product product, List<ProductOption> options) {
    final index = _cart.indexWhere(
      (item) =>
          item.product.id == product.id && _sameOptions(item.options, options),
    );

    if (index == -1) {
      _cart.add(CartItem(product: product, options: options));
    } else {
      final current = _cart[index];
      _cart[index] = current.copyWith(quantity: current.quantity + 1);
    }
    setState(() {});
  }

  void _updateCartQuantity(CartItem item, int quantity) {
    final index = _cart.indexWhere((entry) => entry.id == item.id);
    if (index == -1) return;
    if (quantity <= 0) {
      _cart.removeAt(index);
    } else {
      _cart[index] = _cart[index].copyWith(quantity: quantity);
    }
    setState(() {});
  }

  void _clearCart() {
    _cart.clear();
    setState(() {});
  }

  Future<void> _showProductDetails(
    Product product,
    PosController pos,
  ) async {
    final selected = await showDialog<List<ProductOption>>(
      context: context,
      builder: (_) => _KioskProductDialog(
        product: product,
        currencySymbol: pos.currencySymbol,
        symbolOnRight: pos.isCurrencySymbolRight,
      ),
    );

    if (!mounted || selected == null) return;
    _addToCart(product, selected);
  }

  Future<void> _showCartSheet(PosController pos) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: _kioskYellowSoft,
      builder: (_) => _KioskCartSheet(
        cartItems: _cart,
        currencySymbol: pos.currencySymbol,
        symbolOnRight: pos.isCurrencySymbolRight,
        onIncreaseItem: (item) => _updateCartQuantity(item, item.quantity + 1),
        onDecreaseItem: (item) => _updateCartQuantity(item, item.quantity - 1),
        onRemoveItem: (item) => _updateCartQuantity(item, 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PosController>(
      builder: (context, pos, _) {
        final i18n = context.watch<TranslationController>();
        final isFrench = i18n.locale.startsWith('fr');

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: _showLanding
                ? _KioskLandingView(
                    isFrench: isFrench,
                    onLanguageChanged: (index) {
                      final locale = index == 1 ? 'fr' : 'en';
                      context.read<TranslationController>().setLocale(locale);
                    },
                    onBack: () => Navigator.of(context).pop(),
                    onSelectServiceMode: (mode) {
                      _startOrderFlow(mode);
                    },
                  )
                : _KioskOrderView(
                    pos: pos,
                    strings: _strings,
                    serviceMode: _serviceMode,
                    customerName: _customerName,
                    cartCount: _cartCount,
                    cartTotal: _cartTotal,
                    cartItems: _cart,
                    onBack: () => setState(() => _showLanding = true),
                    onCategorySelected: (categoryId) async {
                      await pos.selectCategory(categoryId);
                    },
                    onProductSelected: (product) =>
                        _showProductDetails(product, pos),
                    onOpenCart: () => _showCartSheet(pos),
                    onSubmit: () async {
                      if (_isSubmitting) return;
                      setState(() => _isSubmitting = true);
                      await _handleSubmit(pos);
                      if (mounted) {
                        setState(() => _isSubmitting = false);
                      }
                    },
                    isSubmitting: _isSubmitting,
                  ),
          ),
        );
      },
    );
  }

  Future<void> _startOrderFlow(String mode) async {
    final entered = await showDialog<String>(
      context: context,
      builder: (_) => _KioskCustomerDialog(
        mode: mode,
      ),
    );
    if (!mounted || entered == null) return;
    setState(() {
      _serviceMode = mode;
      _customerName = entered.trim();
      _showLanding = false;
    });
  }

  Future<void> _handleSubmit(PosController pos) async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.addRequired)),
      );
      return;
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
        confirmLabel: tr('Commander'),
        serviceMode: _serviceMode,
        customerName: _customerName,
      ),
    );
    if (confirmed != true) return;

    var loaderOpened = false;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(tr('Envoi de la commande...'))),
          ],
        ),
      ),
    );
    loaderOpened = true;

    final ok = await pos.submitKioskOrder(
      items: List<CartItem>.from(_cart),
      queueNumber: queueNumber,
      serviceMode: _serviceMode,
      customerName: _customerName,
      receivedAmount: 0,
      paymentTypeId: 0,
      saleStatus: 'pos',
    );
    if (loaderOpened && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      loaderOpened = false;
    }
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
    final kioskTargets = resolved
        .where((service) => service.template.trim().toLowerCase() == 'kiosk')
        .toList();
    printer.syncServices(resolved);
    for (final service in kioskTargets) {
      await printer.printKioskQueueTicket(
        queueNumber: queueNumber,
        companyName: pos.companyName,
        serviceId: service.id,
      );
    }
    if (!mounted) return;

    _clearCart();
    setState(() {
      _showLanding = true;
      _customerName = '';
    });

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
              tr('Votre commande a été envoyée vers le POS.'),
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
            const SizedBox(height: 8),
            Text(
              '${tr('Client')}: ${_customerName.trim().isEmpty ? tr('N/A') : _customerName}',
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

class _KioskLandingView extends StatelessWidget {
  const _KioskLandingView({
    required this.isFrench,
    required this.onLanguageChanged,
    required this.onBack,
    required this.onSelectServiceMode,
  });

  final bool isFrench;
  final ValueChanged<int> onLanguageChanged;
  final VoidCallback onBack;
  final ValueChanged<String> onSelectServiceMode;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    Widget actionCard({
      required IconData icon,
      required String label,
      required String mode,
    }) {
      return Expanded(
        child: FilledButton(
          onPressed: () => onSelectServiceMode(mode),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            backgroundColor: _kioskYellowSoft,
            foregroundColor: const Color(0xFF101828),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 56),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'flutter_02.png',
          fit: BoxFit.cover,
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xAA000000), Color(0xCC000000)],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Spacer(),
                  ToggleButtons(
                    isSelected: [!isFrench, isFrench],
                    onPressed: onLanguageChanged,
                    borderRadius: BorderRadius.circular(12),
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 36,
                    ),
                    color: Colors.white,
                    selectedColor: const Color(0xFF101828),
                    fillColor: Colors.white,
                    children: [
                      Text(tr('EN')),
                      Text(tr('FR')),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Text(
                tr('Comment souhaitez-vous retirer votre commande ?'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: isLandscape ? 230 : 280,
                child: isLandscape
                    ? Row(
                        children: [
                          actionCard(
                            icon: Icons.storefront_outlined,
                            label: tr('Sur place'),
                            mode: 'sur place',
                          ),
                          const SizedBox(width: 16),
                          actionCard(
                            icon: Icons.shopping_bag_outlined,
                            label: tr('Emporter'),
                            mode: 'emporter',
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          actionCard(
                            icon: Icons.storefront_outlined,
                            label: tr('Sur place'),
                            mode: 'sur place',
                          ),
                          const SizedBox(height: 12),
                          actionCard(
                            icon: Icons.shopping_bag_outlined,
                            label: tr('Emporter'),
                            mode: 'emporter',
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: _HoverBackButton(
            label: tr('Retour POS'),
            onPressed: onBack,
          ),
        ),
      ],
    );
  }
}

class _KioskCustomerDialog extends StatefulWidget {
  const _KioskCustomerDialog({required this.mode});

  final String mode;

  @override
  State<_KioskCustomerDialog> createState() => _KioskCustomerDialogState();
}

class _KioskCustomerDialogState extends State<_KioskCustomerDialog> {
  final TextEditingController _nameController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _submitted = true);
    final value = _nameController.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final modeLabel =
        widget.mode == 'emporter' ? tr('Emporter') : tr('Sur place');
    return AlertDialog(
      title: Text(tr('Votre nom')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${tr('Service')}: $modeLabel'),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: tr('Nom client'),
              hintText: tr('Ex: Ahmed'),
              errorText: _submitted && _nameController.text.trim().isEmpty
                  ? tr('Nom requis')
                  : null,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('Annuler')),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(tr('Continuer')),
        ),
      ],
    );
  }
}

class _KioskOrderView extends StatelessWidget {
  const _KioskOrderView({
    required this.pos,
    required this.strings,
    required this.serviceMode,
    required this.customerName,
    required this.cartCount,
    required this.cartTotal,
    required this.cartItems,
    required this.onBack,
    required this.onCategorySelected,
    required this.onProductSelected,
    required this.onOpenCart,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final PosController pos;
  final _KioskStrings strings;
  final String serviceMode;
  final String customerName;
  final int cartCount;
  final double cartTotal;
  final List<CartItem> cartItems;
  final VoidCallback onBack;
  final ValueChanged<int?> onCategorySelected;
  final ValueChanged<Product> onProductSelected;
  final VoidCallback onOpenCart;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final categories = pos.categories;
    final products = pos.products;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(serviceMode == 'emporter'
                      ? tr('Emporter')
                      : tr('Sur place')),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(
                    '${tr('Client')}: ${customerName.trim().isEmpty ? tr('N/A') : customerName}',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 176,
                      child: _CategorySidebar(
                        categories: categories,
                        selectedCategoryId: pos.selectedCategoryId,
                        allLabel: strings.all,
                        onCategorySelected: onCategorySelected,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ProductGrid3(
                        products: products,
                        isLoading: pos.isLoading,
                        noProductsLabel: strings.noProducts,
                        onSelectProduct: onProductSelected,
                        currencySymbol: pos.currencySymbol,
                        symbolOnRight: pos.isCurrencySymbolRight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _KioskFooterBar(
                cartCount: cartCount,
                cartTotal: cartTotal,
                cartItems: cartItems,
                currencySymbol: pos.currencySymbol,
                symbolOnRight: pos.isCurrencySymbolRight,
                onOpenCart: onOpenCart,
                onSubmit: onSubmit,
                isSubmitting: isSubmitting,
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: _HoverBackButton(
            label: tr('Retour'),
            onPressed: onBack,
          ),
        ),
      ],
    );
  }
}

class _HoverBackButton extends StatefulWidget {
  const _HoverBackButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  State<_HoverBackButton> createState() => _HoverBackButtonState();
}

class _HoverBackButtonState extends State<_HoverBackButton> {
  bool _hovering = false;
  bool get _supportsHover =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  @override
  Widget build(BuildContext context) {
    if (!_supportsHover) {
      return OutlinedButton.icon(
        onPressed: widget.onPressed,
        icon: const Icon(Icons.arrow_back),
        label: Text(widget.label),
        style: OutlinedButton.styleFrom(
          backgroundColor: _kioskYellowSoft,
          foregroundColor: const Color(0xFF1F2937),
          side: const BorderSide(color: _kioskYellowBorder),
        ),
      );
    }
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: _hovering ? 1 : 0,
        child: IgnorePointer(
          ignoring: !_hovering,
          child: OutlinedButton.icon(
            onPressed: widget.onPressed,
            icon: const Icon(Icons.arrow_back),
            label: Text(widget.label),
            style: OutlinedButton.styleFrom(
              backgroundColor: _kioskYellowSoft,
              foregroundColor: const Color(0xFF1F2937),
              side: const BorderSide(color: _kioskYellowBorder),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySidebar extends StatelessWidget {
  const _CategorySidebar({
    required this.categories,
    required this.selectedCategoryId,
    required this.allLabel,
    required this.onCategorySelected,
  });

  final List<ProductCategory> categories;
  final int? selectedCategoryId;
  final String allLabel;
  final ValueChanged<int?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kioskYellowSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kioskYellowBorder),
      ),
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          _CategoryTile(
            label: allLabel,
            selected: selectedCategoryId == null,
            onTap: () => onCategorySelected(null),
          ),
          for (final category in categories)
            _CategoryTile(
              label: category.name,
              selected: selectedCategoryId == category.id,
              onTap: () => onCategorySelected(category.id),
            ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? _kioskYellow : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? _kioskYellow : const Color(0xFFE5E7EB),
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
                maxLines: 2,
                textAlign: TextAlign.center,
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
      ),
    );
  }
}

class _ProductGrid3 extends StatelessWidget {
  const _ProductGrid3({
    required this.products,
    required this.isLoading,
    required this.noProductsLabel,
    required this.onSelectProduct,
    required this.currencySymbol,
    required this.symbolOnRight,
  });

  final List<Product> products;
  final bool isLoading;
  final String noProductsLabel;
  final ValueChanged<Product> onSelectProduct;
  final String currencySymbol;
  final bool symbolOnRight;

  @override
  Widget build(BuildContext context) {
    if (isLoading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (products.isEmpty) {
      return Center(child: Text(noProductsLabel));
    }

    return GridView.builder(
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.84,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return InkWell(
          onTap: () => onSelectProduct(product),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppNetworkImage(
                    url: product.imageUrl,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(12),
                    backgroundColor: const Color(0xFFF3F4F6),
                    fallbackIcon: Icons.fastfood,
                    iconSize: 40,
                    iconColor: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(product.price, currencySymbol, symbolOnRight),
                  style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.w700,
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

class _KioskFooterBar extends StatelessWidget {
  const _KioskFooterBar({
    required this.cartCount,
    required this.cartTotal,
    required this.cartItems,
    required this.currencySymbol,
    required this.symbolOnRight,
    required this.onOpenCart,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final int cartCount;
  final double cartTotal;
  final List<CartItem> cartItems;
  final String currencySymbol;
  final bool symbolOnRight;
  final VoidCallback onOpenCart;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _kioskYellowSoft,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${tr('Panier')}: $cartCount • ${_formatCurrency(cartTotal, currencySymbol, symbolOnRight)}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: cartItems.isEmpty || isSubmitting ? null : onOpenCart,
            icon: const Icon(Icons.shopping_cart_outlined),
            label: Text(tr('Voir panier')),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: cartItems.isEmpty || isSubmitting ? null : onSubmit,
            icon: isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                    ),
                  )
                : const Icon(Icons.receipt_long),
            label: Text(isSubmitting ? tr('Envoi...') : tr('Commander')),
            style: FilledButton.styleFrom(
              backgroundColor: _kioskYellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _KioskProductDialog extends StatefulWidget {
  const _KioskProductDialog({
    required this.product,
    required this.currencySymbol,
    required this.symbolOnRight,
  });

  final Product product;
  final String currencySymbol;
  final bool symbolOnRight;

  @override
  State<_KioskProductDialog> createState() => _KioskProductDialogState();
}

class _KioskProductDialogState extends State<_KioskProductDialog> {
  late final List<_OptionChoice> _choices;

  @override
  void initState() {
    super.initState();
    _choices = widget.product.options
        .map((option) => _OptionChoice(
              option: option,
              enabled: option.quantity > 0,
              quantity: option.quantity > 0 ? option.quantity : 0,
              step: option.quantity >= 1 ? 0.5 : 0.1,
            ))
        .toList();
  }

  double _roundQty(double value) => (value * 100).round() / 100;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppNetworkImage(
              url: widget.product.imageUrl,
              width: double.infinity,
              height: 180,
              borderRadius: BorderRadius.circular(14),
              backgroundColor: _kioskYellowSoft,
              fallbackIcon: Icons.fastfood,
              iconSize: 54,
              iconColor: const Color(0xFF6B7280),
            ),
            const SizedBox(height: 10),
            Text(
              _formatCurrency(
                widget.product.price,
                widget.currencySymbol,
                widget.symbolOnRight,
              ),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (_choices.isNotEmpty) ...[
              Text(
                tr('Options'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  itemCount: _choices.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final choice = _choices[index];
                    return Row(
                      children: [
                        Switch(
                          value: choice.enabled,
                          onChanged: (enabled) {
                            setState(() {
                              choice.enabled = enabled;
                              if (!enabled) {
                                choice.quantity = 0;
                              } else if (choice.quantity <= 0) {
                                choice.quantity = _roundQty(choice.step);
                              }
                            });
                          },
                        ),
                        Expanded(child: Text(choice.option.name)),
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
                          width: 52,
                          child: Text(
                            _formatQty(choice.quantity),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w700),
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
                              } else {
                                choice.quantity =
                                    _roundQty(choice.quantity + choice.step);
                              }
                            });
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ] else
              Text(tr('Aucune option disponible.')),
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
              if (choice.enabled && choice.quantity > 0) {
                selected.add(choice.option.copyWith(quantity: choice.quantity));
              }
            }
            Navigator.of(context).pop(selected);
          },
          child: Text(tr('Ajouter au panier')),
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

class _KioskCartSheet extends StatelessWidget {
  const _KioskCartSheet({
    required this.cartItems,
    required this.currencySymbol,
    required this.symbolOnRight,
    required this.onIncreaseItem,
    required this.onDecreaseItem,
    required this.onRemoveItem,
  });

  final List<CartItem> cartItems;
  final String currencySymbol;
  final bool symbolOnRight;
  final ValueChanged<CartItem> onIncreaseItem;
  final ValueChanged<CartItem> onDecreaseItem;
  final ValueChanged<CartItem> onRemoveItem;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('Panier'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: cartItems.isEmpty
                  ? Center(child: Text(tr('Votre panier est vide')))
                  : ListView.separated(
                      itemCount: cartItems.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        final optionsLabel = item.options.map((option) {
                          final qty = option.quantity;
                          final qtyText = qty == qty.roundToDouble()
                              ? qty.toStringAsFixed(0)
                              : qty.toString();
                          return qty <= 1
                              ? option.name
                              : '${option.name} x$qtyText';
                        }).join(', ');

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _kioskYellowBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(
                                      item.subTotal,
                                      currencySymbol,
                                      symbolOnRight,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              if (optionsLabel.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    optionsLabel,
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => onDecreaseItem(item),
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700),
                                  ),
                                  IconButton(
                                    onPressed: () => onIncreaseItem(item),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                  const Spacer(),
                                  TextButton.icon(
                                    onPressed: () => onRemoveItem(item),
                                    icon: const Icon(Icons.delete_outline),
                                    label: Text(tr('Supprimer')),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
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
    required this.serviceMode,
    required this.customerName,
  });

  final List<CartItem> items;
  final String currencySymbol;
  final bool currencyOnRight;
  final String companyName;
  final int queueNumber;
  final double total;
  final String confirmLabel;
  final String serviceMode;
  final String customerName;

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
                  Expanded(child: Text(tr('Service'))),
                  Text(
                    serviceMode == 'emporter'
                        ? tr('Emporter')
                        : tr('Sur place'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text(tr('Client'))),
                  Text(
                    customerName.trim().isEmpty ? tr('N/A') : customerName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
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
