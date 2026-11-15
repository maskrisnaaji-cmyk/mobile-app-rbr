import 'package:mobile_app/features/auth/repositories/auth_repository.dart';
import 'package:mobile_app/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:mobile_app/features/home/repositories/home_repository.dart';
import 'package:mobile_app/features/home/viewmodels/home_viewmodel.dart';

/// Service Locator / Injeksi Ketergantungan (Dependency Injection) Sederhana
/// Mengatur pembuatan dan penyediaan instance Repository & ViewModel
class AppInjection {
  AppInjection._();

  static AuthRepository? _authRepository;
  static HomeRepository? _homeRepository;

  /// Menyediakan instance [AuthRepository]
  static AuthRepository get authRepository {
    _authRepository ??= AuthRepositoryImpl();
    return _authRepository!;
  }

  /// Menyediakan instance [HomeRepository]
  static HomeRepository get homeRepository {
    _homeRepository ??= HomeRepositoryImpl();
    return _homeRepository!;
  }

  /// Factory untuk membuat [AuthViewModel] baru
  static AuthViewModel createAuthViewModel() {
    return AuthViewModel(repository: authRepository);
  }

  /// Factory untuk membuat [HomeViewModel] baru
  static HomeViewModel createHomeViewModel() {
    return HomeViewModel(repository: homeRepository);
  }
}
