import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/core/widgets/user_avatar_widget.dart';
import 'package:mobile_app/core/widgets/api_error_widget.dart';
import 'package:mobile_app/features/agenda/viewmodels/agenda_viewmodel.dart';
import 'package:mobile_app/features/agenda/widgets/agenda_card.dart';
import 'package:mobile_app/features/agenda/views/pengajuan_lokakarya_view.dart';

class AgendaView extends StatefulWidget {
  final AgendaViewModel? viewModel;

  const AgendaView({super.key, this.viewModel});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  late final AgendaViewModel _viewModel;
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  static const List<String> _dayNames = [
    'SEN',
    'SEL',
    'RAB',
    'KAM',
    'JUM',
    'SAB',
    'MIN'
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? AgendaViewModel();
    _viewModel.fetchEvents();
    _viewModel.startAutoRefresh(const Duration(seconds: 6));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.stopAutoRefresh();
    if (widget.viewModel == null) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  Color _colorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'lokakarya':
      case 'workshop':
        return Colors.brown.shade700;
      case 'pertunjukan':
      case 'wicara seni':
      case 'teater':
        return const Color(0xFF521513);
      case 'diskusi':
        return Colors.teal.shade800;
      case 'pameran':
        return Colors.indigo.shade800;
      case 'komunitas':
        return Colors.green.shade800;
      default:
        return AppColors.maroon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final events = _viewModel.filteredEvents;
        final activeDates = _viewModel.datesWithEventsInCurrentMonth;
        final currentMonth = _viewModel.currentMonth;
        final monthLabel =
            '${_monthNames[currentMonth.month - 1]} ${currentMonth.year}';

        return RefreshIndicator(
          onRefresh: _viewModel.fetchEvents,
          color: AppColors.maroon,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.maroon,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.event,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Agenda Budaya',
                          style: GoogleFonts.lora(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isSearchOpen = !_isSearchOpen;
                              if (!_isSearchOpen) {
                                _searchController.clear();
                                _viewModel.clearSearch();
                              }
                            });
                          },
                          tooltip: _isSearchOpen
                              ? 'Tutup pencarian'
                              : 'Cari acara / workshop',
                          icon: Icon(
                            _isSearchOpen
                                ? Icons.close_rounded
                                : Icons.search_rounded,
                            color: AppColors.textMain,
                          ),
                        ),
                        IconButton(
                          onPressed: _viewModel.fetchEvents,
                          tooltip: 'Muat ulang data',
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const UserAvatarWidget(radius: 13),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  'KALENDER BUDAYA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: AppColors.maroon,
                  ),
                ),
                Text(
                  'AGENDA ACARA & WORKSHOP',
                  style: GoogleFonts.lora(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 14),

                // ── FITUR FILTER BULAN MODERN (RINGKAS & MENARIK) ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tombol Bulan Sebelumnya
                      IconButton(
                        onPressed: _viewModel.prevMonth,
                        tooltip: 'Bulan sebelumnya',
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.maroon,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),

                      // Label Bulan & Menu Dropdown Pilihan Cepat
                      PopupMenuButton<int>(
                        tooltip: 'Pilih bulan langsung',
                        onSelected: (int m) => _viewModel.selectMonth(m),
                        itemBuilder: (context) => List.generate(12, (index) {
                          return PopupMenuItem<int>(
                            value: index + 1,
                            child: Text(
                              _monthNames[index],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: (currentMonth.month == index + 1)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: (currentMonth.month == index + 1)
                                    ? AppColors.maroon
                                    : AppColors.textMain,
                              ),
                            ),
                          );
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tagBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_month_outlined,
                                size: 15,
                                color: AppColors.maroon,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                monthLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_drop_down,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Tombol Bulan Selanjutnya
                      IconButton(
                        onPressed: _viewModel.nextMonth,
                        tooltip: 'Bulan selanjutnya',
                        icon: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.maroon,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── CALENDAR STRIP: DIURUTKAN SECARA ASCENDING DARI KIRI ──
                if (activeDates.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        // Tombol Opsi "Semua Tanggal"
                        GestureDetector(
                          onTap: () => _viewModel.selectDate(null),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: _viewModel.selectedDate == null
                                  ? const Color(0xFF6B1D2F)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _viewModel.selectedDate == null
                                    ? const Color(0xFF6B1D2F)
                                    : AppColors.border,
                              ),
                              boxShadow: _viewModel.selectedDate == null
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF6B1D2F)
                                            .withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'SEMUA',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: _viewModel.selectedDate == null
                                        ? Colors.white70
                                        : AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'BULAN INI',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _viewModel.selectedDate == null
                                        ? Colors.white
                                        : AppColors.textMain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Daftar Tanggal Ascending dari Tanggal Paling Awal (Kiri)
                        ...activeDates.map((dayNum) {
                          final dt = DateTime(
                            currentMonth.year,
                            currentMonth.month,
                            dayNum,
                          );
                          final dayLabel = _dayNames[dt.weekday - 1];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildDateItem(dayLabel, dayNum),
                          );
                        }),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // ── DAFTAR EVENT DINAMIS DARI BACKEND ──
                if (_viewModel.isLoading && _viewModel.allEvents.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: CircularProgressIndicator(color: AppColors.maroon),
                    ),
                  )
                else if (_viewModel.errorMessage != null &&
                    _viewModel.allEvents.isEmpty)
                  ApiErrorWidget(
                    message: _viewModel.errorMessage,
                    onRetry: _viewModel.fetchEvents,
                  )
                else if (events.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 48,
                            color: AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _viewModel.selectedDate != null
                                ? 'Tidak ada acara pada tanggal ${_viewModel.selectedDate} $monthLabel.'
                                : 'Tidak ada acara yang dijadwalkan pada $monthLabel.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...events.map((event) {
                    final int? eventId = event.id is int
                        ? event.id as int
                        : int.tryParse(event.id?.toString() ?? '');
                    return Column(
                      children: [
                        AgendaCard(
                          eventId: eventId,
                          category: event.category,
                          time: event.time,
                          seats: event.seats,
                          location: event.location,
                          title: event.title,
                          price: event.formattedPrice,
                          imageColor: _colorForCategory(event.category),
                          image: event.image,
                          imageFallback: event.imageFallback,
                          isSoldOut: event.isSoldOut,
                          currentTierName: event.currentTierName,
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),

                // Bottom CTA Banner (Arahkan ke Pengajuan Lokakarya)
                InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PengajuanLokakaryaView(
                          viewModel: _viewModel,
                        ),
                      ),
                    );
                    _viewModel.fetchEvents();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.goldLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.handshake_outlined,
                          color: AppColors.gold,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ingin Mengadakan Lokakarya?',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Buka kelas seni atau diskusi budaya bersama komunitas Rumah Ratna.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.maroon,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'AJUKAN',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateItem(String day, int date) {
    final isSelected = _viewModel.selectedDate == date;
    return GestureDetector(
      onTap: () => _viewModel.selectDate(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B1D2F) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF6B1D2F) : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6B1D2F).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Text(
              day,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                color: isSelected ? Colors.white70 : AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date.toString().padLeft(2, '0'),
              style: GoogleFonts.lora(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
