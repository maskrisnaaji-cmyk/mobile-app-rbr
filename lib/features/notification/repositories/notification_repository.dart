import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/services/user_session.dart';
import 'package:mobile_app/features/notification/models/notification_model.dart';

abstract class NotificationRepository {
  Future<Map<String, dynamic>> fetchNotifications();
  Future<bool> markAsRead(int id);
  Future<bool> markAllAsRead();
}

class NotificationRepositoryImpl implements NotificationRepository {
  Map<String, String> _authHeaders() {
    final token = UserSession.instance.token;
    if (token != null && token.isNotEmpty) {
      return {'Authorization': 'Bearer $token'};
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> fetchNotifications() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.notificationsUrl),
            headers: _authHeaders(),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic> && body['data'] is List) {
          final list = (body['data'] as List)
              .map((item) => AppNotificationModel.fromJson(item as Map<String, dynamic>))
              .toList();

          final int unread = body['unreadCount'] is int
              ? body['unreadCount'] as int
              : list.where((n) => !n.isRead).length;

          return {
            'notifications': list,
            'unreadCount': unread,
          };
        }
      }
    } catch (_) {
      // Abaikan error jaringan, kembalikan list kosong
    }

    return {
      'notifications': <AppNotificationModel>[],
      'unreadCount': 0,
    };
  }

  @override
  Future<bool> markAsRead(int id) async {
    try {
      final response = await http
          .put(
            Uri.parse(ApiConfig.notificationReadUrl(id)),
            headers: _authHeaders(),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> markAllAsRead() async {
    try {
      final response = await http
          .put(
            Uri.parse(ApiConfig.notificationsReadAllUrl),
            headers: _authHeaders(),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
