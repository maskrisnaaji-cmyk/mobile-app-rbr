import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/colors.dart';

/// Komponen Grid Menu Akses Cepat pada Beranda
class HomeQuickAccessGrid extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const HomeQuickAccessGrid({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AKSES CEPAT',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickAccessItem(Icons.coffee_outlined, 'Pesan Kopi', () => onNavigateTab?.call(1)),
            _buildQuickAccessItem(Icons.menu_book_outlined, 'Katalog Buku', () => onNavigateTab?.call(2)),
            _buildQuickAccessItem(Icons.calendar_month_outlined, 'Event', () => onNavigateTab?.call(3)),
            _buildQuickAccessItem(Icons.person_outline, 'Profil', () => onNavigateTab?.call(4)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.maroon, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
