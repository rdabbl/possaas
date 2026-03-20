class ApiEndpoints {
  ApiEndpoints._();

  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';

  static const String products = '/products';
  static const String customers = '/customers';
  static const String categories = '/categories';
  static const String stores = '/stores';
  static const String sales = '/sales';
  static const String taxes = '/taxes';
  static const String paymentMethods = '/payment-methods';
  static const String currencies = '/currencies';

  // Legacy aliases (kept for existing repository methods).
  static const String cashPayment = sales;
  static const String frontSetting = authMe;
  static const String settings = authMe;
  static const String brands = '';
  static const String warehouses = stores;
  static const String recentSales = sales;
  static const String saleInfo = sales;
  static const String registerDetails = '';
  static const String registerEntry = '';
  static const String registerClose = '';
  static const String config = authMe;
  static const String users = authMe;
}
