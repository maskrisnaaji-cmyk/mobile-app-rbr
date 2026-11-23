import 'package:flutter/material.dart';
import 'package:mobile_app/features/notification/models/notification_model.dart';
import 'package:mobile_app/features/notification/repositories/notification_repository.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository;

  static final NotificationViewModel instance = NotificationViewModel();

  NotificationViewModel({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepositoryImpl();

  List<AppNotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String _selectedFilter = 'Semua';

  List<AppNotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;
  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;

  List<AppNotificationModel> get filteredNotifications {
    if (_selectedFilter == 'Pesanan') {
      return _notifications.where((n) => n.type == 'order').toList();
    }
    if (_selectedFilter == 'Belum Dibaca') {
      return _notifications.where((n) => !n.isRead).toList();
    }
    return _notifications;
  }

  /// Mengambil notifikasi pesanan aktif terbaru yang belum selesai (untuk ringkasan status)
  AppNotificationModel? get latestActiveOrderNotification {
    try {
      final activeOrders = _notifications.where((n) => n.type == 'order').toList();
      if (activeOrders.isNotEmpty) {
        return activeOrders.first;
      }
    } catch (_) {}
    return null;
  }

  void setFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  /// Memuat notifikasi dari backend/repository
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _repository.fetchNotifications();
      _notifications = res['notifications'] as List<AppNotificationModel>;
      _unreadCount = res['unreadCount'] as int;
    } catch (_) {
      // Pertahankan data yang ada
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menandai satu notifikasi sebagai telah dibaca
  Future<void> markAsRead(int id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();
      await _repository.markAsRead(id);
    }
  }

  /// Menandai semua notifikasi telah dibaca
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();
    await _repository.markAllAsRead();
  }

  /// Mensimulasikan progres status pesanan berikutnya:
  /// Dibuat -> Diproses -> Diantar -> Selesai
  Future<void> simulateNextStep({String? orderId, String? tableNumber}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newNotif = await _repository.simulateProgression(
        orderId: orderId,
        tableNumber: tableNumber,
      );

      if (newNotif != null) {
        _notifications.insert(0, newNotif);
        _unreadCount++;
      } else {
        // Fallback simulasi offline di state lokal
        final latest = latestActiveOrderNotification;
        final currentStep = latest?.stepIndex ?? 3;
        final nextStep = (currentStep + 1) % 4;

        String nextStatusTitle;
        String nextStatusMessage;
        String nextStatusLabel;

        final ord = orderId ?? latest?.orderId ?? 'RBR-1042';
        final tbl = tableNumber ?? 'Meja 04';

        switch (nextStep) {
          case 0:
            nextStatusLabel = 'Pesanan Dibuat';
            nextStatusTitle = 'Pesanan Baru Dibuat';
            nextStatusMessage = 'Pesanan #$ord ($tbl) berhasil dibuat dan menunggu konfirmasi kasir/barista.';
            break;
          case 1:
            nextStatusLabel = 'Sedang Diproses';
            nextStatusTitle = 'Pesanan Sedang Diproses';
            nextStatusMessage = 'Pesanan #$ord ($tbl) sedang diracik oleh Barista kami dengan teliti.';
            break;
          case 2:
            nextStatusLabel = 'Dalam Pengantaran';
            nextStatusTitle = 'Pesanan Dalam Pengantaran';
            nextStatusMessage = 'Pesanan #$ord sedang diantarkan oleh staf menuju $tbl.';
            break;
          case 3:
          default:
            nextStatusLabel = 'Selesai';
            nextStatusTitle = 'Pesanan Selesai';
            nextStatusMessage = 'Pesanan #$ord telah selesai diantar ke $tbl. Selamat menikmati sajian Rumah Budaya Ratna!';
            break;
        }

        final simulatedNotif = AppNotificationModel(
          id: DateTime.now().millisecondsSinceEpoch,
          orderId: ord,
          title: nextStatusTitle,
          message: nextStatusMessage,
          type: 'order',
          orderStatus: nextStatusLabel,
          isRead: false,
          createdAt: DateTime.now(),
        );

        _notifications.insert(0, simulatedNotif);
        _unreadCount++;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
