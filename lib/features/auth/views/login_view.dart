import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/di/injection.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/core/utils/app_validator.dart';
import 'package:mobile_app/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:mobile_app/features/auth/views/forgot_password_view.dart';
import 'package:mobile_app/features/auth/views/register_view.dart';
import 'package:mobile_app/features/auth/widgets/auth_header_widget.dart';
import 'package:mobile_app/features/auth/widgets/auth_success_dialog.dart';
import 'package:mobile_app/features/auth/widgets/auth_text_field.dart';
import 'package:mobile_app/features/auth/widgets/google_sign_in_button.dart';

class LoginView extends StatefulWidget {
  final AuthViewModel? viewModel;

  const LoginView({super.key, this.viewModel});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final AuthViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? AppInjection.createAuthViewModel();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_viewModel.isLoading || _viewModel.isGoogleLoading) return;
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await _viewModel.login(email, password);

    if (!mounted) return;

    if (success) {
      await showAuthSuccessDialog(
        context: context,
        userName: _viewModel.currentUser?.name,
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

  Future<void> _handleGoogleSignIn() async {
    if (_viewModel.isGoogleLoading || _viewModel.isLoading) return;

    final success = await _viewModel.loginWithGoogle();

    if (!mounted) return;

    if (success) {
      await showAuthSuccessDialog(
        context: context,
        userName: _viewModel.currentUser?.name,
      );
    } else if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const AuthHeaderWidget(),
                        const SizedBox(height: 24),

                        // Form Validator untuk Email & Password
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AuthTextField(
                                label: 'Email / No. Handphone',
                                hintText: 'Contoh: user@rbr.com',
                                controller: _emailController,
                                prefixIcon: Icons.email_outlined,
                                enabled: !_viewModel.isLoading,
                                validator: AppValidator.validateEmail,
                              ),
                              const SizedBox(height: 14),

                              AuthTextField(
                                label: 'Kata Sandi',
                                hintText: '••••••••',
                                controller: _passwordController,
                                prefixIcon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                enabled: !_viewModel.isLoading,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Kata sandi tidak boleh kosong';
                                  }
                                  return null;
                                },
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    size: 18,
                                    color: AppColors.textMuted,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),

                              // Lupa Kata Sandi
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ForgotPasswordView(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Lupa Kata Sandi?',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.maroon,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Tombol Masuk
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: (_viewModel.isLoading || _viewModel.isGoogleLoading)
                                      ? null
                                      : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.maroon,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: AppColors.maroon.withValues(alpha: 0.6),
                                    disabledForegroundColor: Colors.white70,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 2,
                                  ),
                                  child: _viewModel.isLoading
                                      ? const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              'MEMPROSES...',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'MASUK',
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppColors.border)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'atau masuk dengan',
                                style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textMuted),
                              ),
                            ),
                            const Expanded(child: Divider(color: AppColors.border)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Masuk dengan Google
                        GoogleSignInButton(
                          onPressed: _handleGoogleSignIn,
                          isLoading: _viewModel.isGoogleLoading,
                        ),
                        const SizedBox(height: 24),

                        // Link ke Halaman Daftar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Belum punya akun? ',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RegisterView()),
                                );
                              },
                              child: Text(
                                'Daftar',
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
        );
      },
    );
  }
}
