import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/mobile_frame.dart';

class PeminjamanBukuScreen extends StatelessWidget {
  const PeminjamanBukuScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            'Peminjaman Buku',
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.maroonDark,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline_rounded, color: AppColors.textMain, size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Maksimal 2 buku fisik per anggota dengan durasi 14 hari pinjam.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12),
                    ),
                    backgroundColor: AppColors.maroon,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Kuota Peminjaman
              _buildQuotaBanner(),
              const SizedBox(height: 18),

              // Subjudul Daftar Buku Aktif
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BUKU SEDANG DIPINJAM (2)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: AppColors.greyText,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'STATUS: AKTIF',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF15803D),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Item Buku 1: LemahTulis
              _buildBookLoanCard(
                context: context,
                title: 'LemahTulis',
                author: 'Budi Maryono • Arsip Sastra Jawa Timur',
                category: 'Naskah Sejarah & Sastra Lokal',
                borrowDate: '12 Okt 2026',
                dueDate: '26 Okt 2026',
                daysLeft: 'Sisa 9 Hari',
                codeRak: 'PUST-LT-019 • RAK 2B',
                coverIcon: Icons.menu_book_rounded,
                isUrgent: false,
              ),
              const SizedBox(height: 12),

              // Item Buku 2: Alun-Alun Malang
              _buildBookLoanCard(
                context: context,
                title: 'Alun-Alun Malang',
                author: 'Dukut Imam Widodo • Babad Sejarah Urban',
                category: 'Arsip Sejarah & Lanskap Kota',
                borrowDate: '14 Okt 2026',
                dueDate: '28 Okt 2026',
                daysLeft: 'Sisa 11 Hari',
                codeRak: 'PUST-MLG-042 • RAK 1A',
                coverIcon: Icons.auto_stories_rounded,
                isUrgent: false,
              ),
              const SizedBox(height: 20),

              // Panduan dan Aturan Pengembalian
              _buildReturnRulesCard(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuotaBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.maroon.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.library_books_rounded, color: AppColors.maroon, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kartu Anggota: RBR-2026-0881',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.maroon,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '2 dari 2 Kuota Buku Terpakai',
                  style: GoogleFonts.lora(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kembalikan buku sebelum jatuh tempo untuk meminjam judul lain.',
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
    );
  }

  Widget _buildBookLoanCard({
    required BuildContext context,
    required String title,
    required String author,
    required String category,
    required String borrowDate,
    required String dueDate,
    required String daysLeft,
    required String codeRak,
    required IconData coverIcon,
    required bool isUrgent,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
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
                width: 46,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.maroon.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.maroon.withValues(alpha: 0.2)),
                ),
                child: Center(
                  child: Icon(coverIcon, color: AppColors.maroon, size: 26),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.tagBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.maroon,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: GoogleFonts.lora(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      author,
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
          const SizedBox(height: 12),
          const Divider(color: AppColors.lightBorder, height: 1),
          const SizedBox(height: 10),

          // Detail Tanggal Pinjam & Jatuh Tempo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TANGGAL PINJAM',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    borrowDate,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JATUH TEMPO',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dueDate,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.maroon,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUrgent ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isUrgent ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0),
                  ),
                ),
                child: Text(
                  daysLeft,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isUrgent ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 14, color: AppColors.greyText),
              const SizedBox(width: 4),
              Text(
                codeRak,
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.greyText),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tombol Perpanjang & Detail
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Permintaan perpanjangan buku "$title" berhasil diajukan (+7 hari)!',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12),
                        ),
                        backgroundColor: AppColors.maroon,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.maroon, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                  child: Text(
                    'Perpanjang (1x)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.maroon,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Menampilkan tata letak rak fisik untuk "$title"',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12),
                      ),
                      backgroundColor: AppColors.darkText,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.maroon,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                ),
                child: Text(
                  'Lokasi Rak',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReturnRulesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADBCE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rule_rounded, color: AppColors.maroon, size: 18),
              const SizedBox(width: 8),
              Text(
                'Ketentuan Peminjaman Pustaka',
                style: GoogleFonts.lora(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Pengembalian buku dilakukan di Meja Sirkulasi Pustaka Lt. 1 Rumah Budaya Ratna.\n'
            '• Setiap judul dapat diperpanjang maksimal 1 kali selama belum dipesan anggota lain.\n'
            '• Keterlambatan dikenakan infaq pemeliharaan koleksi Rp 1.000 / hari per buku.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              height: 1.5,
              color: AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }
}
