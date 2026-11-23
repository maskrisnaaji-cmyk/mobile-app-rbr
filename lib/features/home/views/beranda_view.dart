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
import 'package:mobile_app/features/notification/viewmodels/notification_viewmodel.dart';
import 'package:mobile_app/features/notification/views/notification_view.dart';

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
  final NotificationViewModel _notificationViewModel = NotificationViewModel.instance;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? AppInjection.createHomeViewModel();
    _notificationViewModel.fetchNotifications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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
              ListenableBuilder(
                listenable: _notificationViewModel,
                builder: (context, _) {
                  return HomeHeaderBar(
                    userName: _viewModel.userName,
                    userInitials: _viewModel.userInitials,
                    onProfileTap: () => widget.onNavigateTab?.call(4),
                    onSearchTap: () => _searchFocusNode.requestFocus(),
                    notificationCount: _notificationViewModel.unreadCount,
                    onNotificationTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationView(),
                        ),
                      );
                      _notificationViewModel.fetchNotifications();
                    },
                  );
                },
              ),
              const SizedBox(height: 14),

              // Search Bar Beranda
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  textInputAction: TextInputAction.search,
                  onChanged: _viewModel.updateSearch,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.search,
                        color: AppColors.maroon, size: 20),
                    hintText: 'Cari layanan, agenda, atau fitur Beranda...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                    suffixIcon: _viewModel.isSearching
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                size: 18, color: AppColors.textMuted),
                            splashRadius: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              _searchController.clear();
                              _viewModel.clearSearch();
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Jika sedang dalam mode pencarian, tampilkan hasil pencarian fitur & konten Beranda
              if (_viewModel.isSearching) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hasil Pencarian Beranda',
                      style: GoogleFonts.lora(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    Text(
                      '${_viewModel.searchResults.length} ditemukan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_viewModel.searchResults.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 36, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'Fitur atau konten tidak ditemukan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Coba cari dengan kata kunci seperti "kopi", "agenda", "workshop", atau "profil".',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: _viewModel.searchResults.map((result) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          onTap: () {
                            if (result.targetTab > 0) {
                              widget.onNavigateTab?.call(result.targetTab);
                            }
                          },
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.maroon.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(result.icon,
                                color: AppColors.maroon, size: 20),
                          ),
                          title: Text(
                            result.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text(
                                result.subtitle,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.tagBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  result.category,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.maroon,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: result.targetTab > 0
                              ? const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 14, color: AppColors.maroon)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 20),
              ] else ...[
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
            ],
          ),
        );
      },
    );
  }
}
