import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  const TokenStorage();

  static const _tokenKey = 'pos_auth_token';
  static const _userIdentifierKey = 'pos_user_identifier';
  static const _userDisplayNameKey = 'pos_user_display_name';
  static const _recentUsersKey = 'pos_recent_users';
  static const _userPasswordHashKey = 'pos_user_password_hash';
  static const _userPasswordMapKey = 'pos_user_password_map';
  static const _userPasswordPlainKey = 'pos_user_password_plain';

  Future<void> save(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveUserIdentifier(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdentifierKey, identifier);
  }

  Future<void> saveUserDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDisplayNameKey, name);
  }

  Future<String?> readUserIdentifier() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdentifierKey);
  }

  Future<String?> readUserDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDisplayNameKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Keep identifier and password (hash/plain) so offline/auto login can still work after un logout.
    await prefs.remove(_tokenKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdentifierKey);
    await prefs.remove(_userDisplayNameKey);
    await prefs.remove(_recentUsersKey);
    await prefs.remove(_userPasswordHashKey);
    await prefs.remove(_userPasswordPlainKey);
  }

  Future<void> saveUserPasswordHash(String hash) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPasswordHashKey, hash);
  }

  Future<String?> readUserPasswordHash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPasswordHashKey);
  }

  Future<void> saveUserPasswordPlain(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPasswordPlainKey, password);
  }

  Future<String?> readUserPasswordPlain() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPasswordPlainKey);
  }

  Future<void> saveUserPasswordHashForUser(String identifier, String hash) async {
    final prefs = await SharedPreferences.getInstance();
    final map = await _readPasswordMapInternal();
    map[identifier.trim()] = hash;
    await prefs.setString(_userPasswordMapKey, jsonEncode(map));
  }

  Future<String?> readPasswordHashForUser(String identifier) async {
    final map = await _readPasswordMapInternal();
    return map[identifier.trim()];
  }

  Future<void> removeUserCredentials(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = identifier.trim();
    if (trimmed.isEmpty) return;
    final map = await _readPasswordMapInternal();
    if (map.containsKey(trimmed)) {
      map.remove(trimmed);
      if (map.isEmpty) {
        await prefs.remove(_userPasswordMapKey);
      } else {
        await prefs.setString(_userPasswordMapKey, jsonEncode(map));
      }
    }
    final storedIdentifier = prefs.getString(_userIdentifierKey);
    if (storedIdentifier != null &&
        storedIdentifier.trim().toLowerCase() == trimmed.toLowerCase()) {
      await prefs.remove(_userIdentifierKey);
      await prefs.remove(_userDisplayNameKey);
      await prefs.remove(_userPasswordPlainKey);
      await prefs.remove(_userPasswordHashKey);
      await prefs.remove(_tokenKey);
    }
  }

  Future<Map<String, String>> _readPasswordMapInternal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userPasswordMapKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry('$key', '$value'));
      }
    } catch (_) {}
    return {};
  }

  Future<void> addRecentUser(String identifier, String displayName) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _readRecentUsersInternal();
    list.removeWhere((entry) => entry['identifier'] == identifier);
    list.insert(0, {
      'identifier': identifier,
      'displayName': displayName,
    });
    if (list.length > 5) {
      list.removeRange(5, list.length);
    }
    await prefs.setString(_recentUsersKey, jsonEncode(list));
  }

  Future<void> removeRecentUser(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _readRecentUsersInternal();
    list.removeWhere((entry) => entry['identifier'] == identifier);
    await prefs.setString(_recentUsersKey, jsonEncode(list));
  }

  Future<List<Map<String, String>>> readRecentUsers() async {
    final list = await _readRecentUsersInternal();
    return list
        .map((entry) => {
              'identifier': entry['identifier'] ?? '',
              'displayName': entry['displayName'] ?? entry['identifier'] ?? '',
            })
        .where((entry) => entry['identifier']!.isNotEmpty)
        .toList();
  }

  Future<List<Map<String, String>>> _readRecentUsersInternal() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_recentUsersKey);
    if (stored == null || stored.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(stored);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => e.map((key, value) => MapEntry('$key', '$value')))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
