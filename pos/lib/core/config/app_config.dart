class AppConfig {
  AppConfig._();

  /// Base URL used for HTTP calls. Override at build time with:
  /// flutter run --dart-define=API_BASE_URL=https://example.com/api
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://app.kincash.fr/api',
    //defaultValue: 'http://localhost:8000/api',
  );

  static const Duration networkTimeout = Duration(seconds: 60);

  /// Default URL opened from POS banner webview action.
  static const String defaultWebViewUrl = String.fromEnvironment(
    'POS_WEBVIEW_URL',
    defaultValue: 'https://app.kincash.fr',
  );
}
