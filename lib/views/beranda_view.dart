import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class BerandaView extends StatelessWidget {
  final Function(int)? onNavigateTab;
  const BerandaView({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
                    child: const Icon(Icons.other_houses, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Beranda',
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.tagBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.maroon,
                          child: Text('RA', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ratna Anindita',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search, size: 20, color: AppColors.textMain),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none, size: 20, color: AppColors.textMain),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Banner Hero Utama (Dengan Gradient & Shadow Lebih Mewah)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF521513), Color(0xFF80221E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.maroon.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'CAGAR BUDAYA & LITERASI',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Rumah Budaya Ratna',
                  style: GoogleFonts.lora(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ruang temu seni, pemikiran, dan rasa di tengah kehangatan tradisi Jawa.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () => onNavigateTab?.call(3),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Pelajari Selengkapnya',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Akses Cepat Grid
          Text(
            'AKSES CEPAT',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuickAccessItem(Icons.coffee_outlined, 'Pesan Kopi', () => onNavigateTab?.call(1)),
              _buildQuickAccessItem(Icons.menu_book_outlined, 'Katalog Buku', () => onNavigateTab?.call(2)),
              _buildQuickAccessItem(Icons.calendar_month_outlined, 'Event', () => onNavigateTab?.call(3)),
              _buildQuickAccessItem(Icons.person_outline, 'Profil', () => onNavigateTab?.call(4)),
            ],
          ),
          const SizedBox(height: 24),

          // Koleksi Populer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Koleksi Populer',
                style: GoogleFonts.lora(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textMain),
              ),
              GestureDetector(
                onTap: () => onNavigateTab?.call(2),
                child: Text(
                  'Lihat Semua >',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.maroon, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildBookCard('Dokumen Jibril', 'Eko Triono', 'Rak 2A', const Color(0xFF1F2421)),
                const SizedBox(width: 12),
                _buildBookCard('Seni Batik Jawa', 'Nian S. L.', 'Rak 1B', const Color(0xFF3B5249)),
                const SizedBox(width: 12),
                _buildBookCard('Laki-Laki Peri', 'Eka Kurniawan', 'Rak 2C', const Color(0xFF513B41)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Agenda Mendatang
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Agenda Mendatang',
                style: GoogleFonts.lora(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textMain),
              ),
              Text(
                'Kalender >',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.maroon, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
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
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.tagBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text('SEN', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                      Text('12', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.maroon)),
                      Text('SEP', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('19.00 WIB • Pendopo Utama', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textMuted)),
                      const SizedBox(height: 2),
                      Text(
                        'Malam Akustik & Puisi Nusantara',
                        style: GoogleFonts.lora(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMain),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => onNavigateTab?.call(3),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.maroon,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Reservasi', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quote Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.goldLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: Text(
              '"Membaca adalah merawat ingatan, berbudaya adalah merawat martabat."',
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppColors.textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.maroon, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(String title, String author, String shelf, Color coverColor) {
    return Container(
      width: 125,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            height: 135,
            width: double.infinity,
            decoration: BoxDecoration(
              color: coverColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            padding: const EdgeInsets.all(8),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(shelf, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ),
                Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMain),
                ),
                Text(
                  author,
                  style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}