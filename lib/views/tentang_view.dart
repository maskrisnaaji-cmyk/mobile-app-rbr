import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/mobile_frame.dart';

class TentangView extends StatelessWidget {
  const TentangView({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors, prefer_const_literals_to_create_immutables
    return MobileFrame(
      // ignore: prefer_const_constructors
      child: Scaffold(
        backgroundColor: AppColors.bgCanvas,
        // ignore: prefer_const_constructors
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          // ignore: prefer_const_constructors, prefer_const_literals_to_create_immutables
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // ─── App Header ───────────────────────────────────────────────
              _AppHeader(),

              // ─── Hero Banner ──────────────────────────────────────────────
              _HeroBanner(),

              // ─── Misi & Perjalanan ────────────────────────────────────────
              _MisiSection(),

              // ─── Profil Ratna Indraswari ──────────────────────────────────
              _ProfilRatnaSection(),

              // ─── Fasilitas Rumah Budaya ───────────────────────────────────
              _FasilitasSection(),

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 12,
        right: 16,
        bottom: 10,
      ),
      child: Row(
        children: [
          // Tombol Kembali
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.tagBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.maroon,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Judul
          Expanded(
            child: Text(
              'Tentang Rumah Budaya Ratna',
              style: GoogleFonts.lora(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
          ),

          // Badge Cagar Budaya
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B1D2F), Color(0xFF9C3145)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_rounded,
                    size: 11, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  'CAGAR BUDAYA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: Colors.white,
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

// ─────────────────────────────────────────────────────────────────────────────
// HERO BANNER
// ─────────────────────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient (representasi gedung / visual)
        Container(
          width: double.infinity,
          height: 240,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2C0A13), Color(0xFF6B1D2F), Color(0xFF9C3145)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Pola dekoratif batik
              Positioned.fill(
                child: Opacity(
                  opacity: 0.07,
                  child: CustomPaint(painter: _BatikPatternPainter()),
                ),
              ),
              // Ikon gedung besar sebagai placeholder gambar
              const Positioned(
                right: -20,
                bottom: -10,
                child: Opacity(
                  opacity: 0.12,
                  child: Icon(
                    Icons.account_balance,
                    size: 200,
                    color: Colors.white,
                  ),
                ),
              ),
              // Konten teks di atas gambar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge baris atas
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _heroBadge(Icons.group_work_outlined, 'Ruang Kolaborasi'),
                        _heroBadge(Icons.auto_stories_outlined, 'Konservasi Naskah'),
                        _heroBadge(Icons.palette_outlined, 'Komunitas Seni'),
                      ],
                    ),
                    const Spacer(),
                    // Judul
                    Text(
                      'Rumah Budaya\nRatna',
                      style: GoogleFonts.lora(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Info lokasi
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 13, color: Color(0xFFEAD8AD)),
                        const SizedBox(width: 4),
                        Text(
                          'Malang, Jawa Timur  •  Terbuka untuk Umum',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            color: const Color(0xFFEAD8AD),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom arc overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.bgCanvas,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEKSI MISI & PERJALANAN
// ─────────────────────────────────────────────────────────────────────────────
class _MisiSection extends StatelessWidget {
  const _MisiSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label seksi
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.maroon,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Misi & Perjalanan',
                style: GoogleFonts.lora(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Narasi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.lightBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Rumah Budaya Ratna adalah cagar budaya yang berdiri di jantung Kota Malang sebagai warisan dari Ratna Indraswari Ibrahim — penulis, pejuang literasi, dan aktivis hak disabilitas. Tempat ini hadir sebagai ruang temu antara seni, pemikiran, dan tradisi Jawa, terbuka bagi siapa pun yang ingin merawat ingatan kolektif bangsa.\n\nDidirikan dengan semangat inklusivitas, Rumah Budaya Ratna terus menghidupkan program-program pelestarian naskah, pameran seni, diskusi publik, dan pemberdayaan komunitas lokal — selaras dengan nilai bahwa kebudayaan adalah hak semua orang.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                height: 1.7,
                color: AppColors.textMain,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3 Kartu Statistik
          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.auto_stories_rounded,
                  value: '400+',
                  label: 'Karya\nTerdokumentasi',
                  color: AppColors.maroon,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.event_note_rounded,
                  value: '12',
                  label: 'Program\n/ Tahun',
                  color: Color(0xFF9C3145),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.people_alt_rounded,
                  value: '∞',
                  label: 'Komunitas\nTerbuka',
                  color: Color(0xFFC59B27),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.lora(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEKSI PROFIL RATNA INDRASWARI
// ─────────────────────────────────────────────────────────────────────────────
class _ProfilRatnaSection extends StatelessWidget {
  const _ProfilRatnaSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label seksi
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.maroon,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Profil Ratna Indraswari (1949 – 2011)',
                style: GoogleFonts.lora(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Card profil
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto profil + nama
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar representatif
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B1D2F), Color(0xFF9C3145)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.maroon.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.12,
                              child: CustomPaint(
                                painter: _BatikPatternPainter(),
                              ),
                            ),
                          ),
                          const Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ratna Indraswari Ibrahim',
                            style: GoogleFonts.lora(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '1949 – 2011',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.maroon,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              _profileTag('Penulis'),
                              _profileTag('Aktivis'),
                              _profileTag('Pejuang Literasi'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Divider
                Container(height: 1, color: AppColors.lightBorder),
                const SizedBox(height: 14),

                // Biografi
                Text(
                  'Ratna Indraswari Ibrahim adalah seorang novelis, cerpenis, dan pejuang hak disabilitas yang lahir di Malang, Jawa Timur. Meskipun mengalami keterbatasan fisik sejak kecil, beliau tidak pernah berhenti berkarya dan berjuang.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    height: 1.65,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Beliau dikenal luas atas novelnya yang kaya akan nilai budaya Jawa dan perjuangan kemanusiaan. Melalui Rumah Budaya Ratna, warisannya terus hidup sebagai ruang yang inklusif dan terbuka bagi seluruh lapisan masyarakat — membuktikan bahwa seni dan literasi adalah milik semua.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    height: 1.65,
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Quote Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.goldLight,
                  Color(0xFFFFF8E7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  color: AppColors.gold,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  '"Keterbatasan fisik bukanlah batas bagi jiwa untuk merengkuh semesta kita."',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lora(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMain,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '— Ratna Indraswari Ibrahim',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.maroon,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _profileTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.tagBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.maroon.withValues(alpha: 0.15)),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppColors.maroon,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEKSI FASILITAS RUMAH BUDAYA
// ─────────────────────────────────────────────────────────────────────────────
class _FasilitasSection extends StatelessWidget {
  const _FasilitasSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label seksi
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.maroon,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Fasilitas Rumah Budaya',
                style: GoogleFonts.lora(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Kartu Perpustakaan Naskah
          const _FasilitasCard(
            icon: Icons.menu_book_rounded,
            iconBgColor: AppColors.maroon,
            title: 'Perpustakaan Naskah',
            description:
                'Koleksi lebih dari 400 naskah, buku, dan dokumen budaya Jawa yang terpelihara dengan baik. Tersedia ruang baca nyaman untuk umum.',
            tags: ['Koleksi Naskah', 'Ruang Baca', 'Digital Archive'],
            bottomChip: null,
          ),
          const SizedBox(height: 12),

          // Kartu Kedai Kopi & Teras Diskusi
          const _FasilitasCard(
            icon: Icons.coffee_rounded,
            iconBgColor: Color(0xFF7C4A1E),
            title: 'Kedai Kopi & Teras Diskusi',
            description:
                'Nikmati kopi pilihan dari petani lokal Jawa Timur sambil berdiskusi di teras yang hangat. Didesain inklusif dan ramah bagi semua pengunjung.',
            tags: ['Kopi Lokal', 'Diskusi Publik'],
            bottomChip: 'Inklusi / Ramah Kursi Roda',
          ),
        ],
      ),
    );
  }
}

class _FasilitasCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String description;
  final List<String> tags;
  final String? bottomChip;

  const _FasilitasCard({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.description,
    required this.tags,
    this.bottomChip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon + Judul
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Deskripsi
          Text(
            description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.6,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 12),

          // Tags
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags
                .map(
                  (tag) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.tagBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppColors.maroon.withValues(alpha: 0.15)),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.maroon,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          // Chip aksesibilitas (opsional)
          if (bottomChip != null) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.accessible_forward_rounded,
                      size: 13, color: Color(0xFF059669)),
                  const SizedBox(width: 5),
                  Text(
                    bottomChip!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER: Batik Pattern (dekoratif)
// ─────────────────────────────────────────────────────────────────────────────
class _BatikPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const spacing = 30.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), 6, paint);
        canvas.drawCircle(Offset(x, y), 10, paint..strokeWidth = 0.5);
      }
    }
  }

  @override
  bool shouldRepaint(_BatikPatternPainter oldDelegate) => false;
}
