import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/storage/token_storage.dart';

class AuthRepository {
  AuthRepository({
    required this.apiClient,
    required this.tokenStorage,
  });

  final LaravelApiClient apiClient;
  final TokenStorage tokenStorage;

  Future<String?> readToken() => tokenStorage.read();
  Future<String?> readUserIdentifier() => tokenStorage.readUserIdentifier();
  Future<String?> readUserDisplayName() => tokenStorage.readUserDisplayName();
  Future<List<Map<String, String>>> readRecentUsers() => tokenStorage.readRecentUsers();

  Future<String> login({
    required String identifier,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.authLogin,
      body: {
        'email': identifier,
        'password': password,
      },
    );
    final data = response['data'] ?? response;
    final token = data['token'] ?? data['access_token'];
    final user = data['user'] ?? {};
    final name = user['name']?.toString().trim();
    final label = name ?? '';
    if (token == null || token.toString().isEmpty) {
      throw ApiException('Jeton manquant dans la réponse.');
    }
    await tokenStorage.save(token.toString());
    await tokenStorage.saveUserIdentifier(identifier);
    await tokenStorage.saveUserDisplayName(label.isNotEmpty ? label : identifier);
    return token.toString();
  }

  Future<void> logout() async {
    try {
      await apiClient.post(ApiEndpoints.authLogout);
    } catch (_) {
      // ignore network errors on logout
    } finally {
      await tokenStorage.clearToken();
    }
  }
}
