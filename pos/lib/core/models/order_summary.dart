import 'product_option.dart';

class OrderSummary {
  OrderSummary({
    required this.id,
    required this.referenceCode,
    required this.customerName,
    required this.status,
    required this.paymentStatus,
    required this.grandTotal,
    required this.paidAmount,
    required this.itemCount,
    required this.productNames,
    required this.itemsDetail,
    this.userName,
    this.userId,
    this.note,
    this.createdAt,
    this.isLocal = false,
  });

  final int id;
  final String referenceCode;
  final String customerName;
  final String? userName;
  final int? userId;
  final String? note;
  final String status;
  final String paymentStatus;
  final double grandTotal;
  final double paidAmount;
  final int itemCount;
  final List<String> productNames;
  final List<OrderItemSummary> itemsDetail;
  final DateTime? createdAt;
  final bool isLocal;

  bool get isKioskOrder {
    final value = (note ?? '').toLowerCase();
    return value.contains('borne') || value.contains('kiosk');
  }

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] is Map<String, dynamic>
        ? json['attributes'] as Map<String, dynamic>
        : <String, dynamic>{};
    final source = attributes.isNotEmpty ? attributes : json;

    double _parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    DateTime? _parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    List<String> _parseProductNames(dynamic value) {
      if (value is List) {
        return value
            .map((item) {
              if (item is Map<String, dynamic>) {
                final product = item['product'] is Map<String, dynamic> ? item['product'] as Map<String, dynamic> : null;
                final name = item['product_name'] ?? product?['name'] ?? item['name'] ?? item['product'] ?? '';
                return name.toString();
              }
              return item.toString();
            })
            .where((name) => name.trim().isNotEmpty)
            .toList();
      }
      if (value is String && value.trim().isNotEmpty) {
        return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return <String>[];
    }

    List<OrderItemSummary> _parseItems(dynamic value) {
      if (value is List) {
        return value
            .whereType<Map>()
            .map((e) {
              final item = e.cast<String, dynamic>();
              final product = item['product'] is Map<String, dynamic> ? item['product'] as Map<String, dynamic> : null;
              final name = item['product_name'] ?? product?['name'] ?? item['name'] ?? item['product'] ?? '';
              final qtyRaw = item['quantity'] ?? item['qty'] ?? item['pivot']?['quantity'];
              double qty = 0;
              if (qtyRaw is num) {
                qty = qtyRaw.toDouble();
              } else if (qtyRaw is String) {
                qty = double.tryParse(qtyRaw) ?? 0;
              }
              final optionsRaw = item['options'] ?? item['ingredients'];
              final options = optionsRaw is List
                  ? optionsRaw
                      .whereType<Map>()
                      .map((i) => ProductOption.fromJson(i.cast<String, dynamic>()))
                      .where((o) => o.id > 0 && o.name.trim().isNotEmpty)
                      .toList()
                  : <ProductOption>[];
              return OrderItemSummary(
                name: name.toString(),
                quantity: qty,
                options: options,
              );
            })
            .where((item) => item.name.trim().isNotEmpty)
            .toList();
      }
      return <OrderItemSummary>[];
    }

    final saleItems = source['items'] ?? source['sale_items'];
    final itemsDetail = _parseItems(saleItems);
    final status = (source['status'] ?? '').toString();
    final grandTotal = _parseDouble(source['grand_total'] ?? source['grandTotal']);
    final paidAmount = source['paid_amount'] ?? source['paidAmount'];
    double paidFromPayments = 0;
    final paymentsRaw = source['payments'];
    if (paymentsRaw is List) {
      for (final payment in paymentsRaw) {
        if (payment is Map<String, dynamic>) {
          paidFromPayments += _parseDouble(payment['amount']);
        }
      }
    }
    final double computedPaid = paidAmount != null
        ? _parseDouble(paidAmount)
        : (paidFromPayments > 0
            ? paidFromPayments
            : (status.toLowerCase() == 'paid' ? grandTotal : 0.0));

    final rawItems = source['items'] ?? source['sale_items'];

    return OrderSummary(
      id: _parseInt(json['id'] ?? source['id']),
      referenceCode:
          (source['reference_code'] ?? source['referenceCode'] ?? source['number'] ?? '').toString(),
      customerName:
          (source['customer_name'] ?? source['customerName'] ?? source['customer']?['name'] ?? 'Client').toString(),
      userName: (source['user_name'] ?? source['created_by'] ?? source['created_by_name'] ?? '').toString().trim().isEmpty
          ? null
          : (source['user_name'] ?? source['created_by'] ?? source['created_by_name']).toString(),
      userId: source['user_id'] != null ? int.tryParse('${source['user_id']}') : null,
      note: (source['note'] ?? '').toString().trim().isEmpty
          ? null
          : (source['note']).toString(),
      status: status,
      paymentStatus:
          (source['payment_status'] ?? source['paymentStatus'] ?? status).toString(),
      grandTotal: grandTotal,
      paidAmount: computedPaid,
      itemCount: _parseInt(
        rawItems is List ? rawItems.length : source['item_count'],
      ),
      productNames: _parseProductNames(saleItems ?? source['product_names']),
      itemsDetail: itemsDetail,
      createdAt: _parseDate(source['ordered_at'] ?? source['created_at'] ?? source['createdAt']),
      isLocal: false,
    );
  }
}

class OrderItemSummary {
  OrderItemSummary({
    required this.name,
    required this.quantity,
    this.options = const [],
  });
  final String name;
  final double quantity;
  final List<ProductOption> options;
}
