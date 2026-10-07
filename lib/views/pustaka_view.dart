import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class PustakaView extends StatelessWidget {
  const PustakaView({super.key});

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
                    decoration: const BoxDecoration(
                      color: AppColors.maroon,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.menu_book, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pustaka Ratna',
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
                  IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: AppColors.textMain)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: AppColors.textMain)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text('Katalog Pustaka', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          Text('Koleksi naskah, sastra, & sejarah Nusantara', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 12),

          // Search Field
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari judul buku, penulis, atau topik...',
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
          const SizedBox(height: 12),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua', isSelected: true),
                _buildFilterChip('Sastra'),
                _buildFilterChip('Sejarah'),
                _buildFilterChip('Seni & Budaya'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Grid Buku 2 Kolom
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.65,
            children: [
              _buildBookGridCard('Dokumen Jibril', 'Eko Triono', 'Rak 2A', Colors.black87),
              _buildBookGridCard('Anjing-Anjing Menyerbu Lek Zal', 'C.R. Tanujaya', 'Rak 3B', Colors.brown.shade800),
              _buildBookGridCard('Laki-Laki Yang Kawin Dengan Peri', 'Eka Kurniawan', 'Rak 2C', Colors.blueGrey),
              _buildBookGridCard('Lipstik Di Tas Doni', 'Sujiwo Tejo', 'Rak 1A', Colors.purple.shade900),
            ],
          ),
          const SizedBox(height: 20),

          // Banner Bantuan Pustakawan
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.headset_mic, color: AppColors.maroon, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BUTUH BANTUAN PUSTAKAWAN?', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                      Text('Tanya referensi naskah atau peminjaman.', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textMain)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Tanya Pustakawan', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.maroon : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.maroon : AppColors.border),
      ),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: isSelected ? Colors.white : AppColors.textMain)),
    );
  }

  Widget _buildBookGridCard(String title, String author, String shelf, Color coverColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: coverColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                      child: Text(shelf, style: const TextStyle(color: Colors.white, fontSize: 8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold)),
                Text(author, style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.textMuted)),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.maroon,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text('DETAIL BUKU ->', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}