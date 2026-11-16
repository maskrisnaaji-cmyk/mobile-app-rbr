import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/colors.dart';

/// Komponen Header untuk halaman Login & Register
/// Menampilkan Logo RBR, teks sambutan bernuansa budaya, dan Banner foto cagar budaya RBR
class AuthHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? bannerAsset;

  const AuthHeaderWidget({
    super.key,
    this.title = 'Selamat Datang di Rumah\nBudaya Ratna',
    this.subtitle = 'Library Cafe | Bookshop | Fortune Telling',
    this.bannerAsset = 'assets/images/rbr_frontt.jpg',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
          child: ClipOval(
            child: Image.asset(
              'assets/images/rbr_front.jpeg',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.other_houses,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
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
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 20),

        // Banner Card dengan Foto Asli Rumah Budaya Ratna
        if (bannerAsset != null)
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
                    bannerAsset!,
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
      ],
    );
  }
}
