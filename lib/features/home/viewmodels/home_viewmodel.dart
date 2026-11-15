import 'package:flutter/foundation.dart';
import 'package:mobile_app/core/services/user_session.dart';
import 'package:mobile_app/features/home/models/home_model.dart';
import 'package:mobile_app/features/home/repositories/home_repository.dart';

/// ViewModel untuk mengelola alur navigasi tab dan konten layar Beranda
class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repository;

  int _selectedTabIndex = 0;
  bool _isLoading = false;

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
  List<HomePopularBook> get popularBooks => _popularBooks;
  HomeUpcomingAgenda? get upcomingAgenda => _upcomingAgenda;
  HomeBannerData? get bannerData => _bannerData;
  String get quote => _quote;

  String get userName => UserSession.instance.name;
  String get userInitials => UserSession.instance.initials;

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
