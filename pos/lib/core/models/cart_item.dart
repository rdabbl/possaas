import 'product.dart';
import 'product_ingredient.dart';

class CartItem {
  CartItem({
    String? id,
    required this.product,
    this.quantity = 1,
    this.discount = 0,
    List<ProductIngredient>? ingredients,
  })  : id = id ?? _generateId(),
        ingredients = List.unmodifiable(ingredients ?? const []);

  final String id;
  final Product product;
  final int quantity;
  final double discount;
  final List<ProductIngredient> ingredients;

  double get subTotal => product.price * quantity;

  CartItem copyWith({
    int? quantity,
    double? discount,
    List<ProductIngredient>? ingredients,
  }) {
    return CartItem(
      id: id,
      product: product,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
      ingredients: ingredients ?? this.ingredients,
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
      if (ingredients.isNotEmpty)
        'ingredients': ingredients
            .map((ingredient) => {
                  'id': ingredient.id,
                  'name': ingredient.name,
                  'quantity': ingredient.quantity,
                })
            .toList(),
    };
  }

  static String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}
