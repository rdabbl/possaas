class Discount {
  Discount({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.scope,
    required this.isActive,
  });

  final int id;
  final String name;
  final String type; // percent | fixed
  final double value;
  final String scope; // order | item
  final bool isActive;

  bool get isPercent => type == 'percent';
  bool get isFixed => type == 'fixed';

  factory Discount.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return Discount(
      id: data['id'] is int ? data['id'] as int : int.tryParse('${data['id']}') ?? 0,
      name: data['name']?.toString() ?? 'Discount',
      type: data['type']?.toString() ?? 'percent',
      value: _parseDouble(data['value']),
      scope: data['scope']?.toString() ?? 'order',
      isActive: _parseBool(data['is_active'] ?? data['isActive']),
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
