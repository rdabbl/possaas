import 'dart:convert';

enum OfflineSaleStatus { pending, failed, synced }

class OfflineSale {
  OfflineSale({
    required this.id,
    required this.customerId,
    required this.saleItems,
    required this.grandTotal,
    required this.createdAt,
    this.warehouseId,
    this.discount = 0,
    this.shipping = 0,
    this.taxRate = 0,
    this.paymentTypeId = 1,
    this.paymentStatusId = 1,
    this.receivedAmount = 0,
    this.notes,
    this.status = OfflineSaleStatus.pending,
    this.errorMessage,
  });

  final String id;
  final int customerId;
  final int? warehouseId;
  final double grandTotal;
  final double discount;
  final double shipping;
  final double taxRate;
  final int paymentTypeId;
  final int paymentStatusId;
  final double receivedAmount;
  final String? notes;
  final List<Map<String, dynamic>> saleItems;
  final DateTime createdAt;
  final OfflineSaleStatus status;
  final String? errorMessage;

  OfflineSale copyWith({
    OfflineSaleStatus? status,
    String? errorMessage,
  }) {
    return OfflineSale(
      id: id,
      customerId: customerId,
      warehouseId: warehouseId,
      grandTotal: grandTotal,
      discount: discount,
      shipping: shipping,
      taxRate: taxRate,
      paymentTypeId: paymentTypeId,
      paymentStatusId: paymentStatusId,
      receivedAmount: receivedAmount,
      notes: notes,
      saleItems: saleItems,
      createdAt: createdAt,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'warehouseId': warehouseId,
      'grandTotal': grandTotal,
      'discount': discount,
      'shipping': shipping,
      'taxRate': taxRate,
      'paymentTypeId': paymentTypeId,
      'paymentStatusId': paymentStatusId,
      'receivedAmount': receivedAmount,
      'notes': notes,
      'saleItems': saleItems,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'errorMessage': errorMessage,
    };
  }

  static OfflineSale fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] as String?) ?? OfflineSaleStatus.pending.name;
    return OfflineSale(
      id: json['id'] as String,
      customerId: json['customerId'] as int,
      warehouseId: json['warehouseId'] as int?,
      grandTotal: (json['grandTotal'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      shipping: (json['shipping'] as num?)?.toDouble() ?? 0,
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0,
      paymentTypeId: json['paymentTypeId'] as int? ?? 1,
      paymentStatusId: json['paymentStatusId'] as int? ?? 1,
      receivedAmount: (json['receivedAmount'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      saleItems: (json['saleItems'] as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: OfflineSaleStatus.values.firstWhere(
        (s) => s.name == statusStr,
        orElse: () => OfflineSaleStatus.pending,
      ),
      errorMessage: json['errorMessage'] as String?,
    );
  }

  static List<OfflineSale> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => OfflineSale.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  static String encodeList(List<OfflineSale> sales) {
    return jsonEncode(sales.map((e) => e.toJson()).toList());
  }
}
