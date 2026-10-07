import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import 'main_screen.dart';

class StrukPembayaranView extends StatelessWidget {
  const StrukPembayaranView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1A),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
          decoration: BoxDecoration(
            color: AppColors.cream,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 25,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Scaffold(
            backgroundColor: AppColors.cream,
            appBar: AppBar(
              backgroundColor: AppColors.cream,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false,
                  );
                },
              ),
              title: Text(
                'Detail Lokakarya / Resi',
                style: GoogleFonts.lora(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 20, color: AppColors.textMain),
                  onPressed: () {},
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.maroon,
                    child: Text('RA', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Check Icon Circle
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppColors.maroon,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'TRANSAKSI TERVERIFIKASI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pembayaran Berhasil',
                      style: GoogleFonts.lora(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'E-tiket / resi telah terbit dan dikirimkan secara otomatis ke email Anda.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 20),

                    // Struk Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'KEDAI & GALERI RATNA',
                                style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                              ),
                              Text(
                                '#ORD-9042',
                                style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.maroon),
                              ),
                            ],
                          ),
                          const Divider(color: AppColors.border, height: 20),
                          _buildDetailRow('Waktu Transaksi', '28 SEP 2026 • 18:30 WIB'),
                          _buildDetailRow('Metode Pembayaran', 'QRIS (INSTAN)'),
                          _buildDetailRow('Nomor Meja', 'Meja No. 04 (Dine-In)'),
                          const Divider(color: AppColors.border, height: 20),

                          Text('Rincian Pesanan', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                          const SizedBox(height: 8),
                          _buildItemRow('1x Kopi Susu Creamy', 'Rp 18.000'),
                          _buildItemRow('1x Americano Signature', 'Rp 17.000'),
                          const Divider(color: AppColors.border, height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Pembayaran', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                              Text('Rp 35.000', style: GoogleFonts.lora(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.maroon)),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // QR Code Resi
                          Center(
                            child: Column(
                              children: [
                                const Icon(Icons.qr_code_2, size: 70, color: AppColors.textMain),
                                Text(
                                  'Tunjukkan QR ini ke kasir jika diperlukan',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 8, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Kembali
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const MainScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.maroon,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                        ),
                        child: Text(
                          'KEMBALI KE BERANDA',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textMuted)),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMain)),
        ],
      ),
    );
  }

  Widget _buildItemRow(String name, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textMain)),
          Text(price, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMain)),
        ],
      ),
    );
  }
}