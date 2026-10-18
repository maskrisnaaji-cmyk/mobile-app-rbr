import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book_model.dart';
import '../theme/colors.dart';
import 'book_detail_view.dart';

class PustakaView extends StatelessWidget {
  const PustakaView({super.key});

  @override
  Widget build(BuildContext context) {
    final books = Book.dummyBooks;

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

          // Grid Buku 2 Kolom Dinamis
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: books.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              final book = books[index];
              return _buildBookGridCard(context, book);
            },
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

  Color _getCoverColor(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('jibril')) return const Color(0xFF4A1822);
    if (lower.contains('anjing') || lower.contains('lek')) return const Color(0xFF1E3A5F);
    if (lower.contains('peri')) return const Color(0xFF14532D);
    if (lower.contains('lipstik') || lower.contains('tejo')) return const Color(0xFF581C87);
    return const Color(0xFF2E384D);
  }

  String _getBookCoverImage(Book book) {
    if (book.coverImage.trim().isNotEmpty) {
      return book.coverImage.trim();
    }
    final slug = book.title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return 'assets/images/$slug.jpg';
  }

  Widget _buildBookGridCard(BuildContext context, Book book) {
    final coverImage = _getBookCoverImage(book);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailView(
                      book: book,
                      coverImage: coverImage,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          color: _getCoverColor(book.title),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_stories, color: Color(0xFFEAD8AD), size: 28),
                                const SizedBox(height: 6),
                                Text(
                                  book.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lora(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          book.shelfLocation,
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.textMuted),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailView(
                            book: book,
                            coverImage: coverImage,
                          ),
                        ),
                      );
                    },
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