import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  /// Base URL backend Express.js
  /// Menggunakan 10.0.2.2 untuk Android Emulator, dan localhost untuk Web/Desktop/iOS
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else {
      try {
        if (Platform.isAndroid) {
          return 'http://10.0.2.2:5000/api';
        }
      } catch (_) {}
      return 'http://localhost:5000/api';
    }
  }

  static String get menusUrl => '$baseUrl/menus';
  static String get eventsUrl => '$baseUrl/events';
  static String get booksUrl => '$baseUrl/books';
  static String get registerUrl => '$baseUrl/auth/register';
  static String get loginUrl => '$baseUrl/auth/login';
  static String get aiChatUrl => '$baseUrl/ai/chat';
}
