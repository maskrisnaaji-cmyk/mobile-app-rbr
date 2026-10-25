import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book_model.dart';
import '../theme/colors.dart';
import 'book_detail_view.dart';

class KatalogView extends StatefulWidget {
  const KatalogView({super.key});

  @override
  State<KatalogView> createState() => _KatalogViewState();
}

class _KatalogViewState extends State<KatalogView> {
  final TextEditingController _searchController = TextEditingController();
  late List<Book> _allBooks;
  late List<Book> _filteredBooks;
  String _selectedCategory = 'Semua';
  final List<String> _categories = [
    'Semua',
    'Sastra',
    'Sejarah',
    'Seni & Budaya',
  ];

  @override
  void initState() {
    super.initState();
    _allBooks = Book.dummyBooks;
    _filteredBooks = List.from(_allBooks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBooks(String queryText) {
    final query = queryText.toLowerCase().trim();
    _filteredBooks = _allBooks.where((book) {
      final titleMatches = book.title.toLowerCase().contains(query);
      final authorMatches = book.author.toLowerCase().contains(query);
      final categoryMatches = book.category.toLowerCase().contains(query);

      final isCategorySelected = _selectedCategory == 'Semua' ||
          book.category == _selectedCategory ||
          book.category.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
          (_selectedCategory == 'Seni & Budaya' && book.category.toLowerCase().contains('budaya'));

      return (titleMatches || authorMatches || categoryMatches) && isCategorySelected;
    }).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Katalog Pustaka',
          style: GoogleFonts.lora(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              // Search & Filter header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          String query = value.toLowerCase();
                          _filteredBooks = _allBooks.where((book) {
                            final titleMatches = book.title.toLowerCase().contains(query);
                            final authorMatches = book.author.toLowerCase().contains(query);
                            final categoryMatches = book.category.toLowerCase().contains(query);

                            final isCategorySelected = _selectedCategory == 'Semua' ||
                                book.category == _selectedCategory ||
                                book.category.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
                                (_selectedCategory == 'Seni & Budaya' && book.category.toLowerCase().contains('budaya'));

                            return (titleMatches || authorMatches || categoryMatches) && isCategorySelected;
                          }).toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari judul buku, penulis, atau topik...',
                        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                                splashRadius: 18,
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _filterBooks('');
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.maroon, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((category) {
                          final isSelected = _selectedCategory == category;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                                _filterBooks(_searchController.text);
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.maroon : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? AppColors.maroon : AppColors.border),
                              ),
                              child: Text(
                                category,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.white : AppColors.textMain,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Grid / Empty state
              Expanded(
                child: _filteredBooks.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.maroon.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.search_off_rounded,
                                  size: 30,
                                  color: AppColors.maroon,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isNotEmpty
                                    ? "Buku '${_searchController.text}' tidak ditemukan"
                                    : "Tidak ada buku ditemukan",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lora(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _searchController.text.isNotEmpty
                                    ? 'Silakan coba kata kunci lain atau reset pencarian.'
                                    : 'Belum ada koleksi buku pada kategori ini.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              if (_searchController.text.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                TextButton.icon(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _filterBooks('');
                                    });
                                  },
                                  icon: const Icon(Icons.clear, size: 16, color: AppColors.maroon),
                                  label: Text(
                                    'Hapus Pencarian',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.maroon,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredBooks.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                        itemBuilder: (context, index) {
                          final selectedBook = _filteredBooks[index];
                          final coverImage = _getBookCoverImage(selectedBook);
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
                                            book: selectedBook,
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
                                                color: _getCoverColor(selectedBook.title),
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
                                                        selectedBook.title,
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
                                                selectedBook.shelfLocation,
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
                                        selectedBook.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        selectedBook.author,
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
                                                  book: selectedBook,
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
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
