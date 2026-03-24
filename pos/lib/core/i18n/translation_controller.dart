import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../api/api_client.dart';
import 'translation_store.dart';

class TranslationController extends ChangeNotifier {
  TranslationController({LaravelApiClient? apiClient})
      : _apiClient = apiClient ?? LaravelApiClient();

  final LaravelApiClient _apiClient;

  bool _loading = false;
  String _locale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  String get locale => _locale;
  bool get loading => _loading;

  Future<void> bootstrap() async {
    await loadTranslations();
  }

  Future<void> setLocale(String locale) async {
    if (locale.trim().isEmpty) return;
    _locale = locale.trim().toLowerCase();
    await loadTranslations();
  }

  Future<void> loadTranslations() async {
    _loading = true;
    notifyListeners();
    try {
      final response = await _apiClient.get('/translations', queryParameters: {
        'lang': _locale,
        'scope': 'flutter',
      });
      final data = response['translations'];
      if (data is Map) {
        final mapped = data.map((key, value) => MapEntry('$key', '$value'));
        TranslationStore.setTranslations(mapped);
      }
    } catch (_) {
      // Keep existing translations on failure.
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
