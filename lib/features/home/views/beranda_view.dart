import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/di/injection.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/features/home/viewmodels/home_viewmodel.dart';
import 'package:mobile_app/features/home/widgets/home_banner_card.dart';
import 'package:mobile_app/features/home/widgets/home_header_bar.dart';
import 'package:mobile_app/features/home/widgets/home_popular_book_card.dart';
import 'package:mobile_app/features/home/widgets/home_quick_access_grid.dart';
import 'package:mobile_app/features/home/widgets/home_quote_card.dart';
import 'package:mobile_app/features/home/widgets/home_upcoming_agenda_card.dart';

class BerandaView extends StatefulWidget {
  final Function(int)? onNavigateTab;
  final HomeViewModel? viewModel;

  const BerandaView({
    super.key,
    this.onNavigateTab,
    this.viewModel,
  });

  @override
  State<BerandaView> createState() => _BerandaViewState();
}

class _BerandaViewState extends State<BerandaView> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? AppInjection.createHomeViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Bar Beranda
              HomeHeaderBar(
                userName: _viewModel.userName,
                userInitials: _viewModel.userInitials,
                onProfileTap: () => widget.onNavigateTab?.call(4),
              ),
              const SizedBox(height: 16),

              // Banner Hero Utama
              HomeBannerCard(bannerData: _viewModel.bannerData),
              const SizedBox(height: 20),

              // Akses Cepat Grid
              HomeQuickAccessGrid(onNavigateTab: widget.onNavigateTab),
              const SizedBox(height: 24),

              // Koleksi Populer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Koleksi Populer',
                    style: GoogleFonts.lora(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.onNavigateTab?.call(2),
                    child: Text(
                      'Lihat Semua >',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.maroon,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _viewModel.popularBooks.map((book) {
                    final isLast = book == _viewModel.popularBooks.last;
                    return Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : 12),
                      child: HomePopularBookCard(book: book),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Agenda Mendatang
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Agenda Mendatang',
                    style: GoogleFonts.lora(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.onNavigateTab?.call(3),
                    child: Text(
                      'Kalender >',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.maroon,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              HomeUpcomingAgendaCard(
                agenda: _viewModel.upcomingAgenda,
                onReserveTap: () => widget.onNavigateTab?.call(3),
              ),
              const SizedBox(height: 20),

              // Quote Card
              HomeQuoteCard(
                quote: _viewModel.quote.isNotEmpty
                    ? _viewModel.quote
                    : ' Selalu terbuka berbagi makanan, tempat tinggal, atau bantuan kepada siapa saja dengan prinsip kesederhanaan.',
              ),
            ],
          ),
        );
      },
    );
  }
}
