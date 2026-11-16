import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/core/widgets/mobile_frame.dart';
import 'package:mobile_app/features/profil/viewmodels/profil_viewmodel.dart';

class TentangView extends StatelessWidget {
  final ProfilViewModel? viewModel;

  const TentangView({super.key, this.viewModel});

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

              // ─── Tentang RBR ──────────────────────────────────────────────
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

          // Badge ruang budaya
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
                  'RUANG BUDAYA MALANG',
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
        // Foto Rumah Budaya Ratna dengan overlay maroon
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
              Positioned.fill(
                child: Image.asset(
                  'assets/images/welcome_rbr.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.maroonDark.withValues(alpha: 0.78),
                        AppColors.maroon.withValues(alpha: 0.72),
                        const Color(0xFF21070D).withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                ),
              ),
              // Pola dekoratif batik
              Positioned.fill(
                child: Opacity(
                  opacity: 0.07,
                  child: CustomPaint(painter: _BatikPatternPainter()),
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
                        _heroBadge(
                            Icons.local_library_outlined, 'Perpustakaan'),
                        _heroBadge(Icons.coffee_outlined, 'Kedai Kopi'),
                        _heroBadge(Icons.groups_2_outlined, 'Ruang Komunitas'),
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
                          'Jl. Diponegoro No. 3, Klojen, Malang',
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
                'Tentang Rumah Budaya Ratna',
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
              'Rumah Budaya Ratna (RBR) adalah ruang budaya berbasis komunitas di rumah peninggalan sastrawan Ratna Indraswari Ibrahim, Jl. Diponegoro No. 3, Klojen, Kota Malang. RBR diresmikan pada 24 Agustus 2024 sebagai ruang yang mempertemukan buku, seni, kopi, dan percakapan.\n\nRBR terbuka untuk pembaca, mahasiswa, seniman, komunitas, dan siapa saja yang ingin membaca, berdiskusi, berkarya, atau menikmati suasana rumah yang hangat. Semangatnya adalah merawat warisan Ratna sekaligus membuat literasi dan kebudayaan terasa dekat dengan masyarakat.',
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
                  value: '2024',
                  label: 'Tahun\nBerdiri',
                  color: AppColors.maroon,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.event_note_rounded,
                  value: '300+',
                  label: 'Cerpen\nRatna',
                  color: Color(0xFF9C3145),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.people_alt_rounded,
                  value: '11–22',
                  label: 'Jam Buka\nSetiap Hari',
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
                'Sosok Ratna Indraswari Ibrahim',
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/images/ratna_indraswari_ibrahim.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
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
                            'Malang, 24 April 1949 – 28 Maret 2011',
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
                              _profileTag('Sastrawan'),
                              _profileTag('Aktivis Perempuan'),
                              _profileTag('Inklusi & Disabilitas'),
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
                  'Ratna Indraswari Ibrahim adalah sastrawan kelahiran Malang yang dikenal melalui cerpen, novel, puisi, artikel, dan esainya. Ia tetap produktif berkarya meski mengalami keterbatasan fisik sejak kecil.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    height: 1.65,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ratna juga aktif menyuarakan isu perempuan, kelompok marjinal, dan aksesibilitas. Karya serta rumahnya kini menjadi napas bagi RBR: sebuah ruang inklusif yang menjaga ingatan, buku, dan percakapan agar terus hidup di Malang.',
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
                  'Warisan Ratna terus dihidupkan melalui buku, ruang temu, seni, dan komunitas yang terbuka untuk semua.',
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
                  'Semangat Rumah Budaya Ratna',
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

          // Perpustakaan dan ruang baca
          const _FasilitasCard(
            icon: Icons.menu_book_rounded,
            iconBgColor: AppColors.maroon,
            title: 'Perpustakaan & Ruang Baca',
            imageAssets: ['assets/images/ruang_literasi.jpg'],
            description:
                'Rak buku dan koleksi bacaan hadir di ruang rumah yang tenang. Pengunjung dapat membaca, mengerjakan tugas, atau berdiskusi tanpa suasana perpustakaan yang kaku.',
            tags: ['Koleksi Buku', 'Ruang Baca', 'Ramah Pelajar'],
            bottomChip: null,
          ),
          const SizedBox(height: 12),

          // Kedai kopi
          const _FasilitasCard(
            icon: Icons.coffee_rounded,
            iconBgColor: Color(0xFF7C4A1E),
            title: 'Kedai Kopi & Ruang Santai',
            imageAssets: [
              'assets/images/cafe_dalam.jpg',
              'assets/images/kasir.jpg',
            ],
            description:
                'Kafe bernuansa rumah untuk menikmati kopi dan minuman sambil membaca atau berbincang. Suasananya sederhana, hangat, dan nyaman untuk berlama-lama.',
            tags: ['Kopi & Minuman', 'Suasana Rumahan'],
            bottomChip: 'Buka Setiap Hari • 11.00–22.00 WIB',
          ),
          const SizedBox(height: 12),

          // Ruang komunitas dan kegiatan budaya
          const _FasilitasCard(
            icon: Icons.theater_comedy_outlined,
            iconBgColor: Color(0xFF9C3145),
            title: 'Ruang Seni & Komunitas',
            imageAssets: ['assets/images/rbr_frontt.jpg'],
            description:
                'RBR menjadi titik temu untuk bedah buku, diskusi budaya, pembacaan puisi, teater, musik, workshop, dan kegiatan komunitas lintas generasi.',
            tags: ['Diskusi', 'Pentas Seni', 'Workshop'],
            bottomChip: 'Terbuka untuk Kolaborasi',
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
  final List<String> imageAssets;
  final String description;
  final List<String> tags;
  final String? bottomChip;

  const _FasilitasCard({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.imageAssets,
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

          // Foto fasilitas
          SizedBox(
            height: 122,
            child: Row(
              children: imageAssets
                  .map(
                    (asset) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: asset == imageAssets.last ? 0 : 8,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            asset,
                            height: 122,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.tagBg,
                              child: const Center(
                                child: Icon(
                                  Icons.photo_outlined,
                                  color: AppColors.maroon,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3)),
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
