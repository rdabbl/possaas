import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PrinterSettingsStorage {
  const PrinterSettingsStorage();

  static const _machineKey = 'pos_printer_settings_machine';
  static const _legacyKeyPrefix = 'pos_printer_settings_';

  Future<Map<String, dynamic>?> read(String? userKey) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = <String>[
      _machineKey,
      _legacyKey(userKey),
      _legacyKey(null),
    ];
    for (final key in keys) {
      final stored = prefs.getString(key);
      if (stored == null || stored.isEmpty) {
        continue;
      }
      try {
        final decoded = jsonDecode(stored);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        if (decoded is Map) {
          return decoded.map((k, value) => MapEntry('$k', value));
        }
      } catch (_) {
        // ignore corrupted cache, caller will fallback to defaults
      }
    }
    return null;
  }

  Future<void> write(String? userKey, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_machineKey, jsonEncode(data));
  }

  Future<void> clear(String? userKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_machineKey);
  }

  String _legacyKey(String? userKey) {
    final sanitized = (userKey ?? 'default')
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return '$_legacyKeyPrefix$sanitized';
  }
}
