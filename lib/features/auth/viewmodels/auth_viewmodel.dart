import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_app/features/auth/models/auth_user_model.dart';
import 'package:mobile_app/features/auth/repositories/auth_repository.dart';

/// ViewModel untuk mengelola state dan alur bisnis autentikasi (Login, Register, Google Sign-In, Forgot Password)
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;
  AuthUser? _currentUser;

  bool _isForgotPasswordSuccess = false;
  String? _forgotPasswordRecipient;

  AuthViewModel({AuthRepository? repository})
      : _repository = repository ?? AuthRepositoryImpl();

  bool get isLoading => _isLoading;
  bool get isGoogleLoading => _isGoogleLoading;
  String? get errorMessage => _errorMessage;
  AuthUser? get currentUser => _currentUser;
  bool get isForgotPasswordSuccess => _isForgotPasswordSuccess;
  String? get forgotPasswordRecipient => _forgotPasswordRecipient;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetForgotPasswordState() {
    _isForgotPasswordSuccess = false;
    _forgotPasswordRecipient = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Eksekusi alur login email & password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.login(
        email: email,
        password: password,
      );
      _currentUser = response.user;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Eksekusi alur registrasi pengguna baru
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      _currentUser = response.user;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Eksekusi alur masuk menggunakan Google
  Future<bool> loginWithGoogle() async {
    if (_isGoogleLoading || _isLoading) return false;

    _isGoogleLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleIdentity? googleUser;
      try {
        googleUser = await _repository.signInWithGoogleSdk();
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          _isGoogleLoading = false;
          notifyListeners();
          return false;
        }
        rethrow;
      }

      if (googleUser != null) {
        final response = await _repository.processGoogleBackendLogin(
          email: googleUser.email,
          name: googleUser.displayName,
          photoUrl: googleUser.photoUrl,
          googleId: googleUser.id,
        );
        _currentUser = response.user;
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Kendala saat masuk dengan Google: ${e.toString().replaceFirst("Exception: ", "")}';
      return false;
    } finally {
      _isGoogleLoading = false;
      notifyListeners();
    }
  }

  /// Eksekusi alur reset kata sandi
  Future<bool> forgotPassword(String identifier) async {
    _isLoading = true;
    _errorMessage = null;
    _isForgotPasswordSuccess = false;
    notifyListeners();

    try {
      await _repository.forgotPassword(identifier);
      _isForgotPasswordSuccess = true;
      _forgotPasswordRecipient = identifier;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
