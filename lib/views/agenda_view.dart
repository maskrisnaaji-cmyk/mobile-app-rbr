import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class AgendaView extends StatelessWidget {
  const AgendaView({super.key});

  @override
  Widget build(BuildContext context) {
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

          // Horizontal Date Selector Strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateItem('SEN', '08', isSelected: false),
              _buildDateItem('SEL', '09', isSelected: false),
              _buildDateItem('RAB', '10', isSelected: true),
              _buildDateItem('KAM', '11', isSelected: false),
              _buildDateItem('JUM', '12', isSelected: false),
              _buildDateItem('SAB', '13', isSelected: false),
            ],
          ),
          const SizedBox(height: 16),

          // Event Card 1
          _buildEventCard(
            category: 'Lokakarya',
            time: '10 Sep • 15:30 WIB',
            seats: 'Sisa 4 Kursi',
            location: 'Ruang Komunal Lt. 2',
            title: 'Napak Tanah Jilid II Book Club & Pot Luck',
            price: 'Rp 25.000',
            imageColor: Colors.brown.shade700,
          ),
          const SizedBox(height: 16),

          // Event Card 2
          _buildEventCard(
            category: 'Wicara Seni',
            time: '10 Sep • 19:00 WIB',
            seats: 'Sisa 12 Kursi',
            location: 'Panggung Utama Pendopo',
            title: 'Penampilan Seni Teater Pak Rungkad Belum Ketemu',
            price: 'Rp 35.000',
            imageColor: Colors.black87,
          ),
          const SizedBox(height: 16),

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

  Widget _buildDateItem(String day, String date, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.maroon : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? AppColors.maroon : AppColors.border),
      ),
      child: Column(
        children: [
          Text(day, style: GoogleFonts.plusJakartaSans(fontSize: 9, color: isSelected ? Colors.white70 : AppColors.textMuted)),
          Text(date, style: GoogleFonts.lora(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textMain)),
        ],
      ),
    );
  }

  Widget _buildEventCard({
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
                      onPressed: () {},
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