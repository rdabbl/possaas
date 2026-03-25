class ProductOption {
  const ProductOption({
    required this.id,
    required this.name,
    required this.quantity,
  });

  final int id;
  final String name;
  final double quantity;

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    double _parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    final pivot = json['pivot'] is Map ? json['pivot'] as Map : null;
    final qty = pivot?['quantity'] ?? json['quantity'] ?? json['qty'];
    return ProductOption(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      quantity: _parseDouble(qty),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pivot': {'quantity': quantity},
    };
  }

  ProductOption copyWith({double? quantity}) {
    return ProductOption(
      id: id,
      name: name,
      quantity: quantity ?? this.quantity,
    );
  }
}
