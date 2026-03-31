class Customer {
  Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.loyaltyPoints = 0,
  });

  final int id;
  final String name;
  final String? email;
  final String? phone;
  final int loyaltyPoints;

  factory Customer.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>?;
    return Customer(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: attributes?['name']?.toString() ??
          json['name']?.toString() ??
          json['customer_name']?.toString() ??
          'Client',
      email: attributes?['email']?.toString() ?? json['email']?.toString(),
      phone: attributes?['phone']?.toString() ?? json['phone']?.toString(),
      loyaltyPoints: _parseInt(
        attributes?['loyalty_points_balance'] ?? json['loyalty_points_balance'],
      ),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}
