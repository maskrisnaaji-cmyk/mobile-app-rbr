import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/core/widgets/mobile_frame.dart';
import 'package:mobile_app/core/widgets/user_avatar_widget.dart';
import 'package:mobile_app/features/pustaka/models/review_model.dart';
import 'package:mobile_app/features/pustaka/viewmodels/pustaka_viewmodel.dart';
import 'package:mobile_app/features/pustaka/widgets/review_card_widget.dart';

class UlasanDiskusiScreen extends StatefulWidget {
  final PustakaViewModel? viewModel;

  const UlasanDiskusiScreen({super.key, this.viewModel});

  @override
  State<UlasanDiskusiScreen> createState() => _UlasanDiskusiScreenState();
}

class _UlasanDiskusiScreenState extends State<UlasanDiskusiScreen> {
  late final PustakaViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? PustakaViewModel();
    _viewModel.fetchReviews();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final reviews = _viewModel.reviews.isNotEmpty
            ? _viewModel.reviews
            : BookReview.demoReviews;

        return MobileFrame(
          child: Scaffold(
            backgroundColor: AppColors.bgCanvas,
            appBar: AppBar(
              backgroundColor: AppColors.bgCanvas,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textMain),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Ulasan & Diskusi Saya',
                style: GoogleFonts.lora(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.maroonDark,
                ),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list_rounded, color: AppColors.textMain, size: 21),
                  onPressed: () {},
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Center(child: UserAvatarWidget(radius: 13)),
                ),
              ],
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ringkasan Aktivitas Telaah
                  _buildSummaryHeader(reviews.length),
                  const SizedBox(height: 18),

                  Text(
                    'RIWAYAT ULASAN & TELAAH BUDAYA (${reviews.length})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: AppColors.greyText,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...reviews.map(
                    (review) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: ReviewCardWidget(review: review),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryHeader(int reviewCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Ulasan', '$reviewCount', Icons.rate_review_outlined),
          Container(height: 36, width: 1, color: AppColors.lightBorder),
          _buildStatItem('Rerata Rating', '4.8', Icons.star_rounded, isStar: true),
          Container(height: 36, width: 1, color: AppColors.lightBorder),
          _buildStatItem('Apresiasi', '28 Suka', Icons.thumb_up_alt_outlined),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {bool isStar = false}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isStar ? const Color(0xFFEAB308) : AppColors.maroon),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.lora(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.greyText),
        ),
      ],
    );
  }
}
