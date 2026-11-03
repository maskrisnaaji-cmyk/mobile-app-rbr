import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/mobile_frame.dart';
import '../services/payment_service.dart';
import 'struk_pembayaran_view.dart';

class QrisPaymentView extends StatefulWidget {
  final String title;
  final String orderNumber;
  final String badgeText;
  final String totalAmount;
  final int? rawAmount;
  final String? qrUrl;
  final String? qrString;
  final String buttonLabel;
  final Widget? nextScreen;

  const QrisPaymentView({
    super.key,
    this.title = 'Pesanan Meja',
    this.orderNumber = '#ORD-9042',
    this.badgeText = 'Meja 04 • Dine-in',
    this.totalAmount = 'Rp 35.000',
    this.rawAmount,
    this.qrUrl,
    this.qrString,
    this.buttonLabel = 'CEK STATUS PEMBAYARAN',
    this.nextScreen,
  });

  @override
  State<QrisPaymentView> createState() => _QrisPaymentViewState();
}

class _QrisPaymentViewState extends State<QrisPaymentView> {
  bool _isChecking = false;

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);
    final statusData = await PaymentService.checkPaymentStatus(widget.orderNumber);
    if (!mounted) return;
    setState(() => _isChecking = false);

    final txStatus = (statusData?['transaction_status'] ?? '').toString().toLowerCase();
    final isPaid = statusData?['is_paid'] == true || txStatus == 'settlement' || txStatus == 'paid';

    if (isPaid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF2E7D32),
          content: Text('🎉 Pembayaran QRIS Berhasil Terverifikasi!'),
          duration: Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => widget.nextScreen ?? const StrukPembayaranView(),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status: ${txStatus.isEmpty ? "Menunggu Pembayaran" : txStatus}. Silakan scan kode QR di atas.'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _simulateSettlement() async {
    setState(() => _isChecking = true);
    final success = await PaymentService.simulateSettlement(
      orderId: widget.orderNumber,
      grossAmount: widget.rawAmount ?? 35000,
      paymentType: 'qris',
    );
    if (!mounted) return;
    setState(() => _isChecking = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF2E7D32),
          content: Text('✅ Simulasi Berhasil: Pembayaran QRIS LUNAS!'),
          duration: Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => widget.nextScreen ?? const StrukPembayaranView(),
          ),
        );
      });
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
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.title,
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
        color: const Color(0xFFFEF3C7),
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
                      'Nomor Pesanan: ${widget.orderNumber}',
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
                  widget.badgeText,
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
                widget.totalAmount,
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

          // QR Code Container
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
              child: (widget.qrUrl != null && widget.qrUrl!.isNotEmpty)
                  ? Image.network(
                      widget.qrUrl!,
                      width: 210,
                      height: 210,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => CustomPaint(
                        painter: _QrisPainter(),
                      ),
                    )
                  : CustomPaint(
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            onPressed: _isChecking ? null : _checkStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B1D2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
            child: _isChecking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        widget.buttonLabel,
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
            padding: const EdgeInsets.symmetric(vertical: 8),
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

        // Quick simulation helper for local sandbox test
        Center(
          child: TextButton(
            onPressed: _isChecking ? null : _simulateSettlement,
            child: Text(
              '⚡ Simulasi Lunas (Demo Sandbox)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText.withValues(alpha: 0.8),
                decoration: TextDecoration.underline,
              ),
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

    void drawDot(int col, int row) {
      canvas.drawRect(
        Rect.fromLTWH(col * cell, row * cell, cell - 0.5, cell - 0.5),
        paintDark,
      );
    }

    void drawFinderPattern(double startX, double startY) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX, startY, cell * 7, cell * 7),
          const Radius.circular(4),
        ),
        paintDark,
      );
      canvas.drawRect(
        Rect.fromLTWH(startX + cell, startY + cell, cell * 5, cell * 5),
        paintLight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX + cell * 2, startY + cell * 2, cell * 3, cell * 3),
          const Radius.circular(2),
        ),
        paintDark,
      );
    }

    drawFinderPattern(0, 0);
    drawFinderPattern(size.width - cell * 7, 0);
    drawFinderPattern(0, size.height - cell * 7);

    final alignX = size.width - cell * 8;
    final alignY = size.height - cell * 8;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(alignX, alignY, cell * 5, cell * 5),
        const Radius.circular(3),
      ),
      paintDark,
    );
    canvas.drawRect(
      Rect.fromLTWH(alignX + cell, alignY + cell, cell * 3, cell * 3),
      paintLight,
    );
    drawDot((alignX / cell + 2).round(), (alignY / cell + 2).round());

    for (int col = 8; col <= 16; col++) {
      if (col % 2 == 0) drawDot(col, 6);
    }
    for (int row = 8; row <= 16; row++) {
      if (row % 2 == 0) drawDot(6, row);
    }

    final dummyDots = [
      [8, 1], [10, 2], [12, 1], [14, 3], [16, 2],
      [1, 8], [3, 10], [2, 13], [4, 15], [0, 16],
      [8, 8], [9, 10], [11, 8], [13, 9], [15, 11],
      [8, 13], [10, 14], [12, 16], [14, 13], [16, 15],
      [18, 8], [20, 9], [22, 8], [24, 11],
      [18, 14], [20, 15], [22, 13], [24, 16],
      [8, 18], [9, 20], [11, 22], [13, 24],
      [14, 18], [15, 21], [16, 23],
      [18, 18], [20, 20], [22, 22], [24, 24],
      [19, 21], [21, 23], [23, 19],
    ];

    for (final dot in dummyDots) {
      drawDot(dot[0], dot[1]);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
