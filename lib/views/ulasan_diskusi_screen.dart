import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/mobile_frame.dart';

class UlasanDiskusiScreen extends StatelessWidget {
  const UlasanDiskusiScreen({super.key});

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
            'Ulasan & Diskusi Saya',
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.maroonDark,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list_rounded, color: AppColors.textMain, size: 21),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ringkasan Aktivitas Telaah
              _buildSummaryHeader(),
              const SizedBox(height: 18),

              Text(
                'RIWAYAT ULASAN & TELAAH BUDAYA (8)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: AppColors.greyText,
                ),
              ),
              const SizedBox(height: 12),

              // Ulasan 1: Dokumen Jibril
              _buildReviewCard(
                context: context,
                bookTitle: 'Dokumen Jibril',
                author: 'W.S. Rendra • Naskah Drama Klasik',
                rating: 5,
                date: '14 Sep 2026',
                reviewText:
                    'Eksplorasi dialektika batin kemanusiaan yang sangat berani. Pementasan Bengkel Teater di naskah ini membuktikan kekuatan kritik sosial teater era 70-an yang tak lekang oleh waktu.',
                curatorReply:
                    'Telaah yang tajam Mas Aris! Kami simpan manuskrip catatan panggung aslinya di Rak 3A.',
                likes: 12,
                comments: 4,
              ),
              const SizedBox(height: 14),

              // Ulasan 2: Alun-Alun Malang
              _buildReviewCard(
                context: context,
                bookTitle: 'Alun-Alun Malang Tempo Doeloe',
                author: 'Dukut Imam Widodo • Sejarah Urban',
                rating: 5,
                date: '28 Agu 2026',
                reviewText:
                    'Dokumentasi visual dan catatan urban landscape masa kolonial sangat lengkap. Sangat membantu riset sejarah tata ruang kota Malang tempo doeloe.',
                curatorReply: null,
                likes: 7,
                comments: 2,
              ),
              const SizedBox(height: 14),

              // Ulasan 3: Laki-Laki Yang Kawin Dengan Peri
              _buildReviewCard(
                context: context,
                bookTitle: 'Laki-Laki Yang Kawin Dengan Peri',
                author: 'Eka Kurniawan • Sastra Realisme Magis',
                rating: 4,
                date: '10 Agu 2026',
                reviewText:
                    'Perpaduan mistisisme Jawa dan kritik kontemporer yang satir. Gaya bertuturnya segar dan memikat nurani pembaca.',
                curatorReply:
                    'Terima kasih atas diskusinya! Naskah ini salah satu bacaan wajib pada pot luck book club bulan lalu.',
                likes: 9,
                comments: 1,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('8', 'Total Ulasan', Icons.rate_review_outlined),
          Container(width: 1, height: 36, color: AppColors.lightBorder),
          _buildStatItem('3', 'Diskusi Aktif', Icons.forum_outlined),
          Container(width: 1, height: 36, color: AppColors.lightBorder),
          _buildStatItem('5', 'Tanggapan Kurator', Icons.verified_user_outlined),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.maroon),
            const SizedBox(width: 5),
            Text(
              count,
              style: GoogleFonts.lora(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: AppColors.greyText,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required BuildContext context,
    required String bookTitle,
    required String author,
    required int rating,
    required String date,
    required String reviewText,
    required String? curatorReply,
    required int likes,
    required int comments,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookTitle,
                      style: GoogleFonts.lora(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 1),
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
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            reviewText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.45,
              color: AppColors.darkText,
            ),
          ),
          if (curatorReply != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.maroon.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.maroon.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.bookmark_rounded, color: AppColors.maroon, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggapan Kurator Rumah Budaya Ratna',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.maroon,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          curatorReply,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: AppColors.darkText,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(color: AppColors.lightBorder, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ditulis pada $date',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: AppColors.greyText,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.thumb_up_alt_outlined, size: 13, color: AppColors.greyText),
                  const SizedBox(width: 4),
                  Text('$likes', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.greyText)),
                  const SizedBox(width: 12),
                  const Icon(Icons.chat_bubble_outline_rounded, size: 13, color: AppColors.greyText),
                  const SizedBox(width: 4),
                  Text('$comments', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.greyText)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
