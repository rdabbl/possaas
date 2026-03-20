class Brand {
  Brand({required this.id, required this.name});

  final int id;
  final String name;

  factory Brand.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>?;
    final label = attributes?['name']?.toString() ?? json['name']?.toString();
    return Brand(
      id: json['id'] is int ? json['id'] as int : int.parse('${json['id']}'),
      name: label ?? 'Brand',
    );
  }
}
