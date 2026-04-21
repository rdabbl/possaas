import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api/api_client.dart';
import '../../pos/data/offline_sales_storage.dart';
import '../data/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController({required this.repository});

  final AuthRepository repository;

  bool _initializing = true;
  bool _isSubmitting = false;
  String? _token;
  String? _error;
  String? _userLabel;
  String? _userDisplayName;
  List<Map<String, String>> _recentUsers = [];
  bool _offlineMode = false;

  bool get initializing => _initializing;
  bool get isSubmitting => _isSubmitting;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  String? get token => _token;
  String? get error => _error;
  String? get userLabel => _userLabel;
  String? get userDisplayName => _userDisplayName ?? _userLabel;
  List<Map<String, String>> get recentUsers => List.unmodifiable(_recentUsers);
  bool get offlineMode => _offlineMode;

  Future<void> bootstrap() async {
    final splashStartedAt = DateTime.now();
    const minimumSplash = Duration(seconds: 5);
    debugPrint('[AuthController] bootstrap started');
    _token = await repository.readToken();
    _userLabel = await repository.readUserIdentifier();
    _userDisplayName = await repository.readUserDisplayName();
    _recentUsers = await repository.readRecentUsers();
    _offlineMode = await _readOfflineMode();
    debugPrint(
      '[AuthController] bootstrap state token=${_token != null && _token!.isNotEmpty} user="$_userLabel" offlineMode=$_offlineMode recentUsers=${_recentUsers.length}',
    );

    if (_token == null && _offlineMode) {
      debugPrint('[AuthController] attempting offline session restore');
      await _restoreOfflineSessionIfPossible();
    }

    final elapsed = DateTime.now().difference(splashStartedAt);
    if (elapsed < minimumSplash) {
      await Future<void>.delayed(minimumSplash - elapsed);
    }

    _initializing = false;
    debugPrint('[AuthController] bootstrap finished');
    notifyListeners();
  }

  Future<void> login(
    String identifier,
    String password, {
    bool forceOnline = false,
    bool allowOfflineFallback = true,
  }) async {
    debugPrint(
      '[AuthController] login started identifier="$identifier" forceOnline=$forceOnline allowOfflineFallback=$allowOfflineFallback offlineMode=$_offlineMode',
    );
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    if (_offlineMode && !forceOnline) {
      debugPrint(
        '[AuthController] offline mode enabled, checking offline credentials',
      );
      final ok = await _canLoginOffline(identifier, password);
      debugPrint('[AuthController] offline credential check result=$ok');
      if (ok) {
        await _startOfflineSession(identifier);
        debugPrint('[AuthController] offline session started successfully');
        _isSubmitting = false;
        notifyListeners();
        return;
      }
    }

    final success = await _attemptOnlineLogin(
      identifier,
      password,
      persistPassword: true,
      allowOfflineFallback: allowOfflineFallback,
    );

    if (!success &&
        allowOfflineFallback &&
        (_error == null || _error!.isEmpty)) {
      _error =
          'Connexion impossible. Verifiez vos identifiants ou reessayez en mode hors ligne.';
      debugPrint(
        '[AuthController] login failed without explicit error, using fallback message',
      );
    }

    _isSubmitting = false;
    debugPrint(
      '[AuthController] login finished success=$success authenticated=$isAuthenticated error="${_error ?? ''}"',
    );
    notifyListeners();
  }

  Future<void> setOfflineMode(bool value) async {
    debugPrint('[AuthController] setOfflineMode($value)');
    _offlineMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('offline_mode', value);
    notifyListeners();
  }

  Future<bool> _readOfflineMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('offline_mode') ?? false;
  }

  Future<void> _restoreOfflineSessionIfPossible() async {
    final identifier = await repository.readUserIdentifier();
    final hash = identifier != null
        ? await repository.tokenStorage.readPasswordHashForUser(identifier) ??
            await repository.tokenStorage.readUserPasswordHash()
        : await repository.tokenStorage.readUserPasswordHash();
    if (identifier != null && identifier.isNotEmpty && hash != null) {
      debugPrint(
        '[AuthController] offline session can be restored for "$identifier"',
      );
      await _startOfflineSession(identifier, notify: false);
    } else {
      debugPrint('[AuthController] no offline session available to restore');
    }
  }

  Future<void> _startOfflineSession(
    String identifier, {
    bool notify = true,
  }) async {
    debugPrint('[AuthController] starting offline session for "$identifier"');
    _token = 'offline-$identifier';
    _userLabel = identifier;
    _userDisplayName = _userDisplayName ?? identifier;
    await repository.tokenStorage.save(_token!);
    await repository.tokenStorage.saveUserIdentifier(identifier);
    if (notify) {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> _savePasswordHash(String identifier, String password) async {
    final hash = _hash(password);
    await repository.tokenStorage.saveUserIdentifier(identifier);
    await repository.tokenStorage.saveUserPasswordHash(hash);
    await repository.tokenStorage.saveUserPasswordHashForUser(identifier, hash);
  }

  Future<bool> tryReauthenticate() async {
    final identifier = await repository.readUserIdentifier();
    final password = await repository.tokenStorage.readUserPasswordPlain();
    debugPrint(
      '[AuthController] tryReauthenticate identifier="$identifier" hasPassword=${password != null && password.isNotEmpty}',
    );
    if (identifier == null || identifier.isEmpty) return false;
    if (password == null || password.isEmpty) return false;

    final wasOffline = _offlineMode;
    _error = null;
    final success = await _attemptOnlineLogin(
      identifier,
      password,
      persistPassword: false,
      allowOfflineFallback: false,
    );
    if (!success && wasOffline) {
      await setOfflineMode(true);
    }
    debugPrint('[AuthController] tryReauthenticate result=$success');
    return success;
  }

  Future<bool> _canLoginOffline(String identifier, String password) async {
    debugPrint('[AuthController] checking offline login for "$identifier"');
    final storedId = await repository.tokenStorage.readUserIdentifier();
    final storedHash =
        await repository.tokenStorage.readPasswordHashForUser(identifier) ??
            await repository.tokenStorage.readUserPasswordHash();
    if (storedHash == null) {
      debugPrint('[AuthController] no stored offline hash found');
      return false;
    }

    if (storedId != null &&
        storedId.trim().isNotEmpty &&
        storedId.trim() != identifier.trim() &&
        await repository.tokenStorage.readPasswordHashForUser(identifier) ==
            null) {
      debugPrint(
        '[AuthController] offline login rejected because cached credentials belong to another user',
      );
      return false;
    }

    final matches = storedHash == _hash(password);
    debugPrint('[AuthController] offline password hash match=$matches');
    return matches;
  }

  String _hash(String input) {
    return sha1.convert(utf8.encode(input)).toString();
  }

  Future<void> logout() async {
    debugPrint('[AuthController] logout requested');
    await repository.logout();
    _token = null;
    notifyListeners();
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  Future<void> removeRecentUser(String identifier) async {
    final trimmed = identifier.trim();
    if (trimmed.isEmpty) return;
    await repository.tokenStorage.removeRecentUser(trimmed);
    await repository.tokenStorage.removeUserCredentials(trimmed);
    await _clearPosCaches();
    _recentUsers = await repository.readRecentUsers();
    _offlineMode = false;
    if (_userLabel != null &&
        _userLabel!.trim().toLowerCase() == trimmed.toLowerCase()) {
      _userLabel = null;
      _userDisplayName = null;
      _token = null;
    }
    notifyListeners();
  }

  Future<void> _clearPosCaches() async {
    final prefs = await SharedPreferences.getInstance();
    final reserved = {
      'pos_recent_users',
      'pos_user_identifier',
      'pos_user_display_name',
      'pos_user_password_hash',
      'pos_user_password_plain',
      'pos_user_password_map',
      'pos_auth_token',
    };
    final keys = prefs.getKeys().where((key) {
      if (key == 'offline_mode') return true;
      if (!key.startsWith('pos_')) return false;
      return !reserved.contains(key);
    }).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
    await OfflineSalesStorage().clear();
  }

  Future<bool> _attemptOnlineLogin(
    String identifier,
    String password, {
    required bool persistPassword,
    required bool allowOfflineFallback,
  }) async {
    try {
      debugPrint('[AuthController] attempting online login for "$identifier"');
      final token =
          await repository.login(identifier: identifier, password: password);
      await _applyOnlineLogin(
        identifier,
        password,
        token,
        persistPassword: persistPassword,
      );
      debugPrint('[AuthController] online login succeeded for "$identifier"');
      return true;
    } on ApiException catch (error) {
      _error = error.message;
      debugPrint(
        '[AuthController] online login ApiException status=${error.statusCode} message="${error.message}"',
      );
      return false;
    } catch (error, stackTrace) {
      debugPrint('[AuthController] online login unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!allowOfflineFallback) {
        _error = 'Connexion impossible. Reessayez.';
        return false;
      }
      final ok = await _canLoginOffline(identifier, password);
      debugPrint('[AuthController] fallback to offline after error result=$ok');
      if (ok) {
        await setOfflineMode(true);
        await _startOfflineSession(identifier);
        return true;
      }
      return false;
    }
  }

  Future<void> _applyOnlineLogin(
    String identifier,
    String password,
    String token, {
    required bool persistPassword,
  }) async {
    final tokenPreview =
        token.length > 8 ? '${token.substring(0, 8)}...' : token;
    debugPrint(
      '[AuthController] applying online login for "$identifier" persistPassword=$persistPassword tokenPreview=$tokenPreview',
    );
    _token = token;
    _userLabel = identifier;
    _userDisplayName = await repository.readUserDisplayName();
    await repository.tokenStorage.addRecentUser(
      identifier,
      _userDisplayName ?? identifier,
    );
    _recentUsers = await repository.readRecentUsers();
    if (persistPassword) {
      await _savePasswordHash(identifier, password);
      await repository.tokenStorage.saveUserPasswordPlain(password);
    }
    _error = null;
    if (_offlineMode) {
      await setOfflineMode(false);
    } else {
      debugPrint('[AuthController] notifying listeners after online login');
      notifyListeners();
    }
  }
}
