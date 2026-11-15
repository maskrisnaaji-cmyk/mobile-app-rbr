import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  /// Google OAuth Client ID dibaca secara dinamis dari file .env (dotenv.env['GOOGLE_CLIENT_ID'])
  static String get googleClientId {
    try {
      if (dotenv.isInitialized) {
        final val = dotenv.env['GOOGLE_CLIENT_ID'];
        if (val != null && val.trim().isNotEmpty) return val.trim();
      }
    } catch (_) {}
    return '561060062269-aecas36lfi3o4u58tn14r2h3hf2f2cvv.apps.googleusercontent.com';
  }

  static String get menusUrl => '$baseUrl/menus';
  static String get eventsUrl => '$baseUrl/events';
  static String get booksUrl => '$baseUrl/books';
  static String get registerUrl => '$baseUrl/auth/register';
  static String get loginUrl => '$baseUrl/auth/login';
  static String get googleLoginUrl => '$baseUrl/auth/google-login';
  static String get forgotPasswordUrl => '$baseUrl/auth/forgot-password';
  static String get aiChatUrl => '$baseUrl/ai/chat';
  static String get paymentChargeUrl => '$baseUrl/payment/charge';
  static String get paymentNotificationUrl => '$baseUrl/payment/notification';
  static String paymentStatusUrl(String orderId) => '$baseUrl/payment/status/$orderId';
}
