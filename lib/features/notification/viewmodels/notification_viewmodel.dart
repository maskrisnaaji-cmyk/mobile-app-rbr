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
    if (_selectedFilter == 'Pembayaran') {
      return _notifications.where((n) {
        final t = n.type.toLowerCase();
        final title = n.title.toLowerCase();
        return t.contains('payment') ||
            t.contains('order') ||
            title.contains('pembayaran') ||
            title.contains('pesanan');
      }).toList();
    }
    if (_selectedFilter == 'Aktivitas') {
      return _notifications.where((n) {
        final t = n.type.toLowerCase();
        return t.contains('event') ||
            t.contains('activity') ||
            t.contains('general') ||
            t.contains('agenda') ||
            t.contains('pustaka');
      }).toList();
    }
    if (_selectedFilter == 'Belum Dibaca') {
      return _notifications.where((n) => !n.isRead).toList();
    }
    return _notifications;
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
}
