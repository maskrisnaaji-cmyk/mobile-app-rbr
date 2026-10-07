import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import 'register_success_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  bool _agreeTerms = true;
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.maroon,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.other_houses, color: Colors.white, size: 24),
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
                    Text(
                      'Lengkapi data Anda untuk bergabung dalam ruang preservasi & dokumentasi budaya Indonesia.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Input Nama Lengkap
                    _buildInputLabel('Nama Lengkap'),
                    TextField(
                      decoration: _inputDecoration('Contoh: Aris Widiatmoko', Icons.person_outline),
                    ),
                    const SizedBox(height: 12),

                    // Input Email
                    _buildInputLabel('Email'),
                    TextField(
                      decoration: _inputDecoration('Contoh: aris@gmail.com', Icons.email_outlined),
                    ),
                    const SizedBox(height: 12),

                    // Input No HP
                    _buildInputLabel('Nomor Telepon'),
                    Row(
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
                          child: TextField(
                            decoration: _inputDecoration('812-3456-7890', Icons.phone_outlined),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Input Password
                    _buildInputLabel('Kata Sandi'),
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
                    const SizedBox(height: 12),

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
                        onPressed: () {
                          // Lanjut ke Halaman Verifikasi / Sukses
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterSuccessView()),
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
                              'DAFTAR SEKARANG',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
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
      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
      prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
    );
  }
}