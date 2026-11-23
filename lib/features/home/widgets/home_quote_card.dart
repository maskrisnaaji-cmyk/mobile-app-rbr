import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/colors.dart';

/// Komponen Card Kutipan Budaya pada Beranda
class HomeQuoteCard extends StatelessWidget {
  final String quote;

  const HomeQuoteCard({
    super.key,
    this.quote = ' Selalu terbuka berbagi makanan, tempat tinggal, atau bantuan kepada siapa saja dengan prinsip kesederhanaan.',
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            quote,
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '- Ratna Indraswari Ibrahim',
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(
              fontSize: 10,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }
}
