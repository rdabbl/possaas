import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/models/product_category.dart';
import '../../../core/models/customer.dart';
import '../../../core/models/currency.dart';
import '../../../core/models/payment_method.dart';
import '../../../core/models/product.dart';
import '../../../core/models/warehouse.dart';
import '../../../core/models/order_summary.dart';
import '../../../core/models/register_details.dart';
import '../models/user_summary.dart';

class PosRepository {
  PosRepository({required this.apiClient});

  final LaravelApiClient apiClient;

  Future<List<Product>> fetchProducts({
    int? warehouseId,
    int? categoryId,
    String? search,
  }) async {
    final result = await apiClient.getList(
      ApiEndpoints.products,
      queryParameters: {
        'per_page': 200,
        if (warehouseId != null) 'store_id': warehouseId,
        if (categoryId != null && categoryId > 0) 'category_id': categoryId,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final products = result
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();

    Iterable<Product> filtered = products;
    if (categoryId != null && categoryId > 0) {
      filtered = filtered.where((p) => p.categoryId == categoryId);
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      filtered = filtered.where((p) => p.name.toLowerCase().contains(q));
    }
    return filtered.toList();
  }

  Future<List<Customer>> fetchCustomers({String? search}) async {
    final result = await apiClient.getList(
      ApiEndpoints.customers,
      queryParameters: {
        'per_page': 200,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return result
        .whereType<Map<String, dynamic>>()
        .map(Customer.fromJson)
        .toList();
  }

  Future<Map<String, dynamic>> fetchFrontSetting() {
    return apiClient.get(ApiEndpoints.frontSetting);
  }

  Future<List<Currency>> fetchCurrencies() async {
    final result = await apiClient.getList(ApiEndpoints.currencies);
    return result
        .whereType<Map<String, dynamic>>()
        .map(Currency.fromJson)
        .toList();
  }

  Future<Map<String, dynamic>> updateSettings(int storeId, Map<String, dynamic> payload) {
    return apiClient.put('${ApiEndpoints.stores}/$storeId', body: payload);
  }

  Future<List<ProductCategory>> fetchCategories() async {
    final result = await apiClient.getList(
      ApiEndpoints.categories,
      queryParameters: {'per_page': 200},
    );
    return result
        .whereType<Map<String, dynamic>>()
        .map(ProductCategory.fromJson)
        .toList();
  }

  Future<List<PaymentMethod>> fetchPaymentMethods() async {
    final result = await apiClient.getList(
      ApiEndpoints.paymentMethods,
      queryParameters: {'per_page': 200},
    );
    final methods = result
        .whereType<Map<String, dynamic>>()
        .map(PaymentMethod.fromJson)
        .where((method) => method.isActive)
        .toList();
    return methods;
  }

  Future<List<UserSummary>> fetchUsers() async {
    final response = await apiClient.get(ApiEndpoints.authMe);
    if (response.isEmpty) return [];
    final id = response['id'];
    final name = response['name']?.toString().trim();
    final email = response['email']?.toString().trim();
    final label = (name != null && name.isNotEmpty) ? name : (email ?? '');
    final parsedId = int.tryParse('$id');
    if (parsedId == null || label.isEmpty) return [];
    return [UserSummary(id: parsedId, label: label)];
  }

  Future<List<Warehouse>> fetchWarehouses() async {
    final result = await apiClient.getList(
      ApiEndpoints.stores,
      queryParameters: {'per_page': 200},
    );
    return result
        .whereType<Map<String, dynamic>>()
        .map(Warehouse.fromJson)
        .toList();
  }

  Future<void> submitSale({
    required int customerId,
    required List<CartItem> cartItems,
    required double grandTotal,
    int? warehouseId,
    double discount = 0,
    double shipping = 0,
    double taxRate = 0,
    int paymentTypeId = 1,
    int paymentStatusId = 1,
    String? notes,
    double receivedAmount = 0,
  }) async {
    if (warehouseId == null) {
      throw ApiException('Store requis pour enregistrer une vente.');
    }
    final itemsSubTotal =
        cartItems.fold<double>(0, (sum, item) => sum + item.subTotal);
    final discountShare = itemsSubTotal > 0 ? discount / itemsSubTotal : 0;
    final payload = <String, dynamic>{
      'store_id': warehouseId,
      'note': notes,
      'items': cartItems.map((item) {
        final lineSubtotal = item.subTotal;
        final lineDiscount = lineSubtotal * discountShare;
        final lineTax = (lineSubtotal - lineDiscount) * (taxRate / 100);
        return item.toSalePayload(
          discountAmount: lineDiscount,
          taxAmount: lineTax,
        );
      }).toList(),
    };
    if (customerId > 0) {
      payload['customer_id'] = customerId;
    }
    final payments = _buildPayments(
      paymentMethodId: paymentTypeId,
      paymentStatusId: paymentStatusId,
      receivedAmount: receivedAmount,
      grandTotal: grandTotal,
    );
    if (payments.isNotEmpty) {
      payload['payments'] = payments;
    }

    await apiClient.post(ApiEndpoints.sales, body: payload);
  }

  Future<void> submitOfflineSale({
    required int customerId,
    required List<Map<String, dynamic>> saleItems,
    required double grandTotal,
    int? warehouseId,
    double discount = 0,
    double shipping = 0,
    double taxRate = 0,
    int paymentTypeId = 1,
    int paymentStatusId = 1,
    String? notes,
    double receivedAmount = 0,
  }) async {
    if (warehouseId == null) {
      throw ApiException('Store requis pour enregistrer une vente.');
    }
    final payload = <String, dynamic>{
      'store_id': warehouseId,
      'note': notes,
      'items': saleItems,
    };
    if (customerId > 0) {
      payload['customer_id'] = customerId;
    }
    final payments = _buildPayments(
      paymentMethodId: paymentTypeId,
      paymentStatusId: paymentStatusId,
      receivedAmount: receivedAmount,
      grandTotal: grandTotal,
    );
    if (payments.isNotEmpty) {
      payload['payments'] = payments;
    }
    await apiClient.post(ApiEndpoints.sales, body: payload);
  }

  Future<List<OrderSummary>> fetchRecentSales({int hours = 24, int? userId}) async {
    final result = await apiClient.getList(
      ApiEndpoints.sales,
      queryParameters: {'per_page': 200},
    );
    final orders = result
        .whereType<Map<String, dynamic>>()
        .map(OrderSummary.fromJson)
        .toList();
    if (userId == null) return orders;
    return orders.where((order) => order.userId == userId).toList();
  }

  Future<RegisterDetails> fetchRegisterDetails({int hours = 24}) async {
    return RegisterDetails.empty();
  }

  Future<List<String>> fetchSaleProductNames(int saleId) async {
    final result = await apiClient.get('${ApiEndpoints.sales}/$saleId');
    final sale = result['data'] ?? result;
    final items = sale['items'] ?? sale['sale_items'] ?? sale['saleItems'] ?? [];
    if (items is! List) return [];
    return items
        .map((item) {
          if (item is Map<String, dynamic>) {
            final product = item['product'] is Map<String, dynamic> ? item['product'] as Map<String, dynamic> : null;
            final name = item['product_name'] ?? product?['name'] ?? item['name'] ?? item['product'] ?? '';
            return name.toString();
          }
          return item.toString();
        })
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<OrderSummary?> fetchSaleDetails(int saleId) async {
    final result = await apiClient.get('${ApiEndpoints.sales}/$saleId');
    final sale = result['data'] ?? result;
    if (sale is Map<String, dynamic>) {
      return OrderSummary.fromJson(sale);
    }
    return null;
  }

  Future<Map<String, dynamic>> fetchConfig() async {
    return <String, dynamic>{};
  }

  Future<void> openRegister({required double cashInHand}) async {
    return;
  }

  Future<void> closeRegister({
    required double cashInHandWhileClosing,
    String? notes,
  }) async {
    return;
  }

  List<Map<String, dynamic>> _buildPayments({
    required int paymentMethodId,
    required int paymentStatusId,
    required double receivedAmount,
    required double grandTotal,
  }) {
    if (paymentMethodId <= 0) return const [];
    if (paymentStatusId == 2) return const []; // unpaid
    double amount;
    if (paymentStatusId == 3) {
      amount = receivedAmount;
    } else {
      amount = grandTotal;
    }
    if (amount <= 0) return const [];
    if (amount > grandTotal) amount = grandTotal;
    return [
      {
        'payment_method_id': paymentMethodId,
        'amount': double.parse(amount.toStringAsFixed(2)),
      },
    ];
  }
}
