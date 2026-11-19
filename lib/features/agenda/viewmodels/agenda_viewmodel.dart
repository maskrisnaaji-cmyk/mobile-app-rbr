import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_app/features/agenda/models/event_model.dart';
import 'package:mobile_app/features/agenda/repositories/agenda_repository.dart';

/// ViewModel untuk mengelola state dan logika bisnis pada fitur Agenda
class AgendaViewModel extends ChangeNotifier {
  final AgendaRepository repository;
  Timer? _autoRefreshTimer;

  AgendaViewModel({AgendaRepository? repository})
      : repository = repository ?? AgendaRepositoryImpl();

  bool _isLoading = true;
  String? _errorMessage;
  List<EventModel> _allEvents = [];

  // Filter Bulan & Tanggal
  DateTime _currentMonth = DateTime(2026, 9); // Default ke September 2026 (sesuai data acara RBR)
  int? _selectedDate;

  // ── Getters ─────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<EventModel> get allEvents => _allEvents;
  DateTime get currentMonth => _currentMonth;
  int? get selectedDate => _selectedDate;

  /// Memulai sinkronisasi otomatis status tiket dan kuota secara berkala (tiap 5–8 detik)
  void startAutoRefresh([Duration interval = const Duration(seconds: 6)]) {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(interval, (_) {
      fetchEvents(silent: true);
    });
  }

  /// Menghentikan sinkronisasi otomatis
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }

  /// Event yang disaring berdasarkan bulan aktif dan tanggal yang dipilih
  List<EventModel> get filteredEvents {
    return _allEvents.where((event) {
      final dt = event.dateTime;
      if (dt == null) return false;

      // Filter Bulan & Tahun
      final matchMonth =
          dt.year == _currentMonth.year && dt.month == _currentMonth.month;
      if (!matchMonth) return false;

      // Filter Tanggal Spesifik (jika ada yang dipilih)
      if (_selectedDate != null) {
        return dt.day == _selectedDate;
      }
      return true;
    }).toList();
  }

  /// Daftar tanggal unik yang memiliki acara pada bulan terpilih (diurutkan ASCENDING)
  List<int> get datesWithEventsInCurrentMonth {
    final Set<int> dates = {};
    for (var event in _allEvents) {
      final dt = event.dateTime;
      if (dt != null &&
          dt.year == _currentMonth.year &&
          dt.month == _currentMonth.month) {
        dates.add(dt.day);
      }
    }
    final list = dates.toList()..sort();
    return list;
  }

  // ── Logika & Aksi Data ──────────────────────────────────────────────────

  /// Mengambil data agenda secara dinamis dari repositori
  Future<void> fetchEvents({bool silent = false}) async {
    final isInitialLoad = _allEvents.isEmpty;
    if (!silent) {
      if (isInitialLoad) {
        _isLoading = true;
      }
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final events = await repository.getEvents();
      _allEvents = events;
      _isLoading = false;
      _errorMessage = null;

      // Jika baru pertama kali / belum ada tanggal dipilih, arahkan ke bulan event pertama
      if (_allEvents.isNotEmpty && isInitialLoad && _selectedDate == null) {
        final datesWithEvents = _allEvents
            .where((e) => e.dateTime != null)
            .map((e) => e.dateTime!)
            .where((dt) => dt.year >= 2020 && dt.year <= 2100)
            .toList();
        if (datesWithEvents.isNotEmpty) {
          datesWithEvents.sort((a, b) => a.compareTo(b));
          _currentMonth = DateTime(
            datesWithEvents.first.year,
            datesWithEvents.first.month,
          );
        }
      }
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      if (!silent && _allEvents.isEmpty) {
        _errorMessage = 'Tidak dapat terhubung ke server backend.';
      }
      notifyListeners();
    }
  }

  /// Navigasi ke bulan sebelumnya
  void prevMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    _selectedDate = null;
    notifyListeners();
  }

  /// Navigasi ke bulan selanjutnya
  void nextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    _selectedDate = null;
    notifyListeners();
  }

  /// Memilih bulan langsung dari dropdown
  void selectMonth(int month) {
    _currentMonth = DateTime(_currentMonth.year, month);
    _selectedDate = null;
    notifyListeners();
  }

  /// Memilih tanggal spesifik (atau null untuk semua tanggal)
  void selectDate(int? date) {
    _selectedDate = date;
    notifyListeners();
  }
}
