class PrintingService {
  PrintingService({
    required this.id,
    required this.storeId,
    required this.name,
    required this.type,
    required this.template,
    required this.isActive,
    required this.sortOrder,
  });

  final int id;
  final int storeId;
  final String name;
  final String type;
  final String template;
  final bool isActive;
  final int sortOrder;

  factory PrintingService.fromJson(Map<String, dynamic> json) {
    return PrintingService(
      id: _intFrom(json['id']) ?? 0,
      storeId: _intFrom(json['store_id']) ?? 0,
      name: (json['name'] ?? '').toString().trim(),
      type: (json['type'] ?? '').toString().trim(),
      template: (json['template'] ?? 'receipt').toString().trim(),
      isActive: _boolFrom(json['is_active']) ?? true,
      sortOrder: _intFrom(json['sort_order']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'type': type,
      'template': template,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }

  bool get isReceipt => template.toLowerCase() == 'receipt';
  bool get isKitchen => template.toLowerCase() == 'kitchen';
  bool get isKiosk => template.toLowerCase() == 'kiosk';

  String get storageKey => id.toString();

  static PrintingService fallback({int storeId = 0}) {
    return PrintingService(
      id: 0,
      storeId: storeId,
      name: 'POS',
      type: 'pos',
      template: 'receipt',
      isActive: true,
      sortOrder: 0,
    );
  }

  static int? _intFrom(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _boolFrom(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return null;
  }
}
