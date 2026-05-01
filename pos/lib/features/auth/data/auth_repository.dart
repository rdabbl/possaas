import 'package:flutter/foundation.dart';

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
  Future<List<Map<String, String>>> readRecentUsers() =>
      tokenStorage.readRecentUsers();

  Future<String> login({
    required String identifier,
    required String password,
  }) async {
    debugPrint('[AuthRepository] login request started for "$identifier"');
    final trimmedPassword = password.trim();
    final usesPin = RegExp(r'^\d{4}$').hasMatch(trimmedPassword);
    final response = await apiClient.post(
      ApiEndpoints.authLogin,
      body: {
        'username': identifier,
        if (usesPin) 'pin': trimmedPassword else 'password': password,
      },
    );
    debugPrint(
      '[AuthRepository] raw login response keys=${response.keys.toList()}',
    );

    final data = response['data'] ?? response;
    final token = data['token'] ?? data['access_token'];
    final user = data['user'] ?? {};
    final name = user['name']?.toString().trim();
    final label = name ?? '';

    if (token == null || token.toString().isEmpty) {
      debugPrint('[AuthRepository] login response missing token');
      throw ApiException('Jeton manquant dans la reponse.');
    }

    await tokenStorage.save(token.toString());
    await tokenStorage.saveUserIdentifier(identifier);
    await tokenStorage.saveUserDisplayName(
      label.isNotEmpty ? label : identifier,
    );
    debugPrint(
      '[AuthRepository] login success for "$identifier" displayName="${label.isNotEmpty ? label : identifier}" tokenLength=${token.toString().length}',
    );
    return token.toString();
  }

  Future<void> logout() async {
    try {
      debugPrint('[AuthRepository] logout request started');
      await apiClient.post(ApiEndpoints.authLogout);
    } catch (_) {
      // ignore network errors on logout
    } finally {
      debugPrint('[AuthRepository] clearing stored token');
      await tokenStorage.clearToken();
    }
  }
}
