import 'package:flutter/foundation.dart';

/// HTTP / API Logger yang aman — menyensor semua informasi sensitif
/// (password, token, authorization header) agar tidak bocor di log debug.
class ApiLogger {
  ApiLogger._();

  static const String _tag = '[API]';

  /// Field sensitif yang wajib disensor
  static const Set<String> _sensitiveKeys = {
    'authorization',
    'password',
    'token',
    'access_token',
    'refresh_token',
    'secret',
    'client_secret',
    'id_token',
    'google_id',
    'x-api-key',
  };

  /// Sensor map headers
  static Map<String, String> sanitizeHeaders(Map<String, String>? headers) {
    if (headers == null) return {};
    return headers.map((key, value) {
      if (_sensitiveKeys.contains(key.toLowerCase())) {
        return MapEntry(key, '***REDACTED***');
      }
      return MapEntry(key, value);
    });
  }

  /// Sensor body string JSON atau form
  static String sanitizeBody(String? body) {
    if (body == null || body.trim().isEmpty) return '';
    String sanitized = body;
    for (final key in _sensitiveKeys) {
      sanitized = sanitized.replaceAllMapped(
        RegExp('"$key"\\s*:\\s*"[^"]*"', caseSensitive: false),
        (_) => '"$key":"***REDACTED***"',
      );
    }
    return sanitized;
  }

  /// Catat log request keluar
  static void logRequest(
    String method,
    Uri url, {
    Map<String, String>? headers,
    String? body,
  }) {
    if (!kDebugMode) return;
    debugPrint('$_tag ➡ $method ${url.path}');
    if (headers != null && headers.isNotEmpty) {
      debugPrint('$_tag   Headers: ${sanitizeHeaders(headers)}');
    }
    if (body != null && body.isNotEmpty) {
      debugPrint('$_tag   Body: ${sanitizeBody(body)}');
    }
  }

  /// Catat log response masuk
  static void logResponse(
    int statusCode,
    Uri url, {
    String? body,
  }) {
    if (!kDebugMode) return;
    final symbol = statusCode >= 400 ? '✖' : '✔';
    debugPrint('$_tag $symbol $statusCode ${url.path}');
    if (body != null && body.isNotEmpty) {
      final sanitized = sanitizeBody(body);
      final preview =
          sanitized.length > 500 ? '${sanitized.substring(0, 500)}...' : sanitized;
      debugPrint('$_tag   Body: $preview');
    }
  }

  /// Catat log network/client error
  static void logError(String method, Uri url, Object error) {
    if (!kDebugMode) return;
    debugPrint('$_tag ✖ $method ${url.path} Error: $error');
  }
}

