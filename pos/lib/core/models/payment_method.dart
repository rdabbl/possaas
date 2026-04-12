class PaymentMethod {
  PaymentMethod({
    required this.id,
    required this.name,
    this.type,
    this.isDefault = false,
    this.isActive = true,
  });

  final int id;
  final String name;
  final String? type;
  final bool isDefault;
  final bool isActive;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    final id = json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0;
    final name = json['name']?.toString() ?? '';
    final type = json['type']?.toString();
    final isDefault = json['is_default'] == true || json['is_default'] == 1;
    final isActive = json['is_active'] == null
        ? true
        : (json['is_active'] == true || json['is_active'] == 1);
    return PaymentMethod(
      id: id,
      name: name.isNotEmpty ? name : 'Cash',
      type: type,
      isDefault: isDefault,
      isActive: isActive,
    );
  }

  static PaymentMethod fallback() {
    return PaymentMethod(
      id: 0,
      name: 'Cash',
      type: 'cash',
      isDefault: true,
      isActive: true,
    );
  }
}
