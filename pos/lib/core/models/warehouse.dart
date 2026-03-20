class Warehouse {
  Warehouse({
    required this.id,
    required this.name,
    this.currencyId,
    this.currencySymbol,
    this.isCurrencySymbolRight,
  });

  final int id;
  final String name;
  final int? currencyId;
  final String? currencySymbol;
  final bool? isCurrencySymbolRight;

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>?;
    final label = attributes?['name']?.toString() ?? json['name']?.toString();
    final currency = json['currency'] is Map<String, dynamic>
        ? json['currency'] as Map<String, dynamic>
        : null;
    final currencyId = attributes?['currency_id'] ?? json['currency_id'] ?? currency?['id'];
    final currencySymbol = attributes?['currency_symbol'] ??
        json['currency_symbol'] ??
        currency?['symbol'];
    final currencyRight = attributes?['is_currency_right'] ?? json['is_currency_right'];
    return Warehouse(
      id: json['id'] is int ? json['id'] as int : int.parse('${json['id']}'),
      name: label ?? 'Magasin',
      currencyId: currencyId == null ? null : int.tryParse('$currencyId'),
      currencySymbol: currencySymbol?.toString(),
      isCurrencySymbolRight: _parseBool(currencyRight),
    );
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }
}
