import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/mobile_frame.dart';

class KoleksiFavoritScreen extends StatefulWidget {
  const KoleksiFavoritScreen({super.key});

  @override
  State<KoleksiFavoritScreen> createState() => _KoleksiFavoritScreenState();
}

class _KoleksiFavoritScreenState extends State<KoleksiFavoritScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Semua (14)', 'Naskah Drama', 'Manuskrip & Arsip', 'Prosa Budaya'];

  final List<Map<String, dynamic>> _allFavorites = [
    {
      'title': 'Dokumen Jibril',
      'author': 'W.S. Rendra',
      'category': 'Naskah Drama',
      'year': '1978',
      'rating': 4.9,
      'shelf': 'RAK 3A',
      'desc': 'Naskah monumental dialektika moral dan kritik sosial tajam era 70-an Bengkel Teater.',
      'icon': Icons.theater_comedy_rounded,
    },
    {
      'title': 'LemahTulis: Babad Naskah',
      'author': 'Arsip Koleksi Kuno Singhasari',
      'category': 'Manuskrip & Arsip',
      'year': '1820',
      'rating': 5.0,
      'shelf': 'RAK 1C',
      'desc': 'Transkripsi tembang pupuh aksara Jawa Kuno mengenai kosmologi tanah Malang.',
      'icon': Icons.menu_book_rounded,
    },
    {
      'title': 'Anjing-Anjing Menyerbu Lek Zai',
      'author': 'C.R. Tanujaya',
      'category': 'Naskah Drama',
      'year': '1984',
      'rating': 4.7,
      'shelf': 'RAK 3B',
      'desc': 'Satir panggung pertarungan hak tanah masyarakat agraris dan modernisasi.',
      'icon': Icons.theater_comedy_rounded,
    },
    {
      'title': 'Laki-Laki Yang Kawin Dengan Peri',
      'author': 'Eka Kurniawan',
      'category': 'Prosa Budaya',
      'year': '2015',
      'rating': 4.8,
      'shelf': 'RAK 2C',
      'desc': 'Realisme magis yang meramu mitos nusantara, tragedi cinta, dan satir kehidupan.',
      'icon': Icons.auto_stories_rounded,
    },
    {
      'title': 'Serat Centhini: Faksimili Jilid IV',
      'author': 'Tim Preservasi Kraton Surakarta',
      'category': 'Manuskrip & Arsip',
      'year': '1814',
      'rating': 4.9,
      'shelf': 'RAK 1B',
      'desc': 'Ensiklopedia kebudayaan, spiritualitas, kuliner, dan tata laku tanah Jawa.',
      'icon': Icons.menu_book_rounded,
    },
    {
      'title': 'Alun-Alun Malang Tempo Doeloe',
      'author': 'Dukut Imam Widodo',
      'category': 'Prosa Budaya',
      'year': '2004',
      'rating': 4.8,
      'shelf': 'RAK 1A',
      'desc': 'Rekonstruksi visual sejarah tata ruang kota Malang pada era kolonial Hindia Belanda.',
      'icon': Icons.history_edu_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredList = _allFavorites.where((item) {
      if (_selectedFilter == 0) return true;
      if (_selectedFilter == 1) return item['category'] == 'Naskah Drama';
      if (_selectedFilter == 2) return item['category'] == 'Manuskrip & Arsip';
      if (_selectedFilter == 3) return item['category'] == 'Prosa Budaya';
      return true;
    }).toList();

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
            'Koleksi Favorit',
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.maroonDark,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded, color: AppColors.textMain, size: 21),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            // Filter Tabs
            Container(
              height: 40,
              margin: const EdgeInsets.only(top: 4, bottom: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == index;
                  return InkWell(
                    onTap: () => setState(() => _selectedFilter = index),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.maroon : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.maroon : AppColors.lightBorder,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _filters[index],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.greyText,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Daftar Koleksi Favorit
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filteredList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = filteredList[index];
                  return _buildFavoriteCard(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.maroon.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.maroon.withValues(alpha: 0.2)),
                ),
                child: Center(
                  child: Icon(item['icon'] as IconData, color: AppColors.maroon, size: 26),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.tagBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['category'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.maroon,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Buku "${item['title']}" dihapus dari favorit.'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          child: const Icon(Icons.bookmark_rounded, color: AppColors.maroon, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['title'] as String,
                      style: GoogleFonts.lora(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item['author']} • ${item['year']}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item['desc'] as String,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.darkText.withValues(alpha: 0.8),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.lightBorder, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${item['rating']}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '•  ${item['shelf']}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Membuka rincian naskah "${item['title']}"...'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    Text(
                      'Baca / Akses',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.maroon,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_rounded, size: 13, color: AppColors.maroon),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
