import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/mobile_frame.dart';
import 'struk_pembayaran_view.dart';

class QrisPaymentView extends StatelessWidget {
  final String title;
  final String orderNumber;
  final String badgeText;
  final String totalAmount;
  final String buttonLabel;
  final Widget? nextScreen;

  const QrisPaymentView({
    super.key,
    this.title = 'Pesanan Meja',
    this.orderNumber = '#ORD-9042',
    this.badgeText = 'Meja 04 • Dine-in',
    this.totalAmount = 'Rp 35.000',
    this.buttonLabel = 'CEK STATUS PEMBAYARAN',
    this.nextScreen,
  });

  @override
  Widget build(BuildContext context) {
    return MobileFrame(
      child: Scaffold(
        backgroundColor: AppColors.bgCanvas,
        appBar: AppBar(
          backgroundColor: AppColors.bgCanvas,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            title,
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined, color: AppColors.darkText, size: 20),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.person_outline_rounded, color: AppColors.darkText, size: 20),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Timer Card
              _buildTimerCard(),
              const SizedBox(height: 14),

              // 2. Merchant Info Card
              _buildMerchantInfoCard(),
              const SizedBox(height: 14),

              // 3. QRIS Card
              _buildQrisCard(context),
              const SizedBox(height: 20),

              // 4. Action Buttons
              _buildActionButtons(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget: Timer Card ---
  Widget _buildTimerCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7), // Warm amber tint
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_outlined, color: Color(0xFFB45309), size: 18),
          const SizedBox(width: 8),
          Text(
            'Berlaku hingga ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF92400E),
            ),
          ),
          Text(
            '14:59',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFB45309),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget: Merchant Info Card ---
  Widget _buildMerchantInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rumah Budaya Ratna',
                      style: GoogleFonts.lora(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Nomor Pesanan: $orderNumber',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.maroon.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.maroon.withValues(alpha: 0.2)),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.maroon,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.lightBorder, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Tagihan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.greyText,
                ),
              ),
              Text(
                totalAmount,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.maroon,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Widget: QRIS Card ---
  Widget _buildQrisCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header QRIS & GPN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge QRIS
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'QRIS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Text(
                'PEMBAYARAN DIGITAL',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: AppColors.greyText,
                ),
              ),
              // Badge GPN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'GPN',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // QR Code Graphic Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SizedBox(
              width: 210,
              height: 210,
              child: CustomPaint(
                painter: _QrisPainter(),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // NMID
          Text(
            'NMID : ID10200392019',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pindai QR ini melalui aplikasi m-Banking atau E-Wallet',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.greyText,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.lightBorder, height: 1),
          const SizedBox(height: 14),

          // Daftar E-Wallet & Bank yang didukung
          Text(
            'DAPAT DIBAYAR DENGAN',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: AppColors.greyText,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildWalletBadge('BCA Mobile', const Color(0xFF00388A)),
              _buildWalletBadge('GoPay', const Color(0xFF00AED6)),
              _buildWalletBadge('OVO', const Color(0xFF4C2A86)),
              _buildWalletBadge('ShopeePay', const Color(0xFFEE4D2D)),
              _buildWalletBadge('DANA', const Color(0xFF118EEA)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletBadge(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        name,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // --- Widget: Action Buttons ---
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tombol Utama "CEK STATUS PEMBAYARAN"
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => nextScreen ?? const StrukPembayaranView(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B1D2F), // Merah Marun
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  buttonLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Tombol "Unduh Kode QR"
        SizedBox(
          height: 46,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kode QR QRIS berhasil disimpan ke galeri!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.download_rounded, color: AppColors.maroon, size: 18),
            label: Text(
              'Unduh Kode QR',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.maroon,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.maroon, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Tombol "Ubah Metode Pembayaran"
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(
            'Ubah Metode Pembayaran',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.greyText,
            ),
          ),
        ),
      ],
    );
  }
}

/// CustomPainter untuk menggambar ilustrasi QR code yang rapi dan presisi
class _QrisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()..color = const Color(0xFF1E1C1A);
    final paintLight = Paint()..color = Colors.white;

    final cell = size.width / 25;

    // Fungsi helper untuk menggambar modul titik QR
    void drawDot(int col, int row) {
      canvas.drawRect(
        Rect.fromLTWH(col * cell, row * cell, cell - 0.5, cell - 0.5),
        paintDark,
      );
    }

    // Fungsi helper untuk menggambar Finder Pattern (sudut 7x7)
    void drawFinderPattern(double startX, double startY) {
      // Kotak luar 7x7
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX, startY, cell * 7, cell * 7),
          const Radius.circular(4),
        ),
        paintDark,
      );
      // Kotak putih 5x5
      canvas.drawRect(
        Rect.fromLTWH(startX + cell, startY + cell, cell * 5, cell * 5),
        paintLight,
      );
      // Kotak dalam 3x3
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX + cell * 2, startY + cell * 2, cell * 3, cell * 3),
          const Radius.circular(2),
        ),
        paintDark,
      );
    }

    // Gambar 3 Finder Pattern
    drawFinderPattern(0, 0); // Kiri Atas
    drawFinderPattern(size.width - cell * 7, 0); // Kanan Atas
    drawFinderPattern(0, size.height - cell * 7); // Kiri Bawah

    // Alignment pattern (Kanan Bawah)
    final alignX = size.width - cell * 8;
    final alignY = size.height - cell * 8;
    canvas.drawRect(Rect.fromLTWH(alignX, alignY, cell * 5, cell * 5), paintDark);
    canvas.drawRect(Rect.fromLTWH(alignX + cell, alignY + cell, cell * 3, cell * 3), paintLight);
    canvas.drawRect(Rect.fromLTWH(alignX + cell * 2, alignY + cell * 2, cell, cell), paintDark);

    // Data modul pola realistis
    const matrix = [
      "0000000010101010000000000",
      "0000000011010101000000000",
      "0000000001100110000000000",
      "0000000010111001000000000",
      "0000000001001101000000000",
      "0000000011100010000000000",
      "0000000000110111000000000",
      "0000000010001001000000000",
      "1011010111010101101101011",
      "0100101000101100010010100",
      "1110110111010010111011011",
      "0011001000111001001100100",
      "1001101101000110100110110",
      "0110010011101001011001001",
      "1101011000010110110101100",
      "0010100111101001001010011",
      "1011010100011110101101010",
      "0000000011000101000000000",
      "0000000000111010000000000",
      "0000000010100101000000000",
      "0000000001011010000000000",
      "0000000011100111000000000",
      "0000000000011000000000000",
      "0000000010101011000000000",
      "0000000001010100000000000",
    ];

    for (int r = 0; r < matrix.length; r++) {
      final line = matrix[r];
      for (int c = 0; c < line.length; c++) {
        // Lewati area finder pattern agar tidak tertimpa
        if ((r < 8 && c < 8) || (r < 8 && c >= 17) || (r >= 17 && c < 8)) {
          continue;
        }
        // Lewati area tengah untuk logo
        if (r >= 10 && r <= 14 && c >= 10 && c <= 14) {
          continue;
        }
        if (line[c] == '1') {
          drawDot(c, r);
        }
      }
    }

    // Logo Center Badge RBR
    final centerRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cell * 5.5,
      height: cell * 5.5,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerRect, const Radius.circular(6)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: cell * 4.5,
          height: cell * 4.5,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF6B1D2F),
    );

    // Teks RBR di logo tengah
    final textSpan = TextSpan(
      text: 'RBR',
      style: GoogleFonts.plusJakartaSans(
        color: const Color(0xFFC59B27),
        fontSize: cell * 1.7,
        fontWeight: FontWeight.w900,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
