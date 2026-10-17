import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/mobile_frame.dart';

class PusatBantuanScreen extends StatelessWidget {
  const PusatBantuanScreen({super.key});

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
            'Pusat Bantuan & Panduan',
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.maroonDark,
            ),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Hubungi Kurator
              _buildCuratorContactBanner(context),
              const SizedBox(height: 20),

              // Tombol Bantuan Cepat WhatsApp & Email
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      context: context,
                      title: 'Chat WhatsApp',
                      subtitle: 'Kurator Pustaka',
                      icon: Icons.chat_bubble_rounded,
                      bgColor: const Color(0xFFDCFCE7),
                      iconColor: const Color(0xFF15803D),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Menghubungkan ke WhatsApp Kurator (+62 812-3456-7890)...',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12),
                            ),
                            backgroundColor: const Color(0xFF15803D),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionButton(
                      context: context,
                      title: 'Kirim Email',
                      subtitle: 'halo@budaya.id',
                      icon: Icons.mail_outline_rounded,
                      bgColor: AppColors.maroon.withValues(alpha: 0.08),
                      iconColor: AppColors.maroon,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Membuka aplikasi email ke halo@rumahbudayaratna.id...',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12),
                            ),
                            backgroundColor: AppColors.maroon,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section Tanya Jawab Sering Ditanyakan (FAQ)
              Text(
                'PERTANYAAN SERING DIAJUKAN (FAQ)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: AppColors.greyText,
                ),
              ),
              const SizedBox(height: 12),
              _buildFaqSection(context),
              const SizedBox(height: 24),

              // Panduan Etika Salon Pustaka & Preservasi
              _buildVenueGuideCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCuratorContactBanner(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.maroon.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.support_agent_rounded, color: AppColors.maroon, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Layanan Bantuan & Kurasi',
                      style: GoogleFonts.lora(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Butuh bantuan riset naskah, reservasi salon pustaka, atau tiket agenda?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.greyText,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Membuka tautan chat WhatsApp Kurator Rumah Budaya Ratna...',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12),
                  ),
                  backgroundColor: const Color(0xFF15803D),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFF15803D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Hubungi Kurator via WhatsApp',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
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

  Widget _buildFaqSection(BuildContext context) {
    final faqs = [
      {
        'q': 'Bagaimana cara meminjam buku fisik di Salon Pustaka?',
        'a': 'Tunjukkan kartu anggota pustaka digital di tab Profil kepada pustakawan di Meja Sirkulasi Lt. 1. Anggota terdaftar dapat meminjam hingga 2 buku fisik sekaligus dengan masa pinjam 14 hari kalender.',
      },
      {
        'q': 'Apakah naskah kuno & e-faksimili langka dapat dibawa pulang?',
        'a': 'Naskah kuno berstatus cagar budaya dan e-faksimili langka hanya dapat diteliti di Ruang Preservasi Lt. 2 Rumah Budaya Ratna dengan perlengkapan sarung tangan yang disediakan pengelola.',
      },
      {
        'q': 'Bagaimana cara mendaftar agenda lokakarya budaya?',
        'a': 'Buka tab "Agenda", pilih lokakarya yang diinginkan, pilih jenis tiket (Presale/Reguler), dan selesaikan transaksi melalui instruksi QRIS Nasional atau Virtual Account.',
      },
      {
        'q': 'Berapa jam operasional Pustaka & Kedai Kopi Ratna?',
        'a': 'Selasa s/d Minggu beroperasi pukul 09.00 - 21.00 WIB. Hari Senin tutup berkala untuk konservasi, restorasi buku kuno, dan pemeliharaan fasilitas salon.',
      },
      {
        'q': 'Bagaimana mekanisme donasi buku atau manuskrip keluarga?',
        'a': 'Kami menyambut kurasi naskah budaya dan buku sejarah lokal. Silakan kirimkan foto naskah beserta deskripsi singkat melalui WhatsApp kurator untuk jadwal temu telaah kuratorial.',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Column(
          children: faqs.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == faqs.length - 1;

            return Column(
              children: [
                ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
                  title: Text(
                    item['q']!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  iconColor: AppColors.maroon,
                  collapsedIconColor: AppColors.greyText,
                  children: [
                    Text(
                      item['a']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AppColors.darkText.withValues(alpha: 0.8),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
                if (!isLast) const Divider(height: 1, color: AppColors.lightBorder),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildVenueGuideCard() {
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
              const Icon(Icons.location_on_outlined, color: AppColors.maroon, size: 18),
              const SizedBox(width: 8),
              Text(
                'Alamat & Kontak Venue',
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
            'Rumah Budaya Ratna\n'
            'Jl. Simpang Wilis No. 12, Klojen, Kota Malang, Jawa Timur\n'
            'WhatsApp: +62 812-3456-7890 • Surel: halo@rumahbudayaratna.id',
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
