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
    _token = await repository.readToken();
    _userLabel = await repository.readUserIdentifier();
    _userDisplayName = await repository.readUserDisplayName();
    _recentUsers = await repository.readRecentUsers();
    _offlineMode = await _readOfflineMode();
    if (_token == null && _offlineMode) {
      await _restoreOfflineSessionIfPossible();
    }
    _initializing = false;
    notifyListeners();
  }

  Future<void> login(
    String identifier,
    String password, {
    bool forceOnline = false,
    bool allowOfflineFallback = true,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    if (_offlineMode && !forceOnline) {
      final ok = await _canLoginOffline(identifier, password);
      if (ok) {
        await _startOfflineSession(identifier);
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

    if (!success && allowOfflineFallback && (_error == null || _error!.isEmpty)) {
      _error =
          'Connexion impossible. Vérifiez vos identifiants ou réessayez en mode hors ligne.';
    }

    _isSubmitting = false;
    notifyListeners();
  }

  Future<void> setOfflineMode(bool value) async {
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
      await _startOfflineSession(identifier, notify: false);
    }
  }

  Future<void> _startOfflineSession(String identifier,
      {bool notify = true}) async {
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
    return success;
  }

  Future<bool> _canLoginOffline(String identifier, String password) async {
    final storedId = await repository.tokenStorage.readUserIdentifier();
    final storedHash =
        await repository.tokenStorage.readPasswordHashForUser(identifier) ??
            await repository.tokenStorage.readUserPasswordHash();
    if (storedHash == null) return false;
    // If a last user is stored and differs, still allow if specific hash exists.
    if (storedId != null &&
        storedId.trim().isNotEmpty &&
        storedId.trim() != identifier.trim() &&
        await repository.tokenStorage.readPasswordHashForUser(identifier) ==
            null) {
      return false;
    }
    return storedHash == _hash(password);
  }

  String _hash(String input) {
    return sha1.convert(utf8.encode(input)).toString();
  }

  Future<void> logout() async {
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
      final token = await repository.login(identifier: identifier, password: password);
      await _applyOnlineLogin(
        identifier,
        password,
        token,
        persistPassword: persistPassword,
      );
      return true;
    } on ApiException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      if (!allowOfflineFallback) {
        _error = 'Connexion impossible. Réessayez.';
        return false;
      }
      final ok = await _canLoginOffline(identifier, password);
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
      notifyListeners();
    }
  }
}
