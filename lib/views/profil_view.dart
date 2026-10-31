import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import 'login_view.dart';
import 'main_screen.dart';
import 'peminjaman_buku_screen.dart';
import 'koleksi_favorit_screen.dart';
import 'ulasan_diskusi_screen.dart';
import 'pengaturan_akun_screen.dart';
import 'pusat_bantuan_screen.dart';
import 'riwayat_pesanan_screen.dart';
import 'chatbot_view.dart';

class ProfilView extends StatefulWidget {
  final bool showBottomNav;

  const ProfilView({super.key, this.showBottomNav = false});

  @override
  State<ProfilView> createState() => _ProfilViewState();
}

class _ProfilViewState extends State<ProfilView> {
  String _userName = 'Aris Widiatmoko';
  String _userEmail = 'aris.widiatmoko@budaya.id';
  String _userInitials = 'AW';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('userName');
      final email = prefs.getString('userEmail');
      final userStr = prefs.getString('user');

      String? foundName = name;
      String? foundEmail = email;

      if (userStr != null) {
        try {
          final userMap = jsonDecode(userStr);
          if (userMap is Map) {
            if ((foundName == null || foundName.isEmpty) && userMap['name'] != null) {
              foundName = userMap['name'].toString();
            }
            if ((foundEmail == null || foundEmail.isEmpty) && userMap['email'] != null) {
              foundEmail = userMap['email'].toString();
            }
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          if (foundName != null && foundName.trim().isNotEmpty) {
            _userName = foundName.trim();
            _userInitials = _getInitials(_userName);
          }
          if (foundEmail != null && foundEmail.trim().isNotEmpty) {
            _userEmail = foundEmail.trim();
          }
        });
      }
    } catch (_) {}
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'AW';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _userName);
    final emailCtrl = TextEditingController(text: _userEmail);

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
                  child: const Icon(Icons.edit_note, color: AppColors.maroon, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Profil & Preferensi',
                        style: GoogleFonts.lora(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        'Perbarui data identitas kartu pustaka Anda',
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
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: 'Alamat Email',
                labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                prefixIcon: const Icon(Icons.mail_outline, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final newName = nameCtrl.text.trim();
                  final newEmail = emailCtrl.text.trim();
                  if (newName.isNotEmpty) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('userName', newName);
                    if (newEmail.isNotEmpty) {
                      await prefs.setString('userEmail', newEmail);
                    }
                    if (mounted) {
                      setState(() {
                        _userName = newName;
                        if (newEmail.isNotEmpty) _userEmail = newEmail;
                        _userInitials = _getInitials(newName);
                      });
                    }
                  }
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Profil berhasil diperbarui!',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'Simpan Perubahan',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.maroon),
            const SizedBox(width: 8),
            Text(
              'Keluar dari Akun?',
              style: GoogleFonts.lora(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        content: Text(
          'Anda harus masuk kembali untuk mengakses kartu pustaka digital dan reservasi agenda.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            height: 1.5,
            color: AppColors.greyText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppColors.greyText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Ya, Keluar',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Atas: Judul "Profil Saya" di kiri, Settings & Avatar di kanan
          _buildTopHeader(),
          const SizedBox(height: 14),

          // 2. Kartu Profil Utama (Background Putih / Krem Lembut)
          _buildMainProfileCard(),
          const SizedBox(height: 22),

          // 3. Section "AKTIVITAS & KURASI"
          _buildActivitySection(),
          const SizedBox(height: 22),

          // 4. Section "PREFERENSI & BANTUAN"
          _buildPreferenceSection(),
          const SizedBox(height: 28),

          // 5. Footer Teks Kutipan & Versi
          _buildFooterText(),
          const SizedBox(height: 32),
        ],
      ),
    );

    // Jika dipanggil mandiri (showBottomNav = true), bungkus dengan Scaffold dan Bottom Navigation
    if (widget.showBottomNav) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F6F0),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: const Color(0xFFFAF7F2),
            child: SafeArea(child: content),
          ),
        ),
        bottomNavigationBar: _buildStandaloneBottomBar(),
      );
    }

    // Default untuk dirender di dalam MainScreen
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        child: content,
      ),
    );
  }

  // --- 1. Header Atas ---
  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Judul: "Profil Saya"
        Text(
          'Profil Saya',
          style: GoogleFonts.lora(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.maroonDark,
          ),
        ),

        // Action Icons: Settings & Avatar Kecil
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.textMain,
                size: 22,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PengaturanAkunScreen()),
                );
              },
              tooltip: 'Pengaturan',
            ),
            const SizedBox(width: 2),
            GestureDetector(
              onTap: _showEditProfileDialog,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.maroon, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.maroon.withValues(alpha: 0.12),
                  child: Text(
                    'AW',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.maroon,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 2. Kartu Profil Utama ---
  Widget _buildMainProfileCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background aksen ornamen kartu pustaka di sudut kanan atas
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.maroon.withValues(alpha: 0.03),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // Baris Atas: Badge "KARTU PUSTAKA DIGITAL"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7), // Gold/Kuning pastel
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.badge_outlined, size: 12, color: Color(0xFF92400E)),
                          const SizedBox(width: 5),
                          Text(
                            'KARTU PUSTAKA DIGITAL',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.qr_code_2_rounded,
                      color: AppColors.maroon,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Foto Profil Bulat dengan Border Marun & Badge "AKTIF"
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.maroon, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.maroon.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 38,
                        backgroundColor: const Color(0xFFFAF7F2),
                        child: Text(
                          _userInitials,
                          style: GoogleFonts.lora(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.maroon,
                          ),
                        ),
                      ),
                    ),

                    // Badge Status Kecil "AKTIF"
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7), // Hijau pastel
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF16A34A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'AKTIF',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Nama Pengguna Dinamis
                Text(
                  _userName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lora(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.maroonDark,
                  ),
                ),
                const SizedBox(height: 4),

                // Email Dinamis & ID Anggota
                Text(
                  _userEmail,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.greyText,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EBE6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEAD8D0)),
                  ),
                  child: Text(
                    'ID ANGGOTA: RBR-2024-8842',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppColors.maroon,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFEFEAE2)),
                const SizedBox(height: 14),

                // Statistik Ringkas (Grid 3 Kolom)
                Row(
                  children: [
                    _buildStatItem('12', 'Buku Pinjam'),
                    _buildVerticalDivider(),
                    _buildStatItem('8', 'Agenda Budaya'),
                    _buildVerticalDivider(),
                    _buildStatItem('14', 'Koleksi Suka'),
                  ],
                ),
                const SizedBox(height: 16),

                // Tombol Aksi Utama: "Edit Profil & Preferensi"
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _showEditProfileDialog,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(
                      'Edit Profil & Preferensi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.maroon, // #6B1D2F solid
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count,
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.greyText,
              fontWeight: FontWeight.w500,
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
      color: const Color(0xFFE5DFD5),
    );
  }

  // --- 3. Section "AKTIVITAS & KURASI" ---
  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'AKTIVITAS & KURASI',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppColors.greyText,
            ),
          ),
        ),

        // Kartu menu 1: "Peminjaman Buku"
        _buildMenuCard(
          icon: Icons.menu_book_rounded,
          title: 'Peminjaman Buku',
          subtitle: 'Daftar buku fisik & e-faksimili dalam masa pinjam',
          badgeText: '2 Aktif',
          badgeBg: const Color(0xFFDCFCE7),
          badgeColor: const Color(0xFF15803D),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PeminjamanBukuScreen()),
            );
          },
        ),
        const SizedBox(height: 10),

        // Kartu menu 2: "Koleksi Favorit"
        _buildMenuCard(
          icon: Icons.bookmark_outline_rounded,
          title: 'Koleksi Favorit',
          subtitle: '14 karya sastra, manuskrip, & arsip tersimpan',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KoleksiFavoritScreen()),
            );
          },
        ),
        const SizedBox(height: 10),

        // Kartu menu 3: "Ulasan & Diskusi Saya"
        _buildMenuCard(
          icon: Icons.rate_review_outlined,
          title: 'Ulasan & Diskusi Saya',
          subtitle: '8 telaah budaya & tanggapan kuratorial naskah',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UlasanDiskusiScreen()),
            );
          },
        ),
        const SizedBox(height: 10),

        // Kartu menu 4: "Riwayat Pesanan & Tiket"
        _buildMenuCard(
          icon: Icons.receipt_long_rounded,
          title: 'Riwayat Pesanan & Tiket',
          subtitle: 'Transaksi kedai kopi & tiket agenda budaya',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RiwayatPesananScreen()),
            );
          },
        ),
        const SizedBox(height: 10),

        // Kartu menu 5: "Tanya Kurator AI"
        _buildMenuCardHighlighted(
          icon: Icons.auto_awesome_rounded,
          title: 'Tanya Kurator AI',
          subtitle: 'Obrolan budaya dengan Ratna AI — kurator digital RBR',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatbotView()),
            );
          },
        ),
      ],
    );
  }

  // --- 4. Section "PREFERENSI & BANTUAN" ---
  Widget _buildPreferenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'PREFERENSI & BANTUAN',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppColors.greyText,
            ),
          ),
        ),

        // Kartu menu 4: "Pengaturan Akun"
        _buildMenuCard(
          icon: Icons.lock_outline_rounded,
          title: 'Pengaturan Akun',
          subtitle: 'Keamanan kata sandi, privasi, & notifikasi',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PengaturanAkunScreen()),
            );
          },
        ),
        const SizedBox(height: 10),

        // Kartu menu 5: "Pusat Bantuan & Panduan"
        _buildMenuCard(
          icon: Icons.help_outline_rounded,
          title: 'Pusat Bantuan & Panduan',
          subtitle: 'Tata tertib salon pustaka, preservasi & kontak kurator',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PusatBantuanScreen()),
            );
          },
        ),
        const SizedBox(height: 10),

        // Kartu menu 6: "Keluar dari Akun" (Latar merah muda lembut, teks marun)
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2), // Merah muda lembut
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.maroon.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.maroon,
                  size: 20,
                ),
              ),
              title: Text(
                'Keluar dari Akun',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.maroon,
                ),
              ),
              subtitle: Text(
                'Hapus sesi aktif dari perangkat ini',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF991B1B),
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.maroon,
              ),
              onTap: _showLogoutDialog,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  /// Varian menu card dengan aksen gradien AI (untuk "Tanya Kurator AI")
  Widget _buildMenuCardHighlighted({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B1D2F), Color(0xFF8B2543)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B1D2F).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          splashColor: Colors.white.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'AI',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 20, color: Colors.white54),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badgeText,
    Color? badgeBg,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEBE6DC)),
            ),
            child: Icon(
              icon,
              color: AppColors.maroon,
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              if (badgeText != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: badgeBg ?? const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: badgeColor ?? const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.greyText,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            size: 20,
            color: Color(0xFFA8A29E),
          ),
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // --- 5. Footer Teks Kutipan & Versi ---
  Widget _buildFooterText() {
    return Column(
      children: [
        Center(
          child: Text(
            '“Memuliakan Tradisi, Merawat Akal Budi.”',
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(
              fontSize: 12.5,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF8C6B38),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Rumah Budaya Ratna • Versi 2.4.1 (Arsip Kartika)',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: const Color(0xFFA8A29E),
            ),
          ),
        ),
      ],
    );
  }

  // Bottom bar mandiri (jika view dipanggil via pushReplacement secara langsung)
  Widget _buildStandaloneBottomBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(Icons.home_outlined, 'Beranda', 0),
          _buildBottomNavItem(Icons.local_cafe_outlined, 'Kedai Kopi', 1),
          _buildBottomNavItem(Icons.menu_book_outlined, 'Pustaka', 2),
          _buildBottomNavItem(Icons.calendar_today_outlined, 'Agenda', 3),
          _buildBottomNavItem(Icons.person, 'Profil', 4, isSelected: true),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int targetIndex, {bool isSelected = false}) {
    return InkWell(
      onTap: () {
        if (!isSelected) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(initialIndex: targetIndex),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
            color: isSelected ? AppColors.maroon : AppColors.greyText,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.maroon : AppColors.greyText,
            ),
          ),
          const SizedBox(height: 3),
          if (isSelected)
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.maroon,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(height: 4),
        ],
      ),
    );
  }
}
