class ShippingMethod {
  ShippingMethod({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.isActive,
  });

  final int id;
  final String name;
  final String type;
  final double value;
  final bool isActive;

  bool get isFree => type == 'free';
  bool get isManual => type == 'manual';
  bool get isOrderPercent => type == 'order_percent';
  bool get isPerItem => type == 'per_item';

  factory ShippingMethod.fromJson(Map<String, dynamic> json) {
    return ShippingMethod(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? 'Shipping',
      type: json['type']?.toString() ?? 'manual',
      value: _parseDouble(json['value']),
      isActive: _parseBool(json['is_active'] ?? json['isActive']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }
}
