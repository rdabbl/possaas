import '../utils/media_url.dart';
import 'product_option.dart';

class Product {
  Product({
    required this.id,
    required this.name,
    required this.code,
    required this.price,
    required this.cost,
    required this.stockQuantity,
    required this.taxValue,
    this.taxType,
    this.productUnitId,
    this.saleUnitId,
    this.stockAlert,
    this.unitLabel,
    this.imageUrl,
    this.variationName,
    this.variationTypeName,
    this.categoryId,
    this.options = const [],
  });

  final int id;
  final String name;
  final String code;
  final double price;
  final double cost;
  final double stockQuantity;
  final double taxValue;
  final int? taxType;
  final int? productUnitId;
  final int? saleUnitId;
  final double? stockAlert;
  final String? unitLabel;
  final String? imageUrl;
  final String? variationName;
  final String? variationTypeName;
  final int? categoryId;
  final List<ProductOption> options;

  factory Product.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    final rawAttributes = json['attributes'];
    final attributes = rawAttributes is Map<String, dynamic>
        ? rawAttributes
        : Map<String, dynamic>.from(json);
    final stock = attributes['stock'] is Map
        ? Map<String, dynamic>.from(attributes['stock'] as Map)
        : null;
    final images = attributes['images'] is Map
        ? Map<String, dynamic>.from(attributes['images'] as Map)
        : null;
    final variationProduct = attributes['variation_product'] is Map
        ? Map<String, dynamic>.from(attributes['variation_product'] as Map)
        : null;
    final optionsRaw = attributes['option_links'] ??
        attributes['optionLinks'] ??
        json['option_links'] ??
        json['optionLinks'] ??
        attributes['ingredient_links'] ??
        attributes['ingredientLinks'] ??
        json['ingredient_links'] ??
        json['ingredientLinks'];
    final unitName = attributes['product_unit_name'];
    final taxTypeRaw = attributes['tax_type'];
    int? taxType;
    if (taxTypeRaw is Map && taxTypeRaw['value'] != null) {
      taxType = parseInt(taxTypeRaw['value']);
    } else {
      taxType = parseInt(taxTypeRaw);
    }
    final imageUrls = images?['imageUrls'];
    String? imageUrl;
    if (imageUrls is List && imageUrls.isNotEmpty) {
      imageUrl = imageUrls.first.toString();
    } else {
      imageUrl = attributes['image_url']?.toString() ??
          attributes['image_path']?.toString();
    }
    imageUrl = normalizeMediaUrl(imageUrl);

    final stockQuantityRaw =
        attributes['stock_quantity'] ?? json['stock_quantity'];
    double stockQuantity;
    if (stockQuantityRaw == null) {
      stockQuantity = stock != null && stock.containsKey('quantity')
          ? parseDouble(stock?['quantity'])
          : -1;
    } else {
      stockQuantity = parseDouble(stockQuantityRaw);
    }
    if (stockQuantity < 0 && stockQuantityRaw != null) {
      stockQuantity = 0;
    }

    return Product(
      id: json['id'] is int ? json['id'] as int : int.parse('${json['id']}'),
      name: attributes['name']?.toString() ??
          json['name']?.toString() ??
          'Unnamed',
      code: attributes['sku']?.toString() ??
          attributes['code']?.toString() ??
          json['sku']?.toString() ??
          json['code']?.toString() ??
          json['barcode']?.toString() ??
          '',
      price: parseDouble(
        attributes['product_price'] ?? json['price'],
      ),
      cost: parseDouble(attributes['product_cost'] ?? json['cost']),
      stockQuantity: stockQuantity,
      taxValue: parseDouble(attributes['order_tax'] ?? 0),
      taxType: taxType,
      productUnitId: parseInt(attributes['product_unit']),
      saleUnitId: parseInt(attributes['sale_unit']),
      stockAlert: attributes['stock_alert'] == null
          ? null
          : parseDouble(attributes['stock_alert']),
      unitLabel: unitName is Map
          ? unitName['name']?.toString()
          : unitName?.toString(),
      imageUrl: imageUrl,
      variationName: variationProduct?['variation_name']?.toString(),
      variationTypeName: variationProduct?['variation_type_name']?.toString(),
      categoryId: parseInt(attributes['category_id'] ?? json['category_id']),
      options: optionsRaw is List
          ? optionsRaw
              .whereType<Map>()
              .map((e) => ProductOption.fromJson(e.cast<String, dynamic>()))
              .where((o) => o.id > 0 && o.name.trim().isNotEmpty)
              .toList()
          : const [],
    );
  }
}
