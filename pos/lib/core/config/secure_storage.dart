class InMemoryTokenStore {
  static String? _token;

  static void setToken(String? token) {
    _token = token;
  }

  static Future<String?> readToken() async => _token;
}
