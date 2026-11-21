// lib/features/agenda/widgets/presale_tier_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/features/agenda/models/presale_tier_model.dart';

/// Widget card untuk menampilkan satu tier presale tiket.
class PresaleTierCard extends StatelessWidget {
  final PresaleTierModel tier;
  final bool isSelected;
  final VoidCallback? onTap;

  const PresaleTierCard({
    super.key,
    required this.tier,
    this.isSelected = false,
    this.onTap,
  });

  // --- Warna badge berdasarkan status tier ---
  Color get _badgeColor {
    if (tier.isSoldout) return const Color(0xFFDC2626);
    if (tier.isCurrentActive) return const Color(0xFF059669);
    return const Color(0xFF9CA3AF);
  }

  Color get _badgeBgColor {
    if (tier.isSoldout) return const Color(0xFFDC2626).withValues(alpha: 0.12);
    if (tier.isCurrentActive) {
      return const Color(0xFF059669).withValues(alpha: 0.12);
    }
    return const Color(0xFF9CA3AF).withValues(alpha: 0.12);
  }

  String get _badgeLabel {
    if (tier.isSoldout) return 'HABIS';
    if (tier.isCurrentActive) return tier.tierName.toUpperCase();
    return tier.tierName.toUpperCase();
  }

  Color get _progressColor {
    if (tier.isSoldout) return const Color(0xFFDC2626);
    if (tier.isCurrentActive) return AppColors.maroon;
    return const Color(0xFF9CA3AF);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !tier.isCurrentActive || tier.isSoldout;

    return Opacity(
      opacity: !tier.isActive ? 0.5 : 1.0,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.maroon.withValues(alpha: 0.04)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: tier.isCurrentActive && !tier.isSoldout
                  ? (isSelected ? AppColors.maroon : AppColors.maroon.withValues(alpha: 0.5))
                  : AppColors.border,
              width: (tier.isCurrentActive && !tier.isSoldout) ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Baris atas: nama tier + badge status ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Radio indicator
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: isDisabled
                            ? AppColors.textMuted
                            : (isSelected ? AppColors.maroon : AppColors.textMuted),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tier.tierName,
                        style: GoogleFonts.lora(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Badge "TERSEDIA SEKARANG" jika current active
                      if (tier.isCurrentActive && !tier.isSoldout) ...[
                        _buildBadge(
                          'TERSEDIA SEKARANG',
                          const Color(0xFF059669),
                          const Color(0xFF059669).withValues(alpha: 0.12),
                        ),
                        const SizedBox(width: 6),
                      ],
                      // Badge status utama
                      _buildBadge(
                        _badgeLabel,
                        _badgeColor,
                        _badgeBgColor,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // --- Konten detail di bawah radio ---
              Padding(
                padding: const EdgeInsets.only(left: 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Harga
                    Text(
                      '${tier.formattedPrice} / orang',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.maroon,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Progress bar kuota
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${tier.sold} / ${tier.quota} tiket terjual',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  Text(
                                    '${(tier.progressPercent * 100).toStringAsFixed(0)}%',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _progressColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: tier.progressPercent,
                                  minHeight: 6,
                                  backgroundColor: AppColors.border,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _progressColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Sisa kuota / label sold out
                    if (tier.isSoldout)
                      _buildSoldoutLabel()
                    else
                      Text(
                        'Sisa ${tier.remainingQuota} tiket lagi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: tier.remainingQuota <= 10
                              ? const Color(0xFFD97706)
                              : AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSoldoutLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border:
            Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
      ),
      child: Text(
        'HABIS TERJUAL',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFDC2626),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
