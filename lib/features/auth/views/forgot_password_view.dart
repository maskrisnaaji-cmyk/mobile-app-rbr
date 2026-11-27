import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/di/injection.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/features/auth/viewmodels/auth_viewmodel.dart';

class ForgotPasswordView extends StatefulWidget {
  final AuthViewModel? viewModel;

  const ForgotPasswordView({super.key, this.viewModel});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final AuthViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? AppInjection.createAuthViewModel();
    _viewModel.resetForgotPasswordState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final success = await _viewModel.verifyAccount(email, phone);

    if (!mounted) return;

    if (!success && _viewModel.errorMessage != null) {
      _showErrorSnackBar(_viewModel.errorMessage!);
    }
  }

  Future<void> _handleSaveNewPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _viewModel.submitNewPassword(
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1B5E20),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kata sandi berhasil diperbarui. Silakan masuk dengan kata sandi baru.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
      Navigator.pop(context);
    } else if (_viewModel.errorMessage != null) {
      _showErrorSnackBar(_viewModel.errorMessage!);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFC62828),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool isReadOnly = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        color: AppColors.textMuted.withValues(alpha: 0.7),
      ),
      filled: true,
      fillColor: isReadOnly ? const Color(0xFFF3EFEA) : Colors.white,
      prefixIcon: Icon(
        prefixIcon,
        size: 18,
        color: AppColors.textMuted,
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.maroon, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final isAccountVerified = _viewModel.isAccountVerified;
        final errorMessage = _viewModel.errorMessage;
        final isLoading = _viewModel.isLoading;

        return Scaffold(
          backgroundColor: const Color(0xFF1E1C1A),
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 430),
              decoration: BoxDecoration(
                color: AppColors.cream,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 25,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Scaffold(
                backgroundColor: AppColors.cream,
                appBar: AppBar(
                  backgroundColor: AppColors.cream,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textMain),
                    tooltip: 'Kembali',
                  ),
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),

                        // Logo Icon Header (Brand Identity)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/rbr_front.jpeg',
                            width: 92,
                            height: 92,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Judul Layar
                        Text(
                          'Atur Ulang Kata Sandi',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lora(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Teks Penjelas (Helper Text)
                        Text(
                          isAccountVerified
                              ? 'Akun Anda telah terverifikasi. Silakan buat kata sandi baru untuk akun Rumah Budaya Ratna Anda.'
                              : 'Masukkan Email dan No. Handphone yang terdaftar di akun Rumah Budaya Ratna Anda untuk verifikasi.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Banner Info Akun Terverifikasi (Tahap 2)
                        if (isAccountVerified)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 18),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFA5D6A7)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_user_rounded, color: Color(0xFF2E7D32), size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Akun terverifikasi! Silakan masukkan kata sandi baru.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1B5E20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Notifikasi Error (jika ada)
                        if (errorMessage != null)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFFCDD2)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Color(0xFFC62828), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      color: const Color(0xFFB71C1C),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Form 2 Tahap
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Input Email
                              Text(
                                'Email',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                enabled: !isLoading && !isAccountVerified,
                                readOnly: isAccountVerified,
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMain),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Email wajib diisi';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Format email tidak valid';
                                  }
                                  return null;
                                },
                                decoration: _buildInputDecoration(
                                  hintText: 'nama@email.com',
                                  prefixIcon: Icons.mail_outline_rounded,
                                  isReadOnly: isAccountVerified,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Input No. Handphone
                              Text(
                                'No. Handphone',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                enabled: !isLoading && !isAccountVerified,
                                readOnly: isAccountVerified,
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMain),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'No. Handphone wajib diisi';
                                  }
                                  if (value.trim().length < 8) {
                                    return 'Format No. Handphone tidak valid';
                                  }
                                  return null;
                                },
                                decoration: _buildInputDecoration(
                                  hintText: '08123456789',
                                  prefixIcon: Icons.phone_android_rounded,
                                  isReadOnly: isAccountVerified,
                                ),
                              ),

                              // Tahap 2: Input Kata Sandi Baru & Konfirmasi
                              if (isAccountVerified) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Kata Sandi Baru',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMain,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _newPasswordController,
                                  obscureText: _obscureNewPassword,
                                  enabled: !isLoading,
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMain),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Kata sandi baru wajib diisi';
                                    }
                                    if (value.length < 6) {
                                      return 'Kata sandi minimal 6 karakter';
                                    }
                                    return null;
                                  },
                                  decoration: _buildInputDecoration(
                                    hintText: 'Minimal 6 karakter',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        size: 18,
                                        color: AppColors.textMuted,
                                      ),
                                      onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Konfirmasi Kata Sandi Baru',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMain,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  enabled: !isLoading,
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMain),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Konfirmasi kata sandi wajib diisi';
                                    }
                                    if (value != _newPasswordController.text) {
                                      return 'Konfirmasi kata sandi tidak cocok';
                                    }
                                    return null;
                                  },
                                  decoration: _buildInputDecoration(
                                    hintText: 'Ulangi kata sandi baru',
                                    prefixIcon: Icons.lock_reset_rounded,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        size: 18,
                                        color: AppColors.textMuted,
                                      ),
                                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 22),

                              // Tombol Utama: Verifikasi Akun (Tahap 1) / Simpan Kata Sandi (Tahap 2)
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : (isAccountVerified ? _handleSaveNewPassword : _handleVerifyAccount),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.maroon,
                                    foregroundColor: Colors.white,
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          isAccountVerified ? 'Simpan Kata Sandi' : 'Verifikasi Akun',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Tautan Kembali: <- Kembali ke Halaman Masuk
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.arrow_back_rounded,
                              size: 14,
                              color: AppColors.maroon,
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'Kembali ke Halaman Masuk',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.maroon,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
