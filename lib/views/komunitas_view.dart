import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class KomunitasView extends StatelessWidget {
  const KomunitasView({super.key});

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
                    child: const Icon(Icons.people, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text('Komunitas', style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                ],
              ),
              Row(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: AppColors.textMain)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined, color: AppColors.textMain)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text('PROFIL PENGGUNA', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.maroon)),
          const SizedBox(height: 8),

          // User Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.maroon,
                  child: Text('AW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aris Widiatmoko', style: GoogleFonts.lora(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                      Text('Avelnok77@gmail.com', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.goldLight, borderRadius: BorderRadius.circular(10)),
                            child: Text('Anggota Madya (Silver)', style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.gold, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('Aktivitas & Preferensi', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          const SizedBox(height: 10),

          // List Opsi Menu
          _buildOptionTile(
            icon: Icons.receipt_long_outlined,
            title: 'Riwayat Pesanan Kopi',
            subtitle: 'Kedai & Roastery Nusantara',
            badge: '12 Pesanan',
          ),
          const SizedBox(height: 8),
          _buildOptionTile(
            icon: Icons.confirmation_number_outlined,
            title: 'Tiket Event Saya',
            subtitle: 'Lokakarya, pentas & diskusi',
            badge: '2 Aktif',
          ),
          const SizedBox(height: 8),
          _buildOptionTile(
            icon: Icons.book_outlined,
            title: 'Buku Dipinjam',
            subtitle: 'Koleksi Pustaka Ratna',
            badge: '1 Jatuh Tempo 3 Hari',
            badgeColor: Colors.red.shade100,
            badgeTextColor: Colors.red.shade900,
          ),
          const SizedBox(height: 8),
          _buildOptionTile(
            icon: Icons.accessibility_new,
            title: 'Aksesibilitas & Tampilan',
            subtitle: 'Ukuran aksara, tema & suara',
          ),
          const SizedBox(height: 8),
          _buildOptionTile(
            icon: Icons.help_outline,
            title: 'Bantuan & FAQ',
            subtitle: 'Panduan kunjungan & reservasi',
          ),
          const SizedBox(height: 24),

          // Tombol Keluar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('KELUAR DARI AKUN', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    Color? badgeTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.tagBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.maroon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.textMuted)),
              ],
            ),
          ),
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor ?? AppColors.goldLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: badgeTextColor ?? AppColors.gold),
              ),
            ),
            const SizedBox(width: 6),
          ],
          const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textMuted),
        ],
      ),
    );
  }
}