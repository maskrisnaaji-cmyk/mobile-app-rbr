/// Utility helper untuk validasi input form (email, password, phone, nama)
class AppValidator {
  AppValidator._();

  /// Validasi email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email / No. HP tidak boleh kosong';
    }
    return null;
  }

  /// Validasi kata sandi
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kata sandi tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }
    return null;
  }

  /// Validasi nama lengkap
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap tidak boleh kosong';
    }
    return null;
  }

  /// Validasi nomor telepon
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor handphone tidak boleh kosong';
    }
    return null;
  }
}
