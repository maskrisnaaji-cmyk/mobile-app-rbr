import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/mobile_frame.dart';

class PengaturanAkunScreen extends StatefulWidget {
  const PengaturanAkunScreen({super.key});

  @override
  State<PengaturanAkunScreen> createState() => _PengaturanAkunScreenState();
}

class _PengaturanAkunScreenState extends State<PengaturanAkunScreen> {
  final _passwordFormKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Preferences toggles
  bool _notifLoanDue = true;
  bool _notifWorkshopAgenda = true;
  bool _notifCuratorArticles = true;
  bool _notifWhatsapp = true;
  bool _publicReviewProfile = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitChangePassword() {
    if (_passwordFormKey.currentState?.validate() ?? false) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kata sandi akun Anda berhasil diperbarui!',
            style: GoogleFonts.plusJakartaSans(fontSize: 12),
          ),
          backgroundColor: AppColors.maroon,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

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
            'Pengaturan Akun',
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
              // Identitas Akun Singkat
              _buildAccountBadgeCard(),
              const SizedBox(height: 20),

              // Bagian 1: Keamanan & Ganti Password
              Text(
                'KEAMANAN KATA SANDI',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: AppColors.greyText,
                ),
              ),
              const SizedBox(height: 10),
              _buildChangePasswordCard(),
              const SizedBox(height: 22),

              // Bagian 2: Preferensi Notifikasi
              Text(
                'PREFERENSI NOTIFIKASI',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: AppColors.greyText,
                ),
              ),
              const SizedBox(height: 10),
              _buildNotificationPreferencesCard(),
              const SizedBox(height: 22),

              // Bagian 3: Privasi
              Text(
                'PRIVASI & FORUM BUDAYA',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: AppColors.greyText,
                ),
              ),
              const SizedBox(height: 10),
              _buildPrivacyCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountBadgeCard() {
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.maroon.withValues(alpha: 0.12),
            child: Text(
              'AW',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.maroon,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aris Widiatmoko',
                  style: GoogleFonts.lora(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'aris.widiatmoko@budaya.id • Anggota Terverifikasi',
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

  Widget _buildChangePasswordCard() {
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
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPasswordField(
              controller: _currentPasswordController,
              label: 'Kata Sandi Saat Ini',
              hint: 'Masukkan kata sandi lama',
              obscure: _obscureCurrent,
              onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Kata sandi saat ini wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'Kata Sandi Baru',
              hint: 'Minimal 8 karakter kombinasi',
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Kata sandi baru wajib diisi';
                if (val.length < 6) return 'Kata sandi minimal 6 karakter';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Konfirmasi Kata Sandi Baru',
              hint: 'Ulangi kata sandi baru',
              obscure: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Konfirmasi kata sandi wajib diisi';
                if (val != _newPasswordController.text) {
                  return 'Konfirmasi kata sandi tidak cocok';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _submitChangePassword,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: Text(
                  'Perbarui Kata Sandi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.maroon,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: GoogleFonts.plusJakartaSans(fontSize: 12),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.greyText.withValues(alpha: 0.6)),
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.maroon),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18,
                color: AppColors.greyText,
              ),
              onPressed: onToggle,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: AppColors.bgCanvas,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.lightBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.lightBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.maroon, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationPreferencesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              'Pengingat Jatuh Tempo Buku',
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Pemberitahuan H-3 dan H-1 batas pengembalian koleksi',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.greyText),
            ),
            activeThumbColor: AppColors.maroon,
            value: _notifLoanDue,
            onChanged: (val) => setState(() => _notifLoanDue = val),
          ),
          const Divider(height: 1, color: AppColors.lightBorder),
          SwitchListTile(
            title: Text(
              'Notifikasi Agenda & Lokakarya',
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Jadwal lokakarya, pementasan drama, & bedah buku baru',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.greyText),
            ),
            activeThumbColor: AppColors.maroon,
            value: _notifWorkshopAgenda,
            onChanged: (val) => setState(() => _notifWorkshopAgenda = val),
          ),
          const Divider(height: 1, color: AppColors.lightBorder),
          SwitchListTile(
            title: Text(
              'Kabar Kuratorial & Terbitan Pustaka',
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Artikel telaah bulanan & naskah arsip yang baru didigitasi',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.greyText),
            ),
            activeThumbColor: AppColors.maroon,
            value: _notifCuratorArticles,
            onChanged: (val) => setState(() => _notifCuratorArticles = val),
          ),
          const Divider(height: 1, color: AppColors.lightBorder),
          SwitchListTile(
            title: Text(
              'Pemberitahuan via WhatsApp',
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Terima tiket E-Tiket & bukti peminjaman langsung ke WA',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.greyText),
            ),
            activeThumbColor: AppColors.maroon,
            value: _notifWhatsapp,
            onChanged: (val) => setState(() => _notifWhatsapp = val),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: SwitchListTile(
        title: Text(
          'Tampilkan Nama di Forum Ulasan Publik',
          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Bila dinonaktifkan, ulasan Anda akan bertuliskan "Pembaca Ratna"',
          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.greyText),
        ),
        activeThumbColor: AppColors.maroon,
        value: _publicReviewProfile,
        onChanged: (val) => setState(() => _publicReviewProfile = val),
      ),
    );
  }
}
