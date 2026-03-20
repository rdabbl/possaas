import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_nimirik/core/api/api_client.dart';
import 'package:pos_nimirik/core/storage/token_storage.dart';
import 'package:pos_nimirik/features/auth/data/auth_repository.dart';
import 'package:pos_nimirik/features/auth/state/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthController.tryReauthenticate', () {
    late _InMemoryAuthRepository repository;
    late AuthController controller;
    late TokenStorage storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = const TokenStorage();
      repository = _InMemoryAuthRepository(tokenStorage: storage);
      controller = AuthController(repository: repository);
    });

    test('restores an online session when credentials are cached', () async {
      await storage.saveUserIdentifier('cashier');
      await storage.saveUserPasswordPlain('secret');
      await controller.setOfflineMode(true);

      final success = await controller.tryReauthenticate();

      expect(success, isTrue);
      expect(controller.offlineMode, isFalse);
      expect(controller.token, equals('token-1'));
    });

    test('keeps offline mode when backend rejects the token', () async {
      await storage.saveUserIdentifier('cashier');
      await storage.saveUserPasswordPlain('secret');
      await controller.setOfflineMode(true);

      repository.shouldFail = true;
      final success = await controller.tryReauthenticate();

      expect(success, isFalse);
      expect(controller.offlineMode, isTrue);
    });
  });

  group('AuthController.removeRecentUser', () {
    late _InMemoryAuthRepository repository;
    late AuthController controller;
    late TokenStorage storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'pos_recent_users': jsonEncode([
          {'identifier': 'cashier', 'displayName': 'Cashier'}
        ]),
        'pos_cached_products': '[]',
        'pos_printer_settings_cashier': '{}',
        'pos_user_identifier': 'cashier',
        'pos_user_display_name': 'Cashier',
        'pos_user_password_plain': 'secret',
        'pos_user_password_hash': 'hash',
        'pos_user_password_map': jsonEncode({'cashier': 'hash'}),
        'pos_auth_token': 'token',
        'offline_sales_queue': '[]',
        'offline_mode': true,
      });
      storage = const TokenStorage();
      repository = _InMemoryAuthRepository(tokenStorage: storage);
      controller = AuthController(repository: repository);
      await controller.setOfflineMode(true);
    });

    test('clears cached POS data and credentials', () async {
      await controller.removeRecentUser('cashier');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('pos_cached_products'), isNull);
      expect(prefs.getString('pos_printer_settings_cashier'), isNull);
      expect(prefs.getString('offline_sales_queue'), isNull);
      expect(prefs.getBool('offline_mode'), isNull);
      expect(prefs.getString('pos_user_password_map'), isNull);
      expect(await storage.read(), isNull);
      expect(controller.recentUsers, isEmpty);
      expect(controller.offlineMode, isFalse);
    });
  });
}

class _InMemoryAuthRepository extends AuthRepository {
  _InMemoryAuthRepository({required TokenStorage tokenStorage})
      : super(apiClient: LaravelApiClient(), tokenStorage: tokenStorage);

  bool shouldFail = false;
  int _counter = 0;

  @override
  Future<String> login({
    required String identifier,
    required String password,
  }) async {
    if (shouldFail) {
      throw ApiException('Unauthenticated', statusCode: 401);
    }
    _counter++;
    final token = 'token-$_counter';
    await tokenStorage.save(token);
    await tokenStorage.saveUserIdentifier(identifier);
    await tokenStorage.saveUserDisplayName(identifier);
    return token;
  }
}
