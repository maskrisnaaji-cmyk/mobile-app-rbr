import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/features/notification/models/notification_model.dart';

abstract class NotificationRepository {
  Future<Map<String, dynamic>> fetchNotifications();
  Future<bool> markAsRead(int id);
  Future<bool> markAllAsRead();
  Future<AppNotificationModel?> simulateProgression({
    String? orderId,
    String? tableNumber,
  });
}

class NotificationRepositoryImpl implements NotificationRepository {
  // Data fallback default jika backend sedang offline
  final List<AppNotificationModel> _fallbackNotifications = [
    AppNotificationModel(
      id: 104,
      orderId: 'RBR-1042',
      title: 'Pesanan Dalam Pengantaran',
      message: 'Pesanan #RBR-1042 sedang diantarkan oleh staf menuju Meja 04. Mohon menunggu sebentar.',
      type: 'order',
      orderStatus: 'Dalam Pengantaran',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    AppNotificationModel(
      id: 103,
      orderId: 'RBR-1042',
      title: 'Pesanan Sedang Diproses',
      message: 'Pesanan #RBR-1042 (Meja 04) sedang diracik oleh Barista kami: Kopi Susu Gula Aren & Pisang Goreng.',
      type: 'order',
      orderStatus: 'Sedang Diproses',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    AppNotificationModel(
      id: 102,
      orderId: 'RBR-1042',
      title: 'Pesanan Baru Dibuat',
      message: 'Pesanan #RBR-1042 berhasil dibuat dan menunggu konfirmasi pembayaran/barista.',
      type: 'order',
      orderStatus: 'Pesanan Dibuat',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    AppNotificationModel(
      id: 101,
      orderId: 'TKT-3041',
      title: 'E-Tiket Terkonfirmasi',
      message: 'Pendaftaran acara "Napak Tanah Jilid II" berhasil. Siapkan e-tiket saat hadir di lokasi.',
      type: 'event',
      orderStatus: 'Selesai',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 24)),
    ),
  ];

  @override
  Future<Map<String, dynamic>> fetchNotifications() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.notificationsUrl))
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic> && body['data'] is List) {
          final list = (body['data'] as List)
              .map((item) => AppNotificationModel.fromJson(item as Map<String, dynamic>))
              .toList();

          int unread = body['unreadCount'] is int
              ? body['unreadCount'] as int
              : list.where((n) => !n.isRead).length;

          // Jika DB masih kosong, sediakan fallback interaktif
          if (list.isEmpty) {
            return {
              'notifications': List<AppNotificationModel>.from(_fallbackNotifications),
              'unreadCount': _fallbackNotifications.where((n) => !n.isRead).length,
            };
          }

          return {
            'notifications': list,
            'unreadCount': unread,
          };
        }
      }
    } catch (_) {
      // Fallback offline aman
    }

    return {
      'notifications': List<AppNotificationModel>.from(_fallbackNotifications),
      'unreadCount': _fallbackNotifications.where((n) => !n.isRead).length,
    };
  }

  @override
  Future<bool> markAsRead(int id) async {
    try {
      final response = await http
          .put(Uri.parse(ApiConfig.notificationReadUrl(id)))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<bool> markAllAsRead() async {
    try {
      final response = await http
          .put(Uri.parse(ApiConfig.notificationsReadAllUrl))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<AppNotificationModel?> simulateProgression({
    String? orderId,
    String? tableNumber,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.notificationsSimulateUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'order_id': orderId ?? 'RBR-1042',
              'table_number': tableNumber ?? 'Meja 04',
            }),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['data'] != null) {
          return AppNotificationModel.fromJson(body['data']);
        }
      }
    } catch (_) {}
    return null;
  }
}
