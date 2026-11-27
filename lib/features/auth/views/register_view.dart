import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/di/injection.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/core/utils/app_validator.dart';
import 'package:mobile_app/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:mobile_app/features/auth/widgets/auth_success_dialog.dart';

class RegisterView extends StatefulWidget {
  final AuthViewModel? viewModel;

  const RegisterView({super.key, this.viewModel});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final AuthViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _agreeTerms = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? AppInjection.createAuthViewModel();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Anda harus menyetujui Syarat & Ketentuan serta Kebijakan Privasi.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    final success = await _viewModel.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    if (!mounted) return;

    if (success) {
      await showAuthSuccessDialog(
        context: context,
        title: 'Akun Berhasil Dibuat!',
        userName: name,
        customMessage:
            'Selamat bergabung di Rumah Budaya Ratna, $name!\nAkun Anda telah aktif dan siap digunakan untuk menjelajahi kekayaan budaya dan literasi.',
      );
    } else if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
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
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Back Button Bar
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.textMain),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Top Logo
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/rbr_front.jpeg',
                              width: 92,
                              height: 92,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'RUMAH BUDAYA RATNA',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: AppColors.maroon,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'DAFTAR AKUN BARU',
                            style: GoogleFonts.lora(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lengkapi data Anda untuk bergabung dalam ruang preservasi & dokumentasi budaya Indonesia.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              color: AppColors.textMuted,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Input Nama Lengkap
                          _buildInputLabel('Nama Lengkap'),
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration('Contoh: Aris Widiatmoko', Icons.person_outline),
                            validator: AppValidator.validateName,
                          ),
                          const SizedBox(height: 14),

                          // Input Email
                          _buildInputLabel('Email'),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration('Contoh: aris@gmail.com', Icons.email_outlined),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Email tidak boleh kosong';
                              }
                              if (!val.contains('@') || !val.contains('.')) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Input No HP
                          _buildInputLabel('Nomor Telepon'),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text('+62', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: _inputDecoration('812-3456-7890', Icons.phone_outlined),
                                  validator: AppValidator.validatePhone,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Input Password
                          _buildInputLabel('Kata Sandi'),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Minimal 6 karakter',
                              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                              prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.textMuted),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  size: 18,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
                              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
                            ),
                            validator: AppValidator.validatePassword,
                          ),
                          const SizedBox(height: 14),

                          // Terms Checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _agreeTerms,
                                  activeColor: AppColors.maroon,
                                  onChanged: (val) => setState(() => _agreeTerms = val ?? false),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textMuted),
                                    children: [
                                      const TextSpan(text: 'Saya menyetujui '),
                                      TextSpan(
                                        text: 'Syarat & Ketentuan',
                                        style: GoogleFonts.plusJakartaSans(color: AppColors.maroon, fontWeight: FontWeight.bold),
                                      ),
                                      const TextSpan(text: ' serta '),
                                      TextSpan(
                                        text: 'Kebijakan Privasi',
                                        style: GoogleFonts.plusJakartaSans(color: AppColors.maroon, fontWeight: FontWeight.bold),
                                      ),
                                      const TextSpan(text: ' Rumah Budaya Ratna.'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Tombol Daftar
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _viewModel.isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.maroon,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.maroon.withValues(alpha: 0.6),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 2,
                              ),
                              child: _viewModel.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'DAFTAR SEKARANG',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward, size: 16),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Navigasi Kembali ke Login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sudah punya akun? ',
                                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Text(
                                  'Masuk',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.maroon,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
      prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5)),
    );
  }
}
