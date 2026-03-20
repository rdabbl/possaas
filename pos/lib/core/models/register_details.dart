class RegisterDetails {
  RegisterDetails({
    required this.cashInHand,
    required this.totalCashAmount,
    required this.salesAmount,
    required this.salesReturnAmount,
    required this.cashPayments,
    required this.salesCount,
    required this.itemsCount,
  });

  final double cashInHand;
  final double totalCashAmount;
  final double salesAmount;
  final double salesReturnAmount;
  final double cashPayments;
  final int salesCount;
  final int itemsCount;

  factory RegisterDetails.empty() => RegisterDetails(
        cashInHand: 0,
        totalCashAmount: 0,
        salesAmount: 0,
        salesReturnAmount: 0,
        cashPayments: 0,
        salesCount: 0,
        itemsCount: 0,
      );

  factory RegisterDetails.fromJson(Map<String, dynamic> json) {
    final data =
        json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

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

    return RegisterDetails(
      cashInHand: _parseDouble(data['cash_in_hand']),
      totalCashAmount: _parseDouble(data['total_cash_amount']),
      salesAmount: _parseDouble(data['today_sales_amount']),
      salesReturnAmount: _parseDouble(data['today_sales_return_amount']),
      cashPayments: _parseDouble(data['today_sales_cash_payment']),
      salesCount: _parseInt(data['total_sales_count']),
      itemsCount: _parseInt(data['total_items_count']),
    );
  }
}
