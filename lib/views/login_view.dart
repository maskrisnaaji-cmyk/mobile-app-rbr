import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import 'main_screen.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _obscurePassword = true;

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
                      '',
                      style: GoogleFonts.lora(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
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

                    // Banner Card
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.maroonDark,
                        borderRadius: BorderRadius.circular(14),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1513694203232-719a280e022f?q=80&w=600'),
                          fit: BoxFit.cover,
                          opacity: 0.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Menghidupkan Tradisi & Merawat Ingatan',
                          style: GoogleFonts.lora(
                            color: Colors.white,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input Email / No HP
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Email / No. Handphone',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Contoh: ratna@budaya.org atau 0812...',
                        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.email_outlined, size: 18, color: AppColors.textMuted),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Input Password
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Kata Sandi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      obscureText: _obscurePassword,
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
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      ),
                    ),

                    // Lupa Kata Sandi (Sudah Diperbaiki)
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
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MainScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.maroon,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'MASUK',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MainScreen()),
                        );
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
                          const Icon(Icons.g_mobiledata, color: Colors.red, size: 24),
                          const SizedBox(width: 6),
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