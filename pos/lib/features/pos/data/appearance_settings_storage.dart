import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppearanceSettingsStorage {
  const AppearanceSettingsStorage();

  static const _storageKey = 'pos_appearance_settings';

  Future<Map<String, dynamic>?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored == null || stored.isEmpty) return null;
    try {
      final decoded = jsonDecode(stored);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry('$key', value));
      }
    } catch (_) {
      // ignore corrupted cache
    }
    return null;
  }

  Future<void> write(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(data));
  }
}
