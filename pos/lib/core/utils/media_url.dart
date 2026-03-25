import '../config/app_config.dart';

String? normalizeMediaUrl(String? url) {
  if (url == null) return null;
  final trimmedInput = url.trim();
  if (trimmedInput.isEmpty) return null;

  final apiBase = AppConfig.apiBaseUrl.replaceFirst(RegExp(r'/$'), '');
  final root = apiBase.replaceFirst(RegExp(r'/api/?$'), '');

  if (trimmedInput.startsWith('http://') ||
      trimmedInput.startsWith('https://')) {
    if (trimmedInput.contains('/api/media/')) {
      return trimmedInput;
    }
    final storageIndex = trimmedInput.indexOf('/storage/');
    if (storageIndex != -1) {
      final normalized =
          trimmedInput.substring(storageIndex + '/storage/'.length);
      return '$apiBase/media/$normalized';
    }
    return trimmedInput;
  }

  var relative = trimmedInput.startsWith('/')
      ? trimmedInput.substring(1)
      : trimmedInput;

  if (relative.startsWith('api/media/')) {
    return '$root/$relative';
  }

  if (relative.startsWith('media/')) {
    return '$apiBase/$relative';
  }

  if (relative.startsWith('storage/')) {
    relative = relative.substring('storage/'.length);
  }

  return '$apiBase/media/$relative';
}
