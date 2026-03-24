import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/product.dart';
import '../../../../core/models/product_category.dart';
import '../../../../core/i18n/translation_controller.dart';
import '../../state/pos_controller.dart';
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

  String get backToPos => tr('Back to POS');
  String get kioskMenu => tr('Kiosk Menu');
  String get all => tr('All');
  String get noProducts => tr('No products available.');
  String get selectProduct => tr('Select a product');
  String get extras => tr('Extras');
  String get notes => tr('Notes');
  String cartSummary(int count) {
    return '${tr('Cart')}: $count ${tr('item(s)')}';
  }

  String get addToCart => tr('Add to cart');
  String get checkout => tr('Checkout');
  String get order => tr('Place order');
  String get addRequired => tr('Add a product first.');
}

class KioskPage extends StatefulWidget {
  const KioskPage({super.key});

  @override
  State<KioskPage> createState() => _KioskPageState();
}

class _KioskPageState extends State<KioskPage> {
  Product? _selectedProduct;
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
                final panelSpacing = isWide ? 28.0 : 20.0;
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
                              cartCount: pos.totalQuantity,
                              cartTotal: pos.grandTotal,
                              strings: strings,
                              onAdd: () {
                                final selected = selectedProduct;
                                if (selected != null) {
                                  pos.addProduct(selected);
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
                            cartCount: pos.totalQuantity,
                            cartTotal: pos.grandTotal,
                            strings: strings,
                            onAdd: () {
                              final selected = selectedProduct;
                              if (selected != null) {
                                pos.addProduct(selected);
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
                  padding: const EdgeInsets.all(20),
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
    if (pos.cartItems.isEmpty && selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.addRequired)),
      );
      return;
    }

    if (pos.cartItems.isEmpty && selected != null) {
      pos.addProduct(selected);
    }

    await pos.checkout(
      paymentTypeId: 1,
      paymentStatusId: markUnpaid ? 2 : 1,
    );
    if (!mounted) return;
    final message = pos.errorMessage ?? pos.successMessage;
    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      pos.clearMessages();
    }
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
    final theme = Theme.of(context);
    final palette = <Color>[
      const Color(0xFFFFE8A3),
      const Color(0xFFFFE0D6),
      const Color(0xFFE8F3FF),
      const Color(0xFFFFF0C9),
      const Color(0xFFE9E3FF),
      const Color(0xFFDDF7E3),
    ];

    return _KioskPanelShell(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                const SizedBox(width: 12),
                Text(
                  strings.kioskMenu,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
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
                            spacing: 14,
                            runSpacing: 14,
                            children: [
                              for (var i = 0; i < products.length; i++)
                                _MenuCard(
                                  title: products[i].name,
                                  price: products[i].price,
                                  imageUrl: products[i].imageUrl,
                                  accent: palette[i % palette.length],
                                  onTap: () => onProductSelected(products[i]),
                                ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE0D6),
                shape: BoxShape.circle,
                image: product?.imageUrl == null
                    ? null
                    : DecorationImage(
                        image: NetworkImage(product!.imageUrl!),
                        fit: BoxFit.cover,
                      ),
              ),
              child: product?.imageUrl == null
                  ? const Icon(Icons.lunch_dining, size: 110)
                  : null,
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                priceLabel,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 18),
            _OptionButton(
              label: strings.extras,
              icon: Icons.add,
              onTap: hasProduct ? () {} : null,
            ),
            const SizedBox(height: 12),
            _OptionButton(
              label: strings.notes,
              icon: Icons.edit,
              onTap: hasProduct ? () {} : null,
            ),
            const Spacer(),
            if (cartCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(strings.cartSummary(cartCount),
                        style: theme.textTheme.bodyMedium),
                    Text(
                      _formatCurrency(cartTotal, currencySymbol, symbolOnRight),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
    required this.title,
    required this.price,
    required this.accent,
    required this.onTap,
    this.imageUrl,
  });

  final String title;
  final double price;
  final Color accent;
  final String? imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                image: imageUrl == null
                    ? null
                    : DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      ),
              ),
              child: imageUrl == null
                  ? const Icon(Icons.fastfood, size: 46, color: Colors.black45)
                  : null,
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
