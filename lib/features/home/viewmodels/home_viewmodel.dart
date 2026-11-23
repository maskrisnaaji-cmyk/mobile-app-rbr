import 'package:flutter/material.dart';
import 'package:mobile_app/core/services/user_session.dart';
import 'package:mobile_app/features/home/models/home_model.dart';
import 'package:mobile_app/features/home/repositories/home_repository.dart';

/// ViewModel untuk mengelola alur navigasi tab dan konten layar Beranda
class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repository;

  int _selectedTabIndex = 0;
  bool _isLoading = false;
  String _searchQuery = '';

  List<HomePopularBook> _popularBooks = [];
  HomeUpcomingAgenda? _upcomingAgenda;
  HomeBannerData? _bannerData;
  String _quote = '';

  HomeViewModel({HomeRepository? repository})
      : _repository = repository ?? HomeRepositoryImpl() {
    UserSession.instance.addListener(_onSessionChanged);
    loadHomeData();
  }

  int get selectedTabIndex => _selectedTabIndex;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get isSearching => _searchQuery.isNotEmpty;

  List<HomePopularBook> get popularBooks => _popularBooks;
  HomeUpcomingAgenda? get upcomingAgenda => _upcomingAgenda;
  HomeBannerData? get bannerData => _bannerData;
  String get quote => _quote;

  String get userName => UserSession.instance.name;
  String get userInitials => UserSession.instance.initials;

  /// Memperbarui query pencarian Beranda
  void updateSearch(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  /// Menghapus query pencarian Beranda
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Daftar fitur, layanan, dan agenda Beranda yang disaring sesuai konteks Beranda
  List<HomeSearchResult> get searchResults {
    if (_searchQuery.isEmpty) return const [];

    final q = _searchQuery;
    final List<HomeSearchResult> allItems = [
      const HomeSearchResult(
        title: 'Kedai Kopi & Galeri',
        subtitle: 'Pesan kopi nusantara, seduh manual, dan kudapan',
        category: 'Layanan & Menu',
        icon: Icons.coffee_outlined,
        targetTab: 1,
      ),
      const HomeSearchResult(
        title: 'Pustaka Ratna & Manuskrip',
        subtitle: 'Koleksi naskah kuno, sastra budaya, dan buku fisik',
        category: 'Layanan Literasi',
        icon: Icons.menu_book_outlined,
        targetTab: 2,
      ),
      const HomeSearchResult(
        title: 'Agenda Acara & Lokakarya',
        subtitle: 'Jadwal pentas seni, workshop, dan tiket presale budaya',
        category: 'Kegiatan Budaya',
        icon: Icons.calendar_month_outlined,
        targetTab: 3,
      ),
      const HomeSearchResult(
        title: 'Profil & Keanggotaan',
        subtitle: 'Pengaturan akun, riwayat transaksi, dan pusat bantuan',
        category: 'Akun Pengguna',
        icon: Icons.person_outline,
        targetTab: 4,
      ),
      const HomeSearchResult(
        title: 'Reservasi Meja Kedai',
        subtitle: 'Pilih nomor meja kosong untuk santap di kedai',
        category: 'Layanan Kedai',
        icon: Icons.chair_alt_outlined,
        targetTab: 1,
      ),
      const HomeSearchResult(
        title: 'Pengajuan Lokakarya',
        subtitle: 'Ajukan workshop baru untuk ditinjau oleh pengelola',
        category: 'Kolaborasi Budaya',
        icon: Icons.handshake_outlined,
        targetTab: 3,
      ),
    ];

    final results = allItems.where((item) {
      final matchTitle = item.title.toLowerCase().contains(q);
      final matchSubtitle = item.subtitle.toLowerCase().contains(q);
      final matchCategory = item.category.toLowerCase().contains(q);
      return matchTitle || matchSubtitle || matchCategory;
    }).toList();

    // Cek juga kecocokan dengan agenda kegiatan terdekat
    if (_upcomingAgenda != null) {
      final ag = _upcomingAgenda!;
      final matchAgendaTitle = ag.title.toLowerCase().contains(q);
      final matchAgendaLoc = ag.timeLocation.toLowerCase().contains(q);
      if (matchAgendaTitle || matchAgendaLoc) {
        results.insert(
          0,
          HomeSearchResult(
            title: ag.title,
            subtitle: '${ag.day}, ${ag.date} ${ag.month} • ${ag.timeLocation}',
            category: 'Agenda Mendatang',
            icon: Icons.event_available_outlined,
            targetTab: 3,
          ),
        );
      }
    }

    // Cek juga kecocokan dengan banner cagar budaya
    if (_bannerData != null) {
      final b = _bannerData!;
      if (b.title.toLowerCase().contains(q) ||
          b.description.toLowerCase().contains(q) ||
          b.tag.toLowerCase().contains(q)) {
        results.add(
          HomeSearchResult(
            title: b.title,
            subtitle: b.description,
            category: 'Cagar Budaya',
            icon: Icons.other_houses_outlined,
            targetTab: 0,
          ),
        );
      }
    }

    return results;
  }

  void setTabIndex(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  void _onSessionChanged() {
    notifyListeners();
  }

  Future<void> loadHomeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getPopularBooks(),
        _repository.getUpcomingAgenda(),
        _repository.getBannerData(),
        _repository.getQuote(),
      ]);

      _popularBooks = results[0] as List<HomePopularBook>;
      _upcomingAgenda = results[1] as HomeUpcomingAgenda;
      _bannerData = results[2] as HomeBannerData;
      _quote = results[3] as String;
    } catch (_) {
      // Menggunakan fallback jika ada kesalahan
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    UserSession.instance.removeListener(_onSessionChanged);
    super.dispose();
  }
}
