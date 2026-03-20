import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/offline_sale.dart';

class OfflineSalesStorage {
  static const _storageKey = 'offline_sales_queue';

  Future<List<OfflineSale>> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return OfflineSale.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> write(List<OfflineSale> sales) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = OfflineSale.encodeList(sales);
    await prefs.setString(_storageKey, raw);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
