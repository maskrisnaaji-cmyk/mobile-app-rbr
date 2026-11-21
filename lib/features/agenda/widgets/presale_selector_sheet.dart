// lib/features/agenda/widgets/presale_selector_sheet.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/features/agenda/models/presale_tier_model.dart';
import 'package:mobile_app/features/agenda/widgets/presale_tier_card.dart';

/// Bottom sheet untuk memilih tier presale tiket.
///
/// Menampilkan daftar [PresaleTierCard] dan hanya mengizinkan pemilihan
/// tier yang sedang aktif ([PresaleTierModel.isCurrentActive]).
class PresaleSelectorSheet extends StatefulWidget {
  final List<PresaleTierModel> tiers;
  final bool isLoading;
  final void Function(PresaleTierModel tier) onTierSelected;

  const PresaleSelectorSheet({
    super.key,
    required this.tiers,
    required this.onTierSelected,
    this.isLoading = false,
  });

  @override
  State<PresaleSelectorSheet> createState() => _PresaleSelectorSheetState();
}

class _PresaleSelectorSheetState extends State<PresaleSelectorSheet> {
  PresaleTierModel? _selectedTier;

  bool get _allSoldOut =>
      widget.tiers.isNotEmpty &&
      widget.tiers.every((t) => t.isSoldout || !t.isActive);

  bool get _hasActiveTier =>
      widget.tiers.any((t) => t.isCurrentActive && !t.isSoldout);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle drag indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Judul
          Text(
            'Pilih Jenis Tiket Presale',
            style: GoogleFonts.lora(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hanya tier yang sedang aktif dapat dipilih',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),

          // --- Loading state ---
          if (widget.isLoading) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: AppColors.maroon),
              ),
            ),
          ] else ...[
            // --- Banner semua sold out ---
            if (_allSoldOut)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFDC2626), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Semua kuota presale habis — Tiket tidak tersedia',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // --- Daftar tier ---
            if (widget.tiers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Belum ada data tier presale',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.tiers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final tier = widget.tiers[index];
                  return PresaleTierCard(
                    tier: tier,
                    isSelected: _selectedTier?.id == tier.id,
                    onTap: (tier.isCurrentActive && !tier.isSoldout)
                        ? () => setState(() => _selectedTier = tier)
                        : null,
                  );
                },
              ),

            const SizedBox(height: 20),

            // --- Tombol Lanjut ke Pembayaran ---
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: (_selectedTier != null && _hasActiveTier)
                    ? () => widget.onTierSelected(_selectedTier!)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.maroon,
                  disabledBackgroundColor: AppColors.border,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lanjut ke Pembayaran',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _selectedTier != null
                            ? Colors.white
                            : AppColors.textMuted,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: _selectedTier != null
                          ? Colors.white
                          : AppColors.textMuted,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
