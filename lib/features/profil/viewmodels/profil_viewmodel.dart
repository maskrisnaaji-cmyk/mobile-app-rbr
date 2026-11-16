import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/core/services/user_session.dart';
import 'package:mobile_app/features/profil/models/profil_model.dart';
import 'package:mobile_app/features/profil/repositories/profil_repository.dart';

/// ViewModel untuk mengelola seluruh state dan logika interaksi fitur Profil.
class ProfilViewModel extends ChangeNotifier {
  final ProfilRepository repository;

  ProfilViewModel({ProfilRepository? repository})
      : repository = repository ?? ProfilRepositoryImpl() {
    UserSession.instance.addListener(_onSessionChanged);
    loadProfile();
  }

  UserProfileModel? _profile;
  UserProfileModel? get profile => _profile;

  String get userName => _profile?.name ?? UserSession.instance.name;
  String get userEmail => _profile?.email ?? UserSession.instance.email;
  String? get photoUrl => _profile?.photoUrl ?? UserSession.instance.photoUrl;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  NotificationPreferencesModel _preferences =
      const NotificationPreferencesModel();
  NotificationPreferencesModel get preferences => _preferences;

  List<FaqItemModel> _faqs = [];
  List<FaqItemModel> get faqs => List.unmodifiable(_faqs);

  void _onSessionChanged() {
    loadProfile();
  }

  @override
  void dispose() {
    UserSession.instance.removeListener(_onSessionChanged);
    super.dispose();
  }

  /// Memuat profil pengguna, preferensi, dan daftar FAQ dari repositori.
  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await repository.getUserProfile();
      _faqs = repository.getFaqList();
      _preferences = repository.getNotificationPreferences();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memilih foto dari galeri dan memperbarui profil pengguna.
  Future<bool> pickProfilePhoto({
    required BuildContext context,
    ImagePicker? picker,
  }) async {
    try {
      final imagePicker = picker ?? ImagePicker();
      final selected = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (selected == null) return false;
      if (!context.mounted) return false;

      final cropped = await ImageCropper().cropImage(
        sourcePath: selected.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Atur Foto Profil',
            toolbarColor: const Color(0xFF5B1B14),
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFF8B261D),
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Atur Foto Profil',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
          ),
        ],
      );
      if (cropped == null) return false;

      await updateProfile(
        name: userName,
        photoUrl: cropped.path,
      );
      return true;
    } catch (e) {
      _errorMessage = 'Foto profil tidak dapat dipilih: $e';
      notifyListeners();
      return false;
    }
  }

  /// Memperbarui nama, email, atau foto profil pengguna.
  Future<bool> updateProfile({
    required String name,
    String? email,
    String? photoUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.updateProfile(
        name: name,
        email: email,
        photoUrl: photoUrl,
      );
      _profile = await repository.getUserProfile();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Proses keluar akun (logout) dan menghapus sesi.
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memperbarui kata sandi akun pengguna.
  Future<bool> changePassword({
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.changePassword(
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle preferensi notifikasi jatuh tempo buku.
  void setNotifLoanDue(bool val) {
    _preferences = _preferences.copyWith(notifLoanDue: val);
    repository.saveNotificationPreferences(_preferences);
    notifyListeners();
  }

  /// Toggle preferensi notifikasi agenda & lokakarya.
  void setNotifWorkshopAgenda(bool val) {
    _preferences = _preferences.copyWith(notifWorkshopAgenda: val);
    repository.saveNotificationPreferences(_preferences);
    notifyListeners();
  }

  /// Toggle preferensi kabar kuratorial pustaka.
  void setNotifCuratorArticles(bool val) {
    _preferences = _preferences.copyWith(notifCuratorArticles: val);
    repository.saveNotificationPreferences(_preferences);
    notifyListeners();
  }

  /// Toggle preferensi pemberitahuan via WhatsApp.
  void setNotifWhatsapp(bool val) {
    _preferences = _preferences.copyWith(notifWhatsapp: val);
    repository.saveNotificationPreferences(_preferences);
    notifyListeners();
  }

  /// Toggle preferensi privasi ulasan publik.
  void setPublicReviewProfile(bool val) {
    _preferences = _preferences.copyWith(publicReviewProfile: val);
    repository.saveNotificationPreferences(_preferences);
    notifyListeners();
  }
}
