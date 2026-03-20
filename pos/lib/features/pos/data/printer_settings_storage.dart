import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PrinterSettingsStorage {
  const PrinterSettingsStorage();

  static const _keyPrefix = 'pos_printer_settings_';

  Future<Map<String, dynamic>?> read(String? userKey) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key(userKey));
    if (stored == null || stored.isEmpty) return null;
    try {
      final decoded = jsonDecode(stored);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry('$key', value));
      }
    } catch (_) {
      // ignore corrupted cache, caller will fallback to defaults
    }
    return null;
  }

  Future<void> write(String? userKey, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(userKey), jsonEncode(data));
  }

  Future<void> clear(String? userKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(userKey));
  }

  String _key(String? userKey) {
    final sanitized = (userKey ?? 'default')
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return '$_keyPrefix$sanitized';
  }
}
