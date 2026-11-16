import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/features/pustaka/models/loan_model.dart';

/// Komponen Card untuk Peminjaman Buku Aktif & Riwayat
class LoanCardWidget extends StatelessWidget {
  final LoanItem loan;
  final VoidCallback onRequestExtension;

  const LoanCardWidget({
    super.key,
    required this.loan,
    required this.onRequestExtension,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = loan.isOverdue;
    final isReturned = loan.status == 'returned';
    final isPending = loan.isPending;

    final Color badgeBg = isOverdue
        ? const Color(0xFFFEE2E2)
        : (isReturned
            ? const Color(0xFFE2E8F0)
            : (isPending ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5)));
    final Color badgeText = isOverdue
        ? const Color(0xFFDC2626)
        : (isReturned
            ? const Color(0xFF475569)
            : (isPending ? const Color(0xFFB45309) : const Color(0xFF059669)));

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue ? const Color(0xFFFECACA) : AppColors.lightBorder,
          width: isOverdue ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isOverdue
                ? const Color(0xFFDC2626).withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Baris Kode & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.bgCanvas,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Text(
                  loan.bookCode,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyText,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  loan.statusLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: badgeText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Judul & Penulis
          Text(
            loan.title,
            style: GoogleFonts.lora(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loan.author,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.greyText,
            ),
          ),
          const SizedBox(height: 12),

          // Lokasi Rak & Info Tanggal
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildDateInfo('Tgl Pinjam', loan.borrowDateLabel),
                _buildDateInfo('Waktu Pinjam', loan.borrowTimeLabel),
                _buildDateInfo(
                  'Jatuh Tempo',
                  loan.dueDateLabel,
                  valueColor: isOverdue ? const Color(0xFFDC2626) : null,
                ),
                _buildDateInfo(
                  'Tgl Kembali',
                  loan.returnedDateLabel,
                  valueColor: isReturned ? const Color(0xFF15803D) : null,
                ),
                _buildDateInfo(
                  'Waktu Kembali',
                  loan.returnedTimeLabel,
                  valueColor: isReturned ? const Color(0xFF15803D) : null,
                ),
                _buildDateInfo('Lokasi', loan.rackLocation,
                    valueColor: AppColors.maroon),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tombol Perpanjang / Status Hari
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isOverdue
                        ? Icons.error_outline_rounded
                        : Icons.schedule_rounded,
                    size: 16,
                    color:
                        isOverdue ? const Color(0xFFDC2626) : AppColors.maroon,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    loan.daysLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isOverdue
                          ? const Color(0xFFDC2626)
                          : AppColors.maroon,
                    ),
                  ),
                ],
              ),
              if (!isReturned && !isPending)
                ElevatedButton(
                  onPressed: loan.extensionStatus == 'pending'
                      ? null
                      : onRequestExtension,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.maroon,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    loan.extensionStatus == 'pending'
                        ? 'Menunggu Konfirmasi'
                        : 'Perpanjang',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, String value, {Color? valueColor}) {
    return SizedBox(
      width: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: AppColors.greyText,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}
