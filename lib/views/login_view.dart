import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import 'main_screen.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  /// URL endpoint autentikasi backend
  /// Menggunakan 10.0.2.2 untuk Android Emulator, dan localhost untuk Web/Desktop/iOS
  String get _loginUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/auth/login';
    } else {
      try {
        if (Platform.isAndroid) {
          return 'http://10.0.2.2:5000/api/auth/login';
        }
      } catch (_) {}
      return 'http://localhost:5000/api/auth/login';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Fungsi login tersambung ke backend Express.js & MySQL
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Simpan token JWT dan data user ke SharedPreferences
        final token = data['token'] as String?;
        final user = data['user'];
        String? userName;

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          if (user != null) {
            await prefs.setString('user', jsonEncode(user));
            if (user is Map && user['name'] != null) {
              userName = user['name'].toString();
            }
          }
        }

        if (!mounted) return;

        // Tampilkan Dialog Pop-up Sukses modern beranimasi
        await _showSuccessDialog(userName: userName);
      } else {
        // Tampilkan pesan error jika login gagal
        if (!mounted) return;
        final errorMsg = data['message'] ?? 'Email atau kata sandi tidak valid.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal terhubung ke server backend ($_loginUrl). Pastikan server aktif.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Dialog Pop-up Sukses modern menggunakan showGeneralDialog beranimasi
  /// dengan efek ScaleTransition dan Curves.elasticOut
  Future<void> _showSuccessDialog({String? userName}) async {
    bool hasNavigated = false;
    Timer? autoCloseTimer;

    void proceedToHome() {
      if (!hasNavigated && mounted) {
        hasNavigated = true;
        autoCloseTimer?.cancel();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    }

    // Auto-close setelah 2.2 detik jika pengguna tidak menekan tombol secara manual
    autoCloseTimer = Timer(const Duration(milliseconds: 2200), () {
      proceedToHome();
    });

    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Login Success',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (dialogContext, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        );

        return ScaleTransition(
          scale: curvedAnimation,
          child: FadeTransition(
            opacity: animation,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Lingkaran Centang Hijau Besar Modern
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE8F5E9),
                          border: Border.all(
                            color: const Color(0xFFA5D6A7),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.25),
                              blurRadius: 16,
                              spreadRadius: 2,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF10B981),
                            size: 52,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Login Berhasil!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lora(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userName != null && userName.isNotEmpty
                            ? 'Selamat datang kembali, $userName!\nSenang berjumpa kembali di Rumah Budaya Ratna.'
                            : 'Selamat datang di Rumah Budaya Ratna!\nRuang temu seni, literasi, & kehangatan tradisi Jawa.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: proceedToHome,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.maroon,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Lanjutkan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    autoCloseTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(height: 10),
                    // Logo Icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.maroon,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.other_houses, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Selamat Datang di Rumah\nBudaya Ratna',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lora(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ruang temu seni, literasi & kehangatan tradisi Jawa.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Banner Card dengan Foto Asli Rumah Budaya Ratna
                    Container(
                      height: 124,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.maroonDark,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/images/rbr_frontt.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: AppColors.maroonDark,
                                child: const Center(
                                  child: Icon(
                                    Icons.photo_outlined,
                                    color: Colors.white38,
                                    size: 36,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.35),
                                    Colors.black.withValues(alpha: 0.70),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form Validator untuk Email & Password
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Input Email / No HP
                          Text(
                            'Email / No. Handphone',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            enabled: !_isLoading,
                            style: GoogleFonts.plusJakartaSans(fontSize: 12),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email / No. HP tidak boleh kosong';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Contoh: user@rbr.com',
                              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                              prefixIcon: const Icon(Icons.email_outlined, size: 18, color: AppColors.textMuted),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.maroon, width: 1.5)),
                              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
                              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Input Password
                          Text(
                            'Kata Sandi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            enabled: !_isLoading,
                            style: GoogleFonts.plusJakartaSans(fontSize: 12),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Kata sandi tidak boleh kosong';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                              prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.textMuted),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: AppColors.textMuted),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.maroon, width: 1.5)),
                              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
                              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
                            ),
                          ),

                          // Lupa Kata Sandi
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
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
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.maroon,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.maroon.withValues(alpha: 0.6),
                                disabledForegroundColor: Colors.white70,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 2,
                              ),
                              child: _isLoading
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
                    OutlinedButton(
                      onPressed: () {
                        _showSuccessDialog(userName: 'Pengguna Google');
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/google_logo.png',
                            width: 18,
                            height: 18,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.g_mobiledata,
                                color: Color(0xFF4285F4),
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Masuk dengan Google',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMain),
                          ),
                        ],
                      ),
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
  }
}