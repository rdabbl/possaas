import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../../../core/models/product.dart';
import '../../../../core/models/product_category.dart';
import '../../state/appearance_controller.dart';
import '../../../../core/widgets/app_network_image.dart';
import 'package:pos_nimirik/core/i18n/i18n.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
    required this.categories,
    required this.isLoading,
    required this.onRefresh,
    required this.onAdd,
    required this.currencySymbol,
    required this.currencySymbolRight,
    this.customColumns,
  });

  final List<Product> products;
  final List<ProductCategory> categories;
  final bool isLoading;
  final VoidCallback onRefresh;
  final void Function(Product product) onAdd;
  final String currencySymbol;
  final bool currencySymbolRight;
  final int? customColumns;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final appearance = context.watch<AppearanceController>();
    final showAddToCart = appearance.showAddToCartButton;
    final showStock = appearance.showStockInfo;
    final categoryMap = {
      for (final category in categories) category.id: category.name,
    };

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Aucun produit à afficher.\nVérifiez vos filtres ou rechargez.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: Text(tr('Actualiser')),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (customColumns != null && customColumns! > 0) {
          crossAxisCount = customColumns!;
        } else {
          final desiredColumns = (constraints.maxWidth / 230).floor();
          crossAxisCount = desiredColumns <= 0
              ? 1
              : desiredColumns > 4
                  ? 4
                  : desiredColumns;
        }
        if (crossAxisCount < 1) {
          crossAxisCount = 1;
        } else if (crossAxisCount > 5) {
          crossAxisCount = 5;
        }
        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.9,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _ProductCard(
              product: product,
              categoryName: categoryMap[product.categoryId] ?? '',
              currencySymbol: currencySymbol,
              currencySymbolRight: currencySymbolRight,
              onTap: () => onAdd(product),
              showAddToCart: showAddToCart,
            );
          },
        );
      },
    );
  }
}

class _ProductCard extends StatefulWidget {
  const _ProductCard({
    required this.product,
    required this.categoryName,
    required this.currencySymbol,
    required this.currencySymbolRight,
    required this.onTap,
    required this.showAddToCart,
  });

  final Product product;
  final String categoryName;
  final String currencySymbol;
  final bool currencySymbolRight;
  final VoidCallback onTap;
  final bool showAddToCart;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isPressed = false;

  void _playClick(BuildContext context) {
    SystemSound.play(SystemSoundType.alert); // louder, more noticeable ping
    Feedback.forTap(context);
  }

  void _handleTap(BuildContext context) {
    _playClick(context);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final appearance = context.watch<AppearanceController>();
    final showStock = appearance.showStockInfo;
    const accent = Color(0xFFF7C045);
    final borderRadius = BorderRadius.circular(22);
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _isPressed ? 0.98 : 1.0,
      child: Material(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: const BorderSide(
            color: Color(0xFFF7C045),
            width: 2.2,
          ),
        ),
        shadowColor: Colors.black12,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () => _handleTap(context),
          onTapDown: (_) => _playClick(context),
          onHighlightChanged: (isDown) => setState(() => _isPressed = isDown),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppNetworkImage(
                  url: widget.product.imageUrl,
                  width: 88,
                  height: 88,
                  isCircle: true,
                  backgroundColor: const Color(0xFFF3F4F6),
                  fallbackIcon: Icons.restaurant_menu,
                  iconSize: 32,
                  iconColor: Colors.black54,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.product.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.categoryName.isNotEmpty
                      ? widget.categoryName
                      : (widget.product.unitLabel?.isNotEmpty == true
                          ? widget.product.unitLabel!
                          : tr('Catégorie')),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                if (showStock) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.product.stockQuantity == -1
                        ? 'Stock: ∞'
                        : 'Stock: ${widget.product.stockQuantity.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          _formatProductAmount(
                            widget.product.price,
                            widget.currencySymbol,
                            widget.currencySymbolRight,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                    ),
                    if (widget.showAddToCart)
                      InkWell(
                        onTap: () => _handleTap(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
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

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.text,
    required this.color,
    required this.textColor,
    this.textStyle,
  });

  final String text;
  final Color color;
  final Color textColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: textStyle ??
            Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}

String _formatProductAmount(
  double value,
  String symbol,
  bool symbolOnRight,
) {
  final formatted = value.toStringAsFixed(2);
  final trimmedSymbol = symbol.trim();
  if (trimmedSymbol.isEmpty) {
    return formatted;
  }
  return symbolOnRight ? '$formatted $trimmedSymbol' : '$trimmedSymbol $formatted';
}

String _formatVariationLabel(String? variationName, String? variationTypeName) {
  final name = variationName?.trim() ?? '';
  final type = variationTypeName?.trim() ?? '';
  if (name.isNotEmpty && type.isNotEmpty) {
    return '$name: $type';
  }
  if (type.isNotEmpty) return type;
  return name;
}
