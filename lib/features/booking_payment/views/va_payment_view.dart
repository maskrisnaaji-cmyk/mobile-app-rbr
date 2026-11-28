import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/core/widgets/mobile_frame.dart';
import 'package:mobile_app/features/booking_payment/views/struk_pembayaran_view.dart';
import 'package:mobile_app/features/booking_payment/viewmodels/booking_payment_viewmodel.dart';

class VaPaymentView extends StatefulWidget {
  final String title;
  final String orderNumber;
  final String badgeText;
  final String totalAmount;
  final int? rawAmount;
  final String vaNumber;
  final String bankName;
  final String? billerCode;
  final String? billKey;
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

  const VaPaymentView({
    super.key,
    this.title = 'Pesanan Meja',
    this.orderNumber = '#ORD-9042',
    this.badgeText = 'Meja 04',
    this.totalAmount = 'Rp 35.000',
    this.rawAmount,
    this.vaNumber = '8830 9042 1817 000',
    this.bankName = 'BCA Virtual Account',
    this.billerCode,
    this.billKey,
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
  State<VaPaymentView> createState() => _VaPaymentViewState();
}

class _VaPaymentViewState extends State<VaPaymentView> {
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
          content: Text(
              'Waktu pembayaran sudah habis (Expired). Silakan buat pesanan baru.'),
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
          content:
              Text('🎉 Pembayaran Virtual Account Berhasil Terverifikasi!'),
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
          content: Text(
              'Transaksi telah kedaluwarsa. Silakan lakukan pemesanan ulang.'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Menunggu Pembayaran. Silakan transfer ke nomor VA di atas.'),
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
      paymentType: 'bank_transfer',
    );
    if (!mounted) return;

    if (success) {
      await _confirmPaymentIfAny();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF2E7D32),
          content: Text('✅ Simulasi Berhasil: Status pesanan kini LUNAS!'),
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
                  _buildVaDetailsCard(context, isExpiredNow),
                  const SizedBox(height: 16),
                  _buildInstructionsSection(context),
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
    final timeStr =
        hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.alarm_outlined,
              color: Color(0xFFDC2626), size: 18),
          const SizedBox(width: 8),
          Text(
            'BATAS PEMBAYARAN • ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: const Color(0xFF991B1B),
            ),
          ),
          Text(
            timeStr,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFDC2626),
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
              Column(
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
                'Total Pembayaran',
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

  Widget _buildVaDetailsCard(BuildContext context, bool isExpiredNow) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpiredNow
              ? const Color(0xFFFCA5A5)
              : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isExpiredNow
                      ? const Color(0xFF9CA3AF).withValues(alpha: 0.1)
                      : const Color(0xFF00388A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isExpiredNow
                        ? const Color(0xFF9CA3AF).withValues(alpha: 0.3)
                        : const Color(0xFF00388A).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_balance,
                        color: isExpiredNow
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF00388A),
                        size: 14),
                    const SizedBox(width: 6),
                    Text(
                      widget.bankName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isExpiredNow
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF00388A),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isExpiredNow
                      ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                      : const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isExpiredNow ? 'Kedaluwarsa' : 'Verifikasi Otomatis',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isExpiredNow
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF047857),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ── Mandiri: tampilkan Kode Biller + Kode Tagihan ─────────────
          if (widget.billerCode != null && widget.billerCode!.isNotEmpty &&
              widget.billKey != null && widget.billKey!.isNotEmpty) ...[
            Text(
              'Kode Biller (Mandiri)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 6),
            _buildCopyRow(
              context: context,
              value: widget.billerCode!,
              isExpiredNow: isExpiredNow,
              snackLabel: 'Kode Biller disalin!',
            ),
            const SizedBox(height: 10),
            Text(
              'Kode Tagihan (Mandiri)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 6),
            _buildCopyRow(
              context: context,
              value: widget.billKey!,
              isExpiredNow: isExpiredNow,
              snackLabel: 'Kode Tagihan disalin!',
            ),
          ] else ...[
            // ── Non-Mandiri: tampilkan Nomor Virtual Account ─────────────
            Text(
              'Nomor Virtual Account',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 6),
            _buildCopyRow(
              context: context,
              value: widget.vaNumber,
              isExpiredNow: isExpiredNow,
              snackLabel: 'Nomor Virtual Account disalin ke papan klip!',
            ),
          ],
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isExpiredNow
                    ? Icons.error_outline_rounded
                    : Icons.info_outline_rounded,
                color: isExpiredNow
                    ? const Color(0xFFDC2626)
                    : AppColors.greyText,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isExpiredNow
                      ? (widget.billerCode != null && widget.billerCode!.isNotEmpty
                          ? 'Waktu pembayaran telah kedaluwarsa. Kode tagihan di atas sudah dinonaktifkan.'
                          : 'Waktu pembayaran telah kedaluwarsa. Nomor VA di atas sudah dinonaktifkan.')
                      : 'Proses verifikasi instan kurang dari 1 menit setelah transfer berhasil.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: isExpiredNow
                        ? const Color(0xFFDC2626)
                        : AppColors.greyText,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Reusable row: nilai teks + tombol SALIN
  Widget _buildCopyRow({
    required BuildContext context,
    required String value,
    required bool isExpiredNow,
    required String snackLabel,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isExpiredNow ? const Color(0xFFF9FAFB) : AppColors.bgCanvas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpiredNow
              ? const Color(0xFFE5E7EB)
              : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: isExpiredNow
                    ? const Color(0xFF9CA3AF)
                    : AppColors.darkText,
                decoration:
                    isExpiredNow ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          InkWell(
            onTap: isExpiredNow
                ? null
                : () {
                    Clipboard.setData(
                        ClipboardData(text: value.replaceAll(' ', '')));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          snackLabel,
                          style: GoogleFonts.plusJakartaSans(fontSize: 12),
                        ),
                        backgroundColor: AppColors.darkText,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isExpiredNow
                    ? const Color(0xFFD1D5DB)
                    : AppColors.maroon,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy_rounded,
                      color: isExpiredNow
                          ? const Color(0xFF6B7280)
                          : Colors.white,
                      size: 13),
                  const SizedBox(width: 4),
                  Text(
                    'SALIN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isExpiredNow
                          ? const Color(0xFF6B7280)
                          : Colors.white,
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

  Widget _buildInstructionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TATA CARA PEMBAYARAN',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: AppColors.greyText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Column(
            children: [
              if (widget.billerCode != null && widget.billerCode!.isNotEmpty) ...[
                // ── Petunjuk khusus Mandiri ─────────────────────────────
                _buildAccordionItem(
                  title: 'Petunjuk Mandiri m-Banking / Livin\'',
                  initiallyExpanded: true,
                  steps: [
                    'Buka aplikasi Livin\' by Mandiri dan masuk dengan PIN.',
                    'Pilih menu Bayar → Multipayment.',
                    'Masukkan Kode Biller: ${widget.billerCode}.',
                    'Masukkan Kode Tagihan: ${widget.billKey}.',
                    'Pastikan nama dan nominal ${widget.totalAmount} sudah sesuai lalu konfirmasi.',
                  ],
                ),
                const Divider(color: AppColors.lightBorder, height: 1),
                _buildAccordionItem(
                  title: 'Petunjuk Mandiri ATM',
                  initiallyExpanded: false,
                  steps: [
                    'Masukkan kartu ATM Mandiri dan PIN.',
                    'Pilih menu Bayar/Beli → Multipayment.',
                    'Masukkan Kode Biller: ${widget.billerCode}.',
                    'Masukkan Kode Tagihan: ${widget.billKey}.',
                    'Periksa data transaksi dan tekan YA untuk konfirmasi.',
                  ],
                ),
              ] else ...[
                // ── Petunjuk VA standar ─────────────────────────────────
                _buildAccordionItem(
                  title: 'Petunjuk Transfer m-Banking',
                  initiallyExpanded: true,
                  steps: [
                    'Buka aplikasi m-Banking Anda dan masukkan PIN/Kode Akses.',
                    'Pilih menu Transfer lalu pilih Virtual Account.',
                    'Masukkan nomor Virtual Account: ${widget.vaNumber}.',
                    'Pastikan rincian Rumah Budaya Ratna dan nominal ${widget.totalAmount} sudah sesuai.',
                    'Masukkan PIN untuk menyelesaikan pembayaran.',
                  ],
                ),
                const Divider(color: AppColors.lightBorder, height: 1),
                _buildAccordionItem(
                  title: 'Petunjuk Transfer Melalui ATM',
                  initiallyExpanded: false,
                  steps: [
                    'Masukkan kartu ATM dan 6 digit PIN Anda.',
                    'Pilih menu Transaksi Lainnya > Transfer > ke Rekening Virtual Account.',
                    'Masukkan nomor Virtual Account: ${widget.vaNumber}.',
                    'Periksa data transaksi dan konfirmasi pembayaran.',
                    'Simpan struk ATM sebagai bukti pembayaran yang sah.',
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccordionItem({
    required String title,
    required List<String> steps,
    bool initiallyExpanded = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: const Border(),
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: steps.asMap().entries.map((entry) {
          final idx = entry.key + 1;
          final text = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.maroon.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$idx',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.maroon,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.darkText,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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
            onPressed:
                (isExpiredNow || _viewModel.isChecking) ? null : _checkStatus,
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
                        color: isExpiredNow
                            ? const Color(0xFF9CA3AF)
                            : Colors.white,
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
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8)),
          child: Text(
            isExpiredNow ? 'Kembali & Pesan Ulang' : 'Ubah Metode Pembayaran',
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
}
