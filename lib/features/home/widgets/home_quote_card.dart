import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/colors.dart';

/// Komponen Card Kutipan Budaya pada Beranda
class HomeQuoteCard extends StatelessWidget {
  final String quote;

  const HomeQuoteCard({
    super.key,
    this.quote = 'Membaca adalah merawat ingatan, berbudaya adalah merawat martabat.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Text(
        quote,
        textAlign: TextAlign.center,
        style: GoogleFonts.lora(
          fontSize: 11,
          fontStyle: FontStyle.italic,
          color: AppColors.textMain,
        ),
      ),
    );
  }
}
