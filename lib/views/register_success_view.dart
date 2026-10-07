import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import 'main_screen.dart';

class RegisterSuccessView extends StatelessWidget {
  const RegisterSuccessView({super.key});

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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Circle Checkmark
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: AppColors.maroon,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'SELAMAT DATANG',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AKUN BERHASIL DIBUAT',
                      style: GoogleFonts.lora(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Selamat bergabung di keluarga Rumah Budaya Ratna. Kartu keanggotaan digital Anda telah aktif.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Kartu Anggota Digital Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'KARTU ANGGOTA DIGITAL',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'AKTIF',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: AppColors.border, height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ID Anggota', style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.textMuted)),
                                  Text('RBR-2026-8912', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Icon(Icons.qr_code_2, size: 36, color: AppColors.maroon),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('Nama Lengkap', style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.textMuted)),
                          Text('Aris Widiatmoko', style: GoogleFonts.lora(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                          const SizedBox(height: 10),
                          Text('Status Tingkat', style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.textMuted)),
                          Row(
                            children: [
                              const Icon(Icons.workspace_premium, color: AppColors.gold, size: 16),
                              const SizedBox(width: 4),
                              Text('Anggota Madya (Silver)', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Tombol Masuk Ke Beranda
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Pindah ke Beranda & Hapus tumpukan navigasi sebelumnya
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const MainScreen()),
                            (route) => false,
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
                              'MASUK KE BERANDA',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Button Lihat Profil
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const MainScreen()),
                          (route) => false,
                        );
                      },
                      child: Text(
                        'LIHAT PROFIL SAYA',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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