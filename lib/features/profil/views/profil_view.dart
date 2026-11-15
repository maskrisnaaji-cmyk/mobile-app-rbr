import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/widgets/user_avatar_widget.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/features/auth/views/login_view.dart';
import 'package:mobile_app/features/home/views/main_screen.dart';
import 'package:mobile_app/features/pustaka/views/peminjaman_buku_screen.dart';
import 'package:mobile_app/features/pustaka/views/koleksi_favorit_screen.dart';
import 'package:mobile_app/features/pustaka/views/ulasan_diskusi_screen.dart';
import 'package:mobile_app/features/profil/views/pengaturan_akun_screen.dart';
import 'package:mobile_app/features/profil/views/pusat_bantuan_screen.dart';
import 'package:mobile_app/features/profil/viewmodels/profil_viewmodel.dart';
import 'package:mobile_app/features/profil/widgets/profil_menu_item.dart';
import 'package:mobile_app/features/booking_payment/views/riwayat_pesanan_screen.dart';
import 'package:mobile_app/features/chatbot/views/chatbot_view.dart';

class ProfilView extends StatefulWidget {
  final bool showBottomNav;
  final ProfilViewModel? viewModel;

  const ProfilView({
    super.key,
    this.showBottomNav = false,
    this.viewModel,
  });

  @override
  State<ProfilView> createState() => _ProfilViewState();
}

class _ProfilViewState extends State<ProfilView> {
  late final ProfilViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? ProfilViewModel();
  }

  Future<void> _pickProfilePhoto() async {
    final success = await _viewModel.pickProfilePhoto();
    if (!success && _viewModel.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _viewModel.userName);
    final emailCtrl = TextEditingController(text: _viewModel.userEmail);

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
                  child: const Icon(Icons.edit_note,
                      color: AppColors.maroon, size: 24),
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
            Center(
              child: Column(
                children: [
                  UserAvatarWidget(
                    radius: 38,
                    onTap: _pickProfilePhoto,
                    tooltip: 'Pilih foto profil',
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _pickProfilePhoto,
                    icon: const Icon(Icons.photo_camera_outlined, size: 17),
                    label: const Text('Ubah Foto Profil'),
                    style:
                        TextButton.styleFrom(foregroundColor: AppColors.maroon),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: 'Alamat Email',
                labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                prefixIcon: const Icon(Icons.mail_outline, size: 20),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                    await _viewModel.updateProfile(
                      name: newName,
                      email: newEmail.isNotEmpty ? newEmail : null,
                    );
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.maroon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'Simpan Perubahan',
                  style:
                      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      nameCtrl.dispose();
      emailCtrl.dispose();
    });
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
              await _viewModel.logout();
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
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
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final content = SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(),
              const SizedBox(height: 14),
              _buildMainProfileCard(),
              const SizedBox(height: 22),
              _buildActivitySection(),
              const SizedBox(height: 22),
              _buildPreferenceSection(),
              const SizedBox(height: 28),
              _buildFooterText(),
              const SizedBox(height: 32),
            ],
          ),
        );

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

        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: content,
          ),
        );
      },
    );
  }

  // --- 1. Header Atas ---
  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Profil Saya',
          style: GoogleFonts.lora(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.maroonDark,
          ),
        ),
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
                  MaterialPageRoute(
                    builder: (_) =>
                        PengaturanAkunScreen(viewModel: _viewModel),
                  ),
                );
              },
              tooltip: 'Pengaturan',
            ),
            const SizedBox(width: 4),
            UserAvatarWidget(
              radius: 14,
              onTap: _showEditProfileDialog,
            ),
          ],
        ),
      ],
    );
  }

  // --- 2. Kartu Profil Utama ---
  Widget _buildMainProfileCard() {
    final profile = _viewModel.profile;
    final borrowedCount = profile?.borrowedBooksCount.toString() ?? '12';
    final agendasCount = profile?.culturalAgendasCount.toString() ?? '8';
    final favoritesCount = profile?.favoriteCollectionsCount.toString() ?? '14';
    final memberId = profile?.memberId ?? 'RBR-2024-8842';

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.badge_outlined,
                              size: 12, color: Color(0xFF92400E)),
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
                      child: UserAvatarWidget(
                        radius: 38,
                        showBorder: false,
                        tooltip: 'Ubah foto profil',
                        onTap: _pickProfilePhoto,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
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
                Text(
                  _viewModel.userName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lora(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.maroonDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _viewModel.userEmail,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.greyText,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EBE6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEAD8D0)),
                  ),
                  child: Text(
                    'ID ANGGOTA: $memberId',
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
                Row(
                  children: [
                    ProfilStatItem(count: borrowedCount, label: 'Buku Pinjam'),
                    _buildVerticalDivider(),
                    ProfilStatItem(count: agendasCount, label: 'Agenda Budaya'),
                    _buildVerticalDivider(),
                    ProfilStatItem(
                        count: favoritesCount, label: 'Koleksi Suka'),
                  ],
                ),
                const SizedBox(height: 16),
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
                      backgroundColor: AppColors.maroon,
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
        ProfilMenuCard(
          icon: Icons.menu_book_rounded,
          title: 'Peminjaman Buku',
          subtitle: 'Status peminjaman, lokasi rak & request perpanjangan',
          badgeText: 'Lihat Status',
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
        ProfilMenuCard(
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
        ProfilMenuCard(
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
        ProfilMenuCard(
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
        ProfilMenuCardHighlighted(
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
        ProfilMenuCard(
          icon: Icons.lock_outline_rounded,
          title: 'Pengaturan Akun',
          subtitle: 'Keamanan kata sandi, privasi, & notifikasi',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PengaturanAkunScreen(viewModel: _viewModel),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        ProfilMenuCard(
          icon: Icons.help_outline_rounded,
          title: 'Pusat Bantuan & Panduan',
          subtitle: 'Tata tertib salon pustaka, preservasi & kontak kurator',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PusatBantuanScreen(viewModel: _viewModel),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
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

  Widget _buildBottomNavItem(IconData icon, String label, int targetIndex,
      {bool isSelected = false}) {
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
