import 'package:flutter/material.dart';

/// Model untuk data notifikasi transaksi, pesanan, dan aktivitas aplikasi
class AppNotificationModel {
  final int id;
  final dynamic userId;
  final String? orderId;
  final String title;
  final String message;
  final String type; // 'order', 'event', 'general'
  final String orderStatus; // 'Pesanan Dibuat', 'Sedang Diproses', 'Dalam Pengantaran', 'Selesai'
  final bool isRead;
  final DateTime? createdAt;

  const AppNotificationModel({
    required this.id,
    this.userId,
    this.orderId,
    required this.title,
    required this.message,
    this.type = 'order',
    this.orderStatus = 'Pesanan Dibuat',
    this.isRead = false,
    this.createdAt,
  });

  /// Status step (0: Dibuat/Menunggu, 1: Diproses/Disiapkan, 2: Diantar/Pengantaran, 3: Selesai/Diterima)
  int get stepIndex {
    final s = orderStatus.toLowerCase();
    if (s.contains('selesai') || s.contains('diterima') || s.contains('hadir')) {
      return 3;
    }
    if (s.contains('antar') || s.contains('kirim') || s.contains('jalan')) {
      return 2;
    }
    if (s.contains('proses') || s.contains('siap') || s.contains('racik')) {
      return 1;
    }
    return 0; // default dibuat / menunggu pembayaran
  }

  /// Warna representatif status
  Color get statusColor {
    switch (stepIndex) {
      case 3:
        return const Color(0xFF16A34A); // Hijau sukses
      case 2:
        return const Color(0xFF7C3AED); // Ungu pengantaran
      case 1:
        return const Color(0xFF2563EB); // Biru proses
      case 0:
      default:
        return const Color(0xFFD97706); // Oranye/amber dibuat
    }
  }

  /// Background badge warna pastel
  Color get statusBgColor {
    switch (stepIndex) {
      case 3:
        return const Color(0xFFDCFCE7);
      case 2:
        return const Color(0xFFEDE9FE);
      case 1:
        return const Color(0xFFDBEAFE);
      case 0:
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  /// Icon representatif alur status order
  IconData get statusIcon {
    switch (stepIndex) {
      case 3:
        return Icons.check_circle_rounded;
      case 2:
        return Icons.delivery_dining_rounded;
      case 1:
        return Icons.soup_kitchen_rounded;
      case 0:
      default:
        return Icons.receipt_long_rounded;
    }
  }

  /// Label singkat status untuk pill badge
  String get displayStatus {
    switch (stepIndex) {
      case 3:
        return 'Selesai';
      case 2:
        return 'Sedang Diantar';
      case 1:
        return 'Sedang Disiapkan';
      case 0:
      default:
        return 'Pesanan Dibuat';
    }
  }

  /// Formatted date string
  String get timeFormatted {
    if (createdAt == null) return 'Baru saja';
    final now = DateTime.now();
    final diff = now.difference(createdAt!);
    if (diff.inMinutes < 1) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} mnt lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
    }
  }

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['created_at'] != null) {
      parsedDate = DateTime.tryParse(json['created_at'].toString())?.toLocal();
    }

    final rawIsRead = json['is_read'];
    final bool isReadVal = rawIsRead == true || rawIsRead == 1 || rawIsRead == '1';

    return AppNotificationModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'],
      orderId: json['order_id']?.toString(),
      title: json['title']?.toString() ?? 'Notifikasi Transaksi',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'order',
      orderStatus: json['order_status']?.toString() ?? 'Pesanan Dibuat',
      isRead: isReadVal,
      createdAt: parsedDate,
    );
  }

  AppNotificationModel copyWith({
    int? id,
    dynamic userId,
    String? orderId,
    String? title,
    String? message,
    String? type,
    String? orderStatus,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderId: orderId ?? this.orderId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      orderStatus: orderStatus ?? this.orderStatus,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
