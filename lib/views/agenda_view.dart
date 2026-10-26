import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../theme/colors.dart';
import 'booking_checkout_view.dart';

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _allEvents = [];

  // Filter Bulan & Tanggal
  DateTime _currentMonth =
      DateTime(2026, 9); // Default ke September 2026 (sesuai data acara RBR)
  int?
      _selectedDate; // Tanggal yang dipilih (null = tampilkan semua tanggal di bulan tsb)

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
    _fetchEvents();
  }

  /// Mengambil data agenda secara dinamis dari backend Express.js & MySQL
  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(ApiConfig.eventsUrl)).timeout(
            const Duration(seconds: 8),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Map<String, dynamic>> parsedEvents = [];

        for (var item in data) {
          final rawDate = item['date']?.toString() ?? '';
          final parsedDate = _parseEventDate(rawDate);

          final title = item['title']?.toString() ??
              item['tittle']?.toString() ??
              'Acara Budaya';
          final category = item['category']?.toString() ?? 'Budaya';
          final time = item['time']?.toString() ?? '15:00 WIB';
          final location = item['location']?.toString() ?? 'Pendopo Utama RBR';
          final quota = int.tryParse(item['quota']?.toString() ?? '') ?? 50;
          final sold = int.tryParse(item['sold']?.toString() ?? '') ?? 0;
          final rawPrice = item['price'];
          final priceInt = int.tryParse(rawPrice?.toString() ?? '') ?? 0;
          final priceStr = priceInt == 0 ? 'Gratis' : _formatRupiah(priceInt);
          final backendImage = item['image']?.toString() ?? '';
          final image = _eventImageAsset(title, parsedDate, backendImage);
          final imageFallback = _eventImageFallback(title);
          final status = item['status']?.toString() ?? 'Aktif';

          parsedEvents.add({
            'id': item['id'],
            'title': title,
            'category': category,
            'dateStr': rawDate,
            'dateTime': parsedDate,
            'time': time,
            'location': location,
            'quota': quota,
            'sold': sold,
            'seats':
                sold >= quota ? 'Tiket Penuh' : 'Sisa ${quota - sold} Kursi',
            'price': priceStr,
            'image': image,
            'imageFallback': imageFallback,
            'status': status,
            'imageColor': _colorForCategory(category),
          });
        }

        if (mounted) {
          setState(() {
            _allEvents = parsedEvents;
            _isLoading = false;

            // Jika ada event, pastikan bulan yang terpilih mengarah ke bulan event pertama
            if (_allEvents.isNotEmpty) {
              final datesWithEvents = _allEvents
                  .where((e) => e['dateTime'] != null)
                  .map((e) => e['dateTime'] as DateTime)
                  .toList();
              if (datesWithEvents.isNotEmpty) {
                datesWithEvents.sort((a, b) => a.compareTo(b));
                // Set default month ke event terdekat
                _currentMonth = DateTime(
                    datesWithEvents.first.year, datesWithEvents.first.month);
              }
            }
          });
        }
      } else {
        throw Exception('Gagal memuat agenda (HTTP ${response.statusCode})');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Tidak dapat terhubung ke server backend.';
        });
      }
    }
  }

  /// Parser tanggal fleksibel (mendukung format '2026-09-28' atau teks 'Sabtu, 28 September 2026')
  DateTime? _parseEventDate(String dateStr) {
    if (dateStr.trim().isEmpty) return null;

    // 1. Coba format standar ISO (YYYY-MM-DD)
    final iso = DateTime.tryParse(dateStr);
    if (iso != null) return iso;

    // 2. Coba format teks Indonesia: e.g. "Sabtu, 28 September 2026" atau "28 September 2026"
    final clean = dateStr.toLowerCase();
    final monthMap = {
      'januari': 1,
      'februari': 2,
      'maret': 3,
      'april': 4,
      'mei': 5,
      'juni': 6,
      'juli': 7,
      'agustus': 8,
      'september': 9,
      'oktober': 10,
      'november': 11,
      'desember': 12,
      'sep': 9,
      'okt': 10,
      'nov': 11,
      'des': 12,
    };

    final reg = RegExp(r'(\d{1,2})\s+([a-zA-Z]+)\s+(\d{4})');
    final match = reg.firstMatch(clean);
    if (match != null) {
      final day = int.tryParse(match.group(1)!);
      final monthName = match.group(2)!;
      final year = int.tryParse(match.group(3)!);
      final month = monthMap[monthName];
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }

  String _formatRupiah(int price) {
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
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

  String _eventImageAsset(
      String title, DateTime? eventDate, String backendImage) {
    final normalizedTitle = title.toLowerCase();
    if (normalizedTitle.contains('napak tanah')) {
      return 'assets/images/napak_tanah.jpg';
    }
    if (normalizedTitle.contains('teater') &&
        normalizedTitle.contains('rungkad')) {
      return 'assets/images/teater_rungkad.jpg';
    }
    if (eventDate?.year == 2026 && eventDate?.month == 10) {
      switch (eventDate!.day) {
        case 8:
          return 'assets/images/oktober_08_obrolan_budaya.jpg';
        case 9:
          return 'assets/images/oktober_09_pameran_batik.jpg';
        case 11:
          return 'assets/images/oktober_11_workshop_keramik.jpg';
        case 12:
          return 'assets/images/oktober_12_malam_akustik.jpg';
        case 13:
          return 'assets/images/oktober_13_sabtu_budaya.jpg';
      }
    }
    return backendImage;
  }

  String? _eventImageFallback(String title) {
    final normalizedTitle = title.toLowerCase();
    if (normalizedTitle.contains('napak tanah')) {
      return 'assets/images/napak_tanah.png';
    }
    if (normalizedTitle.contains('teater') &&
        normalizedTitle.contains('rungkad')) {
      return 'assets/images/teather_rungkad.png';
    }
    return null;
  }

  // Navigasi Bulan (Bulan Sebelumnya / Selanjutnya)
  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _selectedDate = null; // reset filter tanggal spesifik saat ganti bulan
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _selectedDate = null;
    });
  }

  /// Event yang disaring berdasarkan bulan aktif dan tanggal yang dipilih
  List<Map<String, dynamic>> get _filteredEvents {
    return _allEvents.where((event) {
      final dt = event['dateTime'] as DateTime?;
      if (dt == null) return false;

      // Filter Bulan & Tahun
      final matchMonth =
          dt.year == _currentMonth.year && dt.month == _currentMonth.month;
      if (!matchMonth) return false;

      // Filter Tanggal Spesifik (jika ada yang dipilih)
      if (_selectedDate != null) {
        return dt.day == _selectedDate;
      }
      return true;
    }).toList();
  }

  /// Daftar tanggal unik yang memiliki acara pada bulan terpilih (diurutkan ASCENDING)
  List<int> get _datesWithEventsInCurrentMonth {
    final Set<int> dates = {};
    for (var event in _allEvents) {
      final dt = event['dateTime'] as DateTime?;
      if (dt != null &&
          dt.year == _currentMonth.year &&
          dt.month == _currentMonth.month) {
        dates.add(dt.day);
      }
    }
    final list = dates.toList()..sort();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final events = _filteredEvents;
    final activeDates = _datesWithEventsInCurrentMonth;
    final monthLabel =
        '${_monthNames[_currentMonth.month - 1]} ${_currentMonth.year}';

    return RefreshIndicator(
      onRefresh: _fetchEvents,
      color: AppColors.maroon,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
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
                          color: AppColors.maroon, shape: BoxShape.circle),
                      child: const Icon(Icons.event,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Agenda Budaya',
                      style: GoogleFonts.lora(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _fetchEvents,
                      tooltip: 'Muat ulang data',
                      icon: const Icon(Icons.refresh_rounded,
                          color: AppColors.textMain),
                    ),
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
                    onPressed: _prevMonth,
                    tooltip: 'Bulan sebelumnya',
                    icon: const Icon(Icons.chevron_left_rounded,
                        color: AppColors.maroon, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),

                  // Label Bulan & Menu Dropdown Pilihan Cepat
                  PopupMenuButton<int>(
                    tooltip: 'Pilih bulan langsung',
                    onSelected: (int m) {
                      setState(() {
                        _currentMonth = DateTime(_currentMonth.year, m);
                        _selectedDate = null;
                      });
                    },
                    itemBuilder: (context) => List.generate(12, (index) {
                      return PopupMenuItem<int>(
                        value: index + 1,
                        child: Text(
                          _monthNames[index],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: (_currentMonth.month == index + 1)
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: (_currentMonth.month == index + 1)
                                ? AppColors.maroon
                                : AppColors.textMain,
                          ),
                        ),
                      );
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.tagBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month_outlined,
                              size: 15, color: AppColors.maroon),
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
                          const Icon(Icons.arrow_drop_down,
                              size: 18, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),

                  // Tombol Bulan Selanjutnya
                  IconButton(
                    onPressed: _nextMonth,
                    tooltip: 'Bulan selanjutnya',
                    icon: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.maroon, size: 24),
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
                      onTap: () {
                        setState(() {
                          _selectedDate = null;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: _selectedDate == null
                              ? const Color(0xFF6B1D2F)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedDate == null
                                ? const Color(0xFF6B1D2F)
                                : AppColors.border,
                          ),
                          boxShadow: _selectedDate == null
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
                                color: _selectedDate == null
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
                                color: _selectedDate == null
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
                          _currentMonth.year, _currentMonth.month, dayNum);
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
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: CircularProgressIndicator(color: AppColors.maroon),
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          size: 48, color: Colors.redAccent),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _fetchEvents,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.maroon,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (events.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.event_busy,
                          size: 48,
                          color: AppColors.textMuted.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text(
                        _selectedDate != null
                            ? 'Tidak ada acara pada tanggal $_selectedDate $monthLabel.'
                            : 'Tidak ada acara yang dijadwalkan pada $monthLabel.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...events.asMap().entries.map((entry) {
                final e = entry.value;
                return Column(
                  children: [
                    _buildEventCard(
                      context,
                      category: e['category'] as String,
                      time: e['time'] as String,
                      seats: e['seats'] as String,
                      location: e['location'] as String,
                      title: e['title'] as String,
                      price: e['price'] as String,
                      imageColor: e['imageColor'] as Color,
                      image: e['image'] as String?,
                      imageFallback: e['imageFallback'] as String?,
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),

            // Bottom CTA Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.goldLight,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.handshake_outlined,
                      color: AppColors.gold, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ingin Mengadakan Lokakarya?',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11, fontWeight: FontWeight.bold)),
                        Text(
                            'Buka kelas seni atau diskusi budaya bersama komunitas Rumah Ratna.',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 9, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateItem(String day, int date) {
    final isSelected = _selectedDate == date;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B1D2F) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected ? const Color(0xFF6B1D2F) : AppColors.border),
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

  Widget _buildEventCard(
    BuildContext context, {
    required String category,
    required String time,
    required String seats,
    required String location,
    required String title,
    required String price,
    required Color imageColor,
    String? image,
    String? imageFallback,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 170,
            width: double.infinity,
            decoration: BoxDecoration(
              color: imageColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (image != null && image.isNotEmpty)
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(13)),
                    child: (image.startsWith('http')
                        ? Image.network(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: imageColor),
                          )
                        : Image.asset(
                            image.startsWith('/') ? image.substring(1) : image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => imageFallback == null
                                ? Container(color: imageColor)
                                : Image.asset(
                                    imageFallback,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(color: imageColor),
                                  ),
                          )),
                  ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(13)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      category,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.maroon),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(time,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: seats.contains('Penuh')
                          ? Colors.red.shade900
                          : Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      seats,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.maroon),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5, color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.lora(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Biaya Partisipasi',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 8.5, color: AppColors.textMuted)),
                        Text(
                          price,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.maroon),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingCheckoutView(
                              eventTitle: title,
                              category: category,
                              time: time,
                              location: location,
                              basePrice: price,
                              eventImage: image,
                              eventImageFallback: imageFallback,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.maroon,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('PESAN TIKET',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
