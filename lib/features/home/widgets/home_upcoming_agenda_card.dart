import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/features/home/models/home_model.dart';

/// Komponen Card Agenda Mendatang pada Beranda
class HomeUpcomingAgendaCard extends StatelessWidget {
  final HomeUpcomingAgenda? agenda;
  final VoidCallback? onReserveTap;

  const HomeUpcomingAgendaCard({
    super.key,
    this.agenda,
    this.onReserveTap,
  });

  @override
  Widget build(BuildContext context) {
    final day = agenda?.day ?? 'SEN';
    final date = agenda?.date ?? '12';
    final month = agenda?.month ?? 'SEP';
    final timeLocation = agenda?.timeLocation ?? '19.00 WIB - Pendopo Utama';
    final title = agenda?.title ?? 'Malam Akustik & Puisi Nusantara';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.tagBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.lora(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.maroon,
                  ),
                ),
                Text(
                  month,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeLocation,
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.lora(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onReserveTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Reservasi',
              style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
