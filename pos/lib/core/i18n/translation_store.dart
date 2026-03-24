class TranslationStore {
  TranslationStore._();

  static Map<String, String> _translations = {};

  static String tr(String key) => _translations[key] ?? key;

  static void setTranslations(Map<String, String> translations) {
    _translations = translations;
  }
}

String tr(String key) => TranslationStore.tr(key);
