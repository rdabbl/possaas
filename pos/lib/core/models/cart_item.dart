import 'product.dart';
import 'product_option.dart';

class CartItem {
  CartItem({
    String? id,
    required this.product,
    this.quantity = 1,
    this.discount = 0,
    List<ProductOption>? options,
  })  : id = id ?? _generateId(),
        options = List.unmodifiable(options ?? const []);

  final String id;
  final Product product;
  final int quantity;
  final double discount;
  final List<ProductOption> options;

  double get subTotal => product.price * quantity;

  CartItem copyWith({
    int? quantity,
    double? discount,
    List<ProductOption>? options,
  }) {
    return CartItem(
      id: id,
      product: product,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
      options: options ?? this.options,
    );
  }

  Map<String, dynamic> toSalePayload({
    double discountAmount = 0,
    double taxAmount = 0,
  }) {
    return {
      'product_id': product.id,
      'name': product.name,
      'sku': product.code,
      'quantity': quantity,
      'unit_price': product.price,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      if (options.isNotEmpty)
        'options': options
            .map((option) => {
                  'id': option.id,
                  'name': option.name,
                  'quantity': option.quantity,
                })
            .toList(),
    };
  }

  static String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}
