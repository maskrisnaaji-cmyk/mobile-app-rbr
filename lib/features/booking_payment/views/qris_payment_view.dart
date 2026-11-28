import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/core/widgets/mobile_frame.dart';
import 'package:mobile_app/features/booking_payment/views/struk_pembayaran_view.dart';
import 'package:mobile_app/features/booking_payment/viewmodels/booking_payment_viewmodel.dart';

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
  final PaymentStatusViewModel? viewModel;
  final String? kedaiOrderCode;
  final int? eventId;
  final int? ticketQuantity;
  final String? customerName;
  final String? customerEmail;
  final DateTime? createdAt;
  final DateTime? expiredAt;

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
    this.viewModel,
    this.kedaiOrderCode,
    this.eventId,
    this.ticketQuantity,
    this.customerName,
    this.customerEmail,
    this.createdAt,
    this.expiredAt,
  });

  @override
  State<QrisPaymentView> createState() => _QrisPaymentViewState();
}

class _QrisPaymentViewState extends State<QrisPaymentView> {
  late final PaymentStatusViewModel _viewModel;
  Timer? _countdownTimer;
  late DateTime _effectiveExpiredAt;
  Duration _remainingDuration = const Duration(minutes: 30);
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? PaymentStatusViewModel();
    _initExpiryAndTimer();
  }

  void _initExpiryAndTimer() {
    if (widget.expiredAt != null) {
      _effectiveExpiredAt = widget.expiredAt!;
    } else if (widget.createdAt != null) {
      _effectiveExpiredAt =
          widget.createdAt!.add(const Duration(minutes: 30));
    } else {
      _effectiveExpiredAt =
          DateTime.now().add(const Duration(minutes: 30));
    }

    _updateRemainingTime();

    if (!_isExpired) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          _updateRemainingTime();
        });
      });
    }
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    if (now.isAfter(_effectiveExpiredAt)) {
      _remainingDuration = Duration.zero;
      _isExpired = true;
      _countdownTimer?.cancel();
    } else {
      _remainingDuration = _effectiveExpiredAt.difference(now);
      _isExpired = false;
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _confirmPaymentIfAny() async {
    final code = widget.kedaiOrderCode;
    if (code != null && code.isNotEmpty) {
      await _viewModel.confirmKedaiOrderPayment(code);
    }
    final evId = widget.eventId;
    if (evId != null) {
      await _viewModel.confirmEventBooking(
        eventId: evId,
        quantity: widget.ticketQuantity ?? 1,
        customerName: widget.customerName,
        customerEmail: widget.customerEmail,
        orderId: widget.orderNumber,
      );
    }
  }

  Future<void> _checkStatus() async {
    if (_isExpired || _viewModel.isExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFDC2626),
          content: Text('Waktu pembayaran sudah habis (Expired). Silakan buat pesanan baru.'),
        ),
      );
      return;
    }

    final isPaid = await _viewModel.checkStatus(widget.orderNumber);
    if (!mounted) return;

    if (isPaid) {
      await _confirmPaymentIfAny();
      if (!mounted) return;
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
    } else if (_viewModel.isExpired) {
      setState(() {
        _isExpired = true;
        _remainingDuration = Duration.zero;
        _countdownTimer?.cancel();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFDC2626),
          content: Text('Transaksi telah kedaluwarsa. Silakan lakukan pemesanan ulang.'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menunggu Pembayaran. Silakan scan kode QR di atas.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _simulateSettlement() async {
    if (_isExpired || _viewModel.isExpired) return;

    final success = await _viewModel.simulateSettlement(
      orderId: widget.orderNumber,
      grossAmount: widget.rawAmount ?? 35000,
      paymentType: 'qris',
    );
    if (!mounted) return;

    if (success) {
      await _confirmPaymentIfAny();
      if (!mounted) return;
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
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final bool isExpiredNow = _isExpired || _viewModel.isExpired;

        return MobileFrame(
          child: Scaffold(
            backgroundColor: AppColors.bgCanvas,
            appBar: AppBar(
              backgroundColor: AppColors.bgCanvas,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.darkText),
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
                  icon: const Icon(Icons.share_outlined,
                      color: AppColors.darkText, size: 20),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline_rounded,
                      color: AppColors.darkText, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTimerCard(isExpiredNow),
                  const SizedBox(height: 14),
                  _buildMerchantInfoCard(),
                  const SizedBox(height: 14),
                  _buildQrisCard(context, isExpiredNow),
                  const SizedBox(height: 20),
                  _buildActionButtons(context, isExpiredNow),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerCard(bool isExpiredNow) {
    if (isExpiredNow) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Color(0xFFDC2626), size: 18),
            const SizedBox(width: 8),
            Text(
              'WAKTU PEMBAYARAN KEDALUWARSA (00:00)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      );
    }

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(_remainingDuration.inMinutes.remainder(60));
    final seconds = twoDigits(_remainingDuration.inSeconds.remainder(60));
    final hours = _remainingDuration.inHours;
    final timeStr = hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';

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
          const Icon(Icons.timer_outlined,
              color: Color(0xFFB45309), size: 18),
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
            timeStr,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.maroon.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.maroon.withValues(alpha: 0.2)),
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

  Widget _buildQrisCard(BuildContext context, bool isExpiredNow) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isExpiredNow
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFFDC2626),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isExpiredNow
                      ? const Color(0xFF6B7280)
                      : const Color(0xFF1E3A8A),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isExpiredNow
                    ? const Color(0xFFFCA5A5)
                    : AppColors.lightBorder,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: isExpiredNow ? 0.2 : 1.0,
                    child: SizedBox(
                      width: 220,
                      height: 220,
                      child: _buildQrImage(),
                    ),
                  ),
                  if (isExpiredNow)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.block_rounded,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'KEDALUWARSA',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isExpiredNow
                ? 'Kode QR telah kedaluwarsa dan tidak dapat dipindai lagi.'
                : 'Pindai QR ini melalui aplikasi m-Banking atau E-Wallet',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: isExpiredNow
                  ? const Color(0xFFDC2626)
                  : AppColors.greyText,
              fontWeight:
                  isExpiredNow ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.lightBorder, height: 1),
          const SizedBox(height: 14),
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

  Widget _buildActionButtons(BuildContext context, bool isExpiredNow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: (isExpiredNow || _viewModel.isChecking) ? null : _checkStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: isExpiredNow
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFF6B1D2F),
              disabledBackgroundColor: const Color(0xFFE5E7EB),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: isExpiredNow ? 0 : 2,
            ),
            child: _viewModel.isChecking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isExpiredNow
                            ? Icons.cancel_outlined
                            : Icons.check_circle_outline,
                        color: isExpiredNow ? const Color(0xFF9CA3AF) : Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isExpiredNow
                            ? 'PEMBAYARAN KEDALUWARSA'
                            : widget.buttonLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isExpiredNow
                              ? const Color(0xFF9CA3AF)
                              : Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 46,
          child: OutlinedButton.icon(
            onPressed: isExpiredNow
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Kode QR QRIS berhasil disimpan ke galeri!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
            icon: Icon(
              Icons.download_rounded,
              color: isExpiredNow ? const Color(0xFF9CA3AF) : AppColors.maroon,
              size: 18,
            ),
            label: Text(
              'Unduh Kode QR',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isExpiredNow
                    ? const Color(0xFF9CA3AF)
                    : AppColors.maroon,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isExpiredNow
                    ? const Color(0xFFD1D5DB)
                    : AppColors.maroon,
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              backgroundColor: isExpiredNow ? const Color(0xFFF9FAFB) : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style:
              TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
          child: Text(
            isExpiredNow
                ? 'Kembali & Pesan Ulang'
                : 'Ubah Metode Pembayaran',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isExpiredNow ? AppColors.maroon : AppColors.greyText,
            ),
          ),
        ),
        if (!isExpiredNow)
          Center(
            child: TextButton(
              onPressed: _viewModel.isChecking ? null : _simulateSettlement,
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

  Widget _buildQrImage() {
    final qrStr = widget.qrString?.trim();
    final qrUrl = widget.qrUrl?.trim();

    // 1. Prioritas Utama: render qr_string secara lokal via qr_flutter (Bebas CORS di Web & Mobile)
    if (qrStr != null && qrStr.isNotEmpty) {
      return Center(
        child: QrImageView(
          data: qrStr,
          version: QrVersions.auto,
          size: 210,
          gapless: false,
          backgroundColor: Colors.white,
          errorCorrectionLevel: QrErrorCorrectLevel.M,
          errorStateBuilder: (cxt, err) {
            // Jika qr_string gagal diparse, fallback ke Image.network jika qrUrl ada
            if (qrUrl != null && qrUrl.isNotEmpty) {
              return _buildNetworkQr(qrUrl);
            }
            return _buildQrFallback(
              icon: Icons.qr_code_2_rounded,
              message: 'Gagal membuat kode QR lokal',
            );
          },
        ),
      );
    }

    // 2. Cadangan: gunakan Image.network jika qr_string kosong tapi qrUrl ada
    if (qrUrl != null && qrUrl.isNotEmpty) {
      return _buildNetworkQr(qrUrl);
    }

    // 3. Fallback jika kedua-duanya kosong
    return _buildQrFallback(
      icon: Icons.qr_code_2_rounded,
      message: 'Kode QR tidak tersedia',
    );
  }

  Widget _buildNetworkQr(String url) {
    return Image.network(
      url,
      width: 210,
      height: 210,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        final totalBytes = loadingProgress.expectedTotalBytes;
        final loadedBytes = loadingProgress.cumulativeBytesLoaded;
        final progress = (totalBytes != null && totalBytes > 0)
            ? loadedBytes / totalBytes
            : null;
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  value: progress,
                  color: AppColors.maroon,
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Memuat gambar QR...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildQrFallback(
          icon: Icons.broken_image_outlined,
          message: 'Gagal memuat gambar QR',
        );
      },
    );
  }

  Widget _buildQrFallback({required IconData icon, required String message}) {
    return Container(
      width: 220,
      height: 220,
      color: const Color(0xFFF9FAFB),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppColors.greyText),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Periksa koneksi internet Anda',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
