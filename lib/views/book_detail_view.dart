import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book_model.dart';
import '../theme/colors.dart';

class BookDetailView extends StatefulWidget {
  final Book book;
  final String? coverImage;

  BookDetailView({
    super.key,
    Book? book,
    this.coverImage,
  }) : book = book ?? Book.dummyBooks.first;

  @override
  State<BookDetailView> createState() => _BookDetailViewState();
}

class _BookDetailViewState extends State<BookDetailView> {
  int _selectedTabIndex = 0;
  bool _isBookmarked = false;

  Book get book => widget.book;

  String get coverImagePath {
    if (widget.coverImage != null && widget.coverImage!.trim().isNotEmpty) {
      return widget.coverImage!.trim();
    }
    if (book.coverImage.trim().isNotEmpty) {
      return book.coverImage.trim();
    }
    final slug = book.title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return 'assets/images/$slug.jpg';
  }

  bool get isAvailable =>
      book.status.toLowerCase().contains('tersedia');

  Color get statusTextColor =>
      isAvailable ? const Color(0xFF2E7D32) : const Color(0xFFB45309);

  Color get statusBgColor =>
      isAvailable ? const Color(0xFFE8F5E9) : const Color(0xFFFEF3C7);

  Color get coverBaseColor {
    final titleLower = book.title.toLowerCase();
    if (titleLower.contains('jibril')) {
      return const Color(0xFF4A1822); // Maroon Klasik
    } else if (titleLower.contains('anjing') || titleLower.contains('lek')) {
      return const Color(0xFF1E3A5F); // Deep Navy
    } else if (titleLower.contains('peri')) {
      return const Color(0xFF14532D); // Deep Forest Green
    } else if (titleLower.contains('lipstik') || titleLower.contains('tejo')) {
      return const Color(0xFF581C87); // Deep Purple
    }
    return const Color(0xFF332A24);
  }

  void _showBorrowModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.maroon.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.menu_book, color: AppColors.maroon, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ajukan Peminjaman Fisik',
                        style: GoogleFonts.lora(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        'Pustaka Rumah Budaya Ratna',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.maroonDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Penulis: ${book.author} • Lokasi: ${book.shelfLocation}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.greyText,
                    ),
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.maroon),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isAvailable
                              ? 'Buku tersedia di ruang pustaka fisik. Peminjaman maksimal 7 hari kerja.'
                              : 'Status saat ini sedang dipinjam. Anda akan masuk dalam antrean reservasi.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Pengajuan peminjaman "${book.title}" berhasil dicatat! Kode: RBR-LIB-${DateTime.now().millisecondsSinceEpoch % 10000}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.maroon,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.maroon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isAvailable ? 'Konfirmasi Peminjaman' : 'Reservasi Antrean Buku',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFacsimilePreview() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.auto_stories, color: Color(0xFFFBC02D)),
            const SizedBox(width: 8),
            Text(
              'Pratinjau E-Faksimili',
              style: GoogleFonts.lora(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Digital Scan Preservasi Arsip Kertas Asli:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFBF8EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2D9C8)),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.picture_as_pdf_outlined, size: 40, color: AppColors.maroon),
                  const SizedBox(height: 8),
                  Text(
                    '${book.title.replaceAll(' ', '_')}_Faksimili.pdf',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${book.pageCount} Halaman • Resolusi Tinggi 600 DPI',
                    style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.greyText),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Tutup',
              style: GoogleFonts.plusJakartaSans(color: AppColors.greyText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Membuka penampil E-Faksimili untuk ${book.title}...',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12),
                  ),
                  backgroundColor: AppColors.maroon,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFBC02D),
              foregroundColor: const Color(0xFF3E2723),
              elevation: 0,
            ),
            child: Text(
              'Buka Faksimili',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0), // Latar cream lembut
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480), // Menjaga proporsi Mobile
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              // 1. Header Navigation Bar (Di dalam mobile frame 480px)
              _buildHeaderNavigation(),

              // 2. Konten Scrollable
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Section (Sampul & Status Badge)
                      _buildHeroSection(),

                      // Informasi Judul, Penulis, Spesifikasi & Aksi
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBookTitleAndAuthor(),
                            const SizedBox(height: 18),

                            // Grid Spesifikasi Buku (4 Kolom)
                            _buildSpecificationGrid(),
                            const SizedBox(height: 20),

                            // Tombol Aksi Utama & Sekunder
                            _buildActionButtons(),
                            const SizedBox(height: 24),

                            // Tab Bar Segmented Control
                            _buildTabBar(),
                            const SizedBox(height: 16),

                            // Konten Tab Dinamis (Sinopsis / Preservasi / Riwayat)
                            _buildTabContent(),
                            const SizedBox(height: 28),

                            // Section "Karya Terkait"
                            _buildRelatedSection(),
                            const SizedBox(height: 28),

                            // Footer Banner
                            _buildFooterBanner(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Header Navigation Bar (Mobile App Bar) ---
  Widget _buildHeaderNavigation() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 16,
        bottom: 8,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.maroon,
              size: 20,
            ),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          Expanded(
            child: Text(
              'Detail Buku',
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: _isBookmarked ? AppColors.maroon : AppColors.darkText,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isBookmarked
                        ? 'Buku disimpan ke daftar koleksi favorit Anda'
                        : 'Buku dihapus dari koleksi tersimpan',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12),
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.maroon,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.darkText,
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tautan katalog ${book.title} disalin ke clipboard',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12),
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.maroon,
                ),
              );
            },
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.maroon.withValues(alpha: 0.12),
            child: Text(
              book.author.isNotEmpty ? book.author[0] : 'R',
              style: GoogleFonts.lora(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.maroon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Hero Section (Sampul & Status Badge) ---
  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F5F0), // Latar krem sangat muda / abu-abu lembut
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Baris Atas Sampul: Badge Status (Kiri) & Badge Lokasi (Kanan)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge Status Dinamis (Tersedia / Dipinjam)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusTextColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusTextColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      book.status,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Badge Lokasi Rak Dinamis
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shelves, size: 14, color: AppColors.maroon),
                    const SizedBox(width: 5),
                    Text(
                      book.shelfLocation,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Gambar Sampul Buku: Terpusat di tengah dengan bayangan halus & sudut rounded
          Center(
            child: Container(
              width: 170,
              height: 245,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: coverBaseColor.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  coverImagePath,
                  width: 170,
                  height: 245,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildBookCoverArt(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Desain visual sampul buku dinamis berdasarkan parameter book
  Widget _buildBookCoverArt() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            coverBaseColor.withValues(alpha: 0.85),
            coverBaseColor,
            Colors.black.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Efek lipatan punggung buku di sisi kiri
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 12,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.white.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),

          // Border ornamen klasik
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFC59B27).withValues(alpha: 0.4),
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Detail teks pada sampul
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      book.category.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 7.5,
                        letterSpacing: 1.2,
                        color: const Color(0xFFEAD8AD),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 24,
                      height: 1,
                      color: const Color(0xFFC59B27),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      book.author.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lora(
                        fontSize: 11,
                        letterSpacing: 1.6,
                        color: const Color(0xFFF5EBE6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      book.title.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lora(
                        fontSize: 16,
                        height: 1.15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFE082),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Icon(
                      Icons.auto_stories,
                      size: 22,
                      color: Color(0xFFC59B27),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'EDISI KOLEKSI PUSTAKA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 7,
                        letterSpacing: 1.2,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${book.year} • RUMAH BUDAYA RATNA',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 7.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: const Color(0xFFC59B27),
                      ),
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

  // --- Informasi Judul & Penulis Dinamis ---
  Widget _buildBookTitleAndAuthor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtitle: Kategori Buku
        Text(
          book.category.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
            color: const Color(0xFFB48324), // Cokelat / gold
          ),
        ),
        const SizedBox(height: 6),

        // Judul Utama Dinamis
        Text(
          book.title,
          style: GoogleFonts.lora(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),

        // Penulis Dinamis + Badge Centang Emas/Verified
        Row(
          children: [
            Text(
              book.author,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.maroon,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.verified,
              size: 16,
              color: Color(0xFFC59B27), // Emas
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Deskripsi Penulis
        Text(
          'Sastrawan & Budayawan Terkemuka Nusantara',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            color: AppColors.greyText,
          ),
        ),
        const SizedBox(height: 10),

        // Rating & Review Dinamis
        Row(
          children: [
            const Icon(
              Icons.star_rounded,
              color: Color(0xFFFFB300),
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              book.rating.toStringAsFixed(1),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '•',
              style: TextStyle(color: Colors.grey.shade400),
            ),
            const SizedBox(width: 8),
            Text(
              '${book.reviewCount} telaah kuratorial',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Grid Spesifikasi Buku Dinamis (4 Kolom) ---
  Widget _buildSpecificationGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F0), // Latar abu-abu / krem muda halus
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEBE6DC)),
      ),
      child: Row(
        children: [
          // Kolom 1: Tahun (book.year), Sub-label (Cet. 1)
          _buildSpecColumn(
            book.year,
            'Cet. 1',
          ),
          _buildVerticalDivider(),

          // Kolom 2: Tebal (book.pageCount), Sub-label (Halaman)
          _buildSpecColumn(
            book.pageCount,
            'Halaman',
          ),
          _buildVerticalDivider(),

          // Kolom 3: Bahasa (book.language), Sub-label (Nusantara)
          _buildSpecColumn(
            book.language,
            'Melayu/IDN',
          ),
          _buildVerticalDivider(),

          // Kolom 4: Kondisi (book.condition), Sub-label (Terawat - Teks Hijau)
          _buildSpecColumn(
            book.condition.split(' ').first,
            book.condition.contains(' ')
                ? book.condition.substring(book.condition.indexOf(' ') + 1)
                : 'Terawat',
            subLabelColor: const Color(0xFF2E7D32),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecColumn(String value, String subLabel, {Color? subLabelColor}) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subLabel,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: subLabelColor != null ? FontWeight.bold : FontWeight.w500,
              color: subLabelColor ?? AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 28,
      color: const Color(0xFFE2DCD2),
    );
  }

  // --- Tombol Aksi Utama & Sekunder ---
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Tombol Utama: Ajukan Peminjaman Fisik
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _showBorrowModal,
            icon: const Icon(Icons.menu_book_rounded, size: 20),
            label: Text(
              'Ajukan Peminjaman Fisik',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.maroon, // #6B1D2F
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Row Tombol Sekunder
        Row(
          children: [
            // Kiri: Simpan Koleksi
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isBookmarked = !_isBookmarked;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isBookmarked
                              ? 'Tersimpan di rak koleksi Anda'
                              : 'Dihapus dari koleksi tersimpan',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12),
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppColors.maroon,
                      ),
                    );
                  },
                  icon: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    size: 18,
                    color: AppColors.maroon,
                  ),
                  label: Text(
                    _isBookmarked ? 'Tersimpan' : 'Simpan Koleksi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.maroon,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5EBE6),
                    side: const BorderSide(color: Color(0xFFEAD8D0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Kanan: Pratinjau E-Faksimili
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _showFacsimilePreview,
                  icon: const Icon(Icons.auto_stories, size: 18),
                  label: Text(
                    'Pratinjau E-Faksimili',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3E2723),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFBC02D), // Kuning Emas
                    foregroundColor: const Color(0xFF3E2723),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Tab Bar Segmented Control ---
  Widget _buildTabBar() {
    final tabs = ['Sinopsis', 'Preservasi & Rak', 'Riwayat Baca'];

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1.5),
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppColors.maroon : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.maroon : AppColors.greyText,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- Konten Tab Dinamis ---
  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildSynopsisCard();
      case 1:
        return _buildPreservationTab();
      case 2:
        return _buildReadingHistoryTab();
      default:
        return _buildSynopsisCard();
    }
  }

  // Tab 1: Konten Sinopsis Dinamis (Card Putih)
  Widget _buildSynopsisCard() {
    final defaultTags = [
      '#${book.category.replaceAll(' ', '')}',
      '#Arsip${book.year}',
      '#RumahBudayaRatna',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gema Moral & Pergolakan Batin',
            style: GoogleFonts.lora(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 10),

          // Teks Sinopsis dari book.synopsis
          Text(
            book.synopsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              height: 1.6,
              color: const Color(0xFF4A4441),
            ),
          ),
          const SizedBox(height: 14),

          // Tags / Hashtags (Pill chips)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: defaultTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EBE6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8DDD7)),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.maroon,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Tab 2: Preservasi & Rak
  Widget _buildPreservationTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.maroon, size: 20),
              const SizedBox(width: 8),
              Text(
                'Protokol Konservasi Arsip',
                style: GoogleFonts.lora(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPreservationRow('Kondisi Fisik', book.condition),
          _buildPreservationRow('Lokasi Rak', '${book.shelfLocation} (Pustaka Lantai 2)'),
          _buildPreservationRow('Suhu Ruang Rak', '20°C ± 2°C (Ruang Khusus RBR)'),
          _buildPreservationRow('Kelembapan', '50% RH (Stabil Terpantau)'),
          _buildPreservationRow('Kode Registrasi', 'RBR-ARS-${book.year}-${book.id.padLeft(4, '0')}'),
        ],
      ),
    );
  }

  Widget _buildPreservationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: AppColors.greyText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab 3: Riwayat Baca
  Widget _buildReadingHistoryTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catatan Telaah & Pengkaji',
            style: GoogleFonts.lora(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Naskah ini telah ditelaah oleh ${book.reviewCount} kurator & peneliti drama/sastra nusantara. Peminjaman fisik tercatat aktif untuk kajian pustaka berlisensi Rumah Budaya Ratna.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.5,
              color: AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }

  // --- Section "Karya Terkait" ---
  Widget _buildRelatedSection() {
    final otherBooks =
        Book.dummyBooks.where((b) => b.id != book.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Koleksi Pustaka Lainnya',
                    style: GoogleFonts.lora(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Koleksi naskah, sastra, & sejarah nusantara',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Row(
                  children: [
                    Text(
                      'Semua',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.maroon,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.maroon,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Horizontal ListView Card Buku Terkait
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: otherBooks.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final relatedBook = otherBooks[index];
              return _buildRelatedBookCard(relatedBook);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedBookCard(Book item) {
    final available = item.status.toLowerCase().contains('tersedia');
    final sColor = available ? const Color(0xFF2E7D32) : const Color(0xFFB45309);
    final sBg = available ? const Color(0xFFE8F5E9) : const Color(0xFFFEF3C7);

    final relatedImage = item.coverImage.trim().isNotEmpty
        ? item.coverImage.trim()
        : 'assets/images/${item.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '')}.jpg';

    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailView(
              book: item,
              coverImage: relatedImage,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 128,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Thumbnail dengan Badge Status
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                    child: Image.asset(
                      relatedImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.maroonDark,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.menu_book_outlined,
                              size: 26,
                              color: Colors.white70,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lora(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ),

                  // Badge Status
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: sBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        available ? 'Tersedia' : 'Dipinjam',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: sColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Teks Judul & Tahun
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tahun ${item.year}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      color: AppColors.greyText,
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

  // --- Footer Banner ---
  Widget _buildFooterBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F0), // Latar abu-abu lembut / krem
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEBE6DC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ikon Rumah Budaya (Kuning)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFBC02D).withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance,
              color: Color(0xFFB48324), // Emas / Kuning tua
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Teks & Deskripsi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rumah Budaya Ratna',
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.maroon,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Penyimpanan resmi naskah warisan sastra & drama nusantara.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    height: 1.4,
                    color: AppColors.greyText,
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
