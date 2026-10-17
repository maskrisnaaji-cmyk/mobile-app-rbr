import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import 'booking_checkout_view.dart';

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  int selectedDate = 12;

  // Data event per tanggal
  List<Map<String, dynamic>> _getEventsForDate(int date) {
    switch (date) {
      case 8:
        return [
          {
            'category': 'Diskusi',
            'time': '08 Sep - 13:00 WIB',
            'seats': 'Sisa 8 Kursi',
            'location': 'Ruang Komunal Lt. 1',
            'title': 'Obrolan Budaya: Kearifan Lokal Jawa',
            'price': 'Rp 15.000',
            'imageColor': Colors.teal.shade700,
          },
        ];
      case 9:
        return [
          {
            'category': 'Pameran',
            'time': '09 Sep - 10:00 WIB',
            'seats': 'Sisa 20 Kursi',
            'location': 'Galeri Utama',
            'title': 'Pameran Batik Kontemporer Nusantara',
            'price': 'Rp 20.000',
            'imageColor': Colors.indigo.shade700,
          },
        ];
      case 10:
        return [
          {
            'category': 'Lokakarya',
            'time': '10 Sep - 15:30 WIB',
            'seats': 'Sisa 4 Kursi',
            'location': 'Ruang Komunal Lt. 2',
            'title': 'Napak Tanah Jilid II Book Club & Pot Luck',
            'price': 'Rp 25.000',
            'imageColor': Colors.brown.shade700,
          },
          {
            'category': 'Wicara Seni',
            'time': '10 Sep - 19:00 WIB',
            'seats': 'Sisa 12 Kursi',
            'location': 'Panggung Utama Pendopo',
            'title': 'Penampilan Seni Teater Pak Rungkad Belum Ketemu',
            'price': 'Rp 35.000',
            'imageColor': Colors.black87,
          },
        ];
      case 11:
        return [
          {
            'category': 'Workshop',
            'time': '11 Sep - 09:00 WIB',
            'seats': 'Sisa 6 Kursi',
            'location': 'Studio Kreatif',
            'title': 'Workshop Keramik: Membentuk Tanah Liat',
            'price': 'Rp 45.000',
            'imageColor': Colors.orange.shade800,
          },
        ];
      case 12:
        return [
          {
            'category': 'Pertunjukan',
            'time': '12 Sep - 19:00 WIB',
            'seats': 'Sisa 18 Kursi',
            'location': 'Pendopo Utama',
            'title': 'Malam Akustik & Puisi Nusantara',
            'price': 'Rp 30.000',
            'imageColor': Colors.deepPurple.shade800,
          },
        ];
      case 13:
        return [
          {
            'category': 'Komunitas',
            'time': '13 Sep - 10:00 WIB',
            'seats': 'Sisa 25 Kursi',
            'location': 'Taman Budaya',
            'title': 'Sabtu Budaya: Gotong Royong Seni',
            'price': 'Gratis',
            'imageColor': Colors.green.shade800,
          },
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEventsForDate(selectedDate);

    return SingleChildScrollView(
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
                    decoration: const BoxDecoration(color: AppColors.maroon, shape: BoxShape.circle),
                    child: const Icon(Icons.event, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text('Agenda Budaya', style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                ],
              ),
              Row(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: AppColors.textMain)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: AppColors.textMain)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text('KALENDER BUDAYA', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.maroon)),
          Text('AGENDA ACARA & WORKSHOP', style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          const SizedBox(height: 12),

          // Horizontal Date Selector Strip - Interaktif
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateItem('SEN', 8),
              _buildDateItem('SEL', 9),
              _buildDateItem('RAB', 10),
              _buildDateItem('KAM', 11),
              _buildDateItem('JUM', 12),
              _buildDateItem('SAB', 13),
            ],
          ),
          const SizedBox(height: 16),

          // Daftar Event Dinamis
          if (events.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    Text(
                      'Tidak ada acara pada tanggal ini.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
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
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.handshake_outlined, color: AppColors.gold, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ingin Mengadakan Lokakarya?', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold)),
                      Text('Buka kelas seni atau diskusi budaya bersama komunitas Rumah Ratna.', style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(String day, int date) {
    final isSelected = selectedDate == date;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = date;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B1D2F) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF6B1D2F) : AppColors.border),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: imageColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            padding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                    child: Text(category, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.maroon)),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(time, style: const TextStyle(color: Colors.white, fontSize: 9)),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                    child: Text(seats, style: const TextStyle(color: Colors.white, fontSize: 8)),
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
                    const Icon(Icons.location_on_outlined, size: 12, color: AppColors.maroon),
                    const SizedBox(width: 4),
                    Text(location, style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(title, style: GoogleFonts.lora(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Biaya Partisipasi', style: GoogleFonts.plusJakartaSans(fontSize: 8, color: AppColors.textMuted)),
                        Text(price, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.maroon)),
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
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.maroon,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('PESAN TIKET', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold)),
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
