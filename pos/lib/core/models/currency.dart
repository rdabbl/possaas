class Currency {
  const Currency({
    required this.id,
    required this.name,
    required this.code,
    required this.symbol,
  });

  final int id;
  final String name;
  final String code;
  final String symbol;

  factory Currency.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final attributes = Map<String, dynamic>.from(json['attributes'] ?? json);
    return Currency(
      id: int.tryParse('$rawId') ?? 0,
      name: attributes['name']?.toString() ?? '',
      code: attributes['code']?.toString() ?? '',
      symbol: attributes['symbol']?.toString() ?? '',
    );
  }
}
