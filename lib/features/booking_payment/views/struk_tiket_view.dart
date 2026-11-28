import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/core/widgets/mobile_frame.dart';
import 'package:mobile_app/features/home/views/main_screen.dart';

class StrukTiketView extends StatelessWidget {
  final String bookingId;
  final String eventTitle;
  final String category;
  final String eventTime;
  final String eventLocation;
  final String buyerName;
  final String buyerEmail;
  final String buyerPhone;
  final String ticketType;
  final int ticketCount;
  final String totalPrice;
  final String paymentMethod;
  final String? vaNumber;
  final String? billerCode;
  final String? billKey;
  final String? transactionStatus;

  const StrukTiketView({
    super.key,
    this.bookingId = '#TKT-9042',
    this.eventTitle = 'Napak Tanah Jilid II Book Club & Pot Luck',
    this.category = 'Lokakarya Seni',
    this.eventTime = 'Rabu, 10 Sep 2026 • 15:30 WIB',
    this.eventLocation = 'Ruang Komunal Lt. 2, Rumah Budaya Ratna',
    this.buyerName = 'Budi Santoso',
    this.buyerEmail = 'budi.santoso@gmail.com',
    this.buyerPhone = '0812-3456-7890',
    this.ticketType = 'Presale',
    this.ticketCount = 2,
    this.totalPrice = 'Rp 50.000',
    this.paymentMethod = 'QRIS Nasional',
    this.vaNumber,
    this.billerCode,
    this.billKey,
    this.transactionStatus,
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
            icon:
                const Icon(Icons.arrow_back_rounded, color: AppColors.textMain),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
                (route) => false,
              );
            },
          ),
          title: Text(
            'E-Tiket Lokakarya',
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined,
                  color: AppColors.textMain, size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tautan E-Tiket berhasil disalin!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 13,
                backgroundColor: AppColors.maroon,
                child: Text(
                  'RA',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // 1. Success Indicator & Header
              _buildSuccessHeader(),
              const SizedBox(height: 18),

              // 2. Ticket Card with Cutout Design
              _buildTicketCard(),
              const SizedBox(height: 20),

              // 3. Action Buttons
              _buildActionButtons(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isCash =>
      paymentMethod.toLowerCase().contains('kasir') ||
      paymentMethod.toLowerCase().contains('tunai') ||
      paymentMethod.toLowerCase().contains('loket');

  bool get _isExpired {
    final status = (transactionStatus ?? '').toLowerCase().trim();
    return status == 'expire' || status == 'expired';
  }

  bool get _isPending {
    final status = (transactionStatus ?? '').toLowerCase().trim();
    return status == 'pending' || _isCash;
  }

  // --- Widget: Success Header Badge ---
  Widget _buildSuccessHeader() {
    final statusColor = _isExpired
        ? const Color(0xFFDC2626)
        : (_isPending ? const Color(0xFFD97706) : const Color(0xFF10B981));
    final statusBgColor = _isExpired
        ? const Color(0xFFDC2626).withValues(alpha: 0.12)
        : (_isPending
            ? const Color(0xFFD97706).withValues(alpha: 0.12)
            : const Color(0xFF10B981).withValues(alpha: 0.1));
    final textBadgeColor = _isExpired
        ? const Color(0xFFDC2626)
        : (_isPending ? const Color(0xFFB45309) : const Color(0xFF047857));

    final IconData headerIcon = _isExpired
        ? Icons.close_rounded
        : (_isCash
            ? Icons.storefront_rounded
            : (_isPending ? Icons.access_time_rounded : Icons.check_rounded));

    final String badgeText = _isExpired
        ? 'TRANSAKSI KEDALUWARSA'
        : (_isCash
            ? 'PESANAN TIKET DIBUAT (LOKET)'
            : (_isPending
                ? 'MENUNGGU PEMBAYARAN'
                : 'TRANSAKSI TERVERIFIKASI'));

    final String titleText = _isExpired
        ? 'Pembayaran Kedaluwarsa'
        : (_isPending ? 'Pesanan Tiket Dibuat' : 'Pembayaran Berhasil');

    final String descText = _isExpired
        ? 'Batas waktu pembayaran telah kedaluwarsa. Nomor VA / pesanan ini dinonaktifkan.'
        : (_isCash
            ? 'Silakan tunjukkan kode booking ini dan bayar tunai di loket tiket / meja kasir sebelum acara.'
            : (_isPending
                ? 'Pesanan tiket telah dibuat. Silakan selesaikan pembayaran ke nomor VA atau kasir.'
                : 'E-tiket resmi telah terbit dan dikirimkan otomatis ke email Anda.'));

    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.28),
                blurRadius: 16,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(
            headerIcon,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusBgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            badgeText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: textBadgeColor,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          titleText,
          style: GoogleFonts.lora(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          descText,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  // --- Widget: Ticket Card ---
  Widget _buildTicketCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ticket Header Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.confirmation_number_outlined,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'RUMAH BUDAYA RATNA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    bookingId,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Event Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.tagBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.maroon,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  eventTitle,
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 12),

                // Waktu & Tempat
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: AppColors.maroon),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        eventTime,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.maroon),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        eventLocation,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Perforated Ticket Divider with Notches
          Row(
            children: [
              SizedBox(
                width: 12,
                height: 24,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.bgCanvas,
                    borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(12)),
                    border: Border.all(color: AppColors.border),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final boxWidth = constraints.constrainWidth();
                    const dashWidth = 5.0;
                    const dashHeight = 1.0;
                    final dashCount = (boxWidth / (2 * dashWidth)).floor();
                    return Flex(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      direction: Axis.horizontal,
                      children: List.generate(dashCount, (_) {
                        return const SizedBox(
                          width: dashWidth,
                          height: dashHeight,
                          child: DecoratedBox(
                              decoration:
                                  BoxDecoration(color: AppColors.border)),
                        );
                      }),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 12,
                height: 24,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.bgCanvas,
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12)),
                    border: Border.all(color: AppColors.border),
                  ),
                ),
              ),
            ],
          ),

          // Booker & Price Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildInfoRow('Nama Pemesan', buyerName),
                _buildInfoRow('Email Aktif', buyerEmail),
                _buildInfoRow('No. WhatsApp', buyerPhone),
                _buildInfoRow(
                    'Jenis Tiket', '$ticketType ($ticketCount Tiket)'),
                _buildInfoRow('Metode Pembayaran', paymentMethod),
                if (vaNumber != null && vaNumber!.isNotEmpty)
                  _buildInfoRow('Nomor Virtual Account', vaNumber!),
                if (billerCode != null &&
                    billerCode!.isNotEmpty &&
                    billKey != null &&
                    billKey!.isNotEmpty) ...[
                  _buildInfoRow('Kode Biller (Mandiri)', billerCode!),
                  _buildInfoRow('Kode Tagihan', billKey!),
                ],
                const Divider(color: AppColors.border, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          totalPrice,
                          style: GoogleFonts.lora(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.maroon,
                          ),
                        ),
                      ],
                    ),
                    _buildPaymentStatusBadge(),
                  ],
                ),
                const SizedBox(height: 18),

                // QR Code Check-in
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCanvas,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          size: 96,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'KODE CHECK-IN: RBR-EVT-9042',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tunjukkan QR Code ini ke petugas resepsionis saat check-in di venue.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusBadge() {
    final status = (transactionStatus ?? '').toLowerCase().trim();
    final bool isExpired = status == 'expire' || status == 'expired';
    final bool isPending = status == 'pending' || _isCash;

    final Color bgColor = isExpired
        ? const Color(0xFFFEE2E2)
        : (isPending
            ? const Color(0xFFFEF3C7)
            : const Color(0xFF10B981).withValues(alpha: 0.12));

    final Color fgColor = isExpired
        ? const Color(0xFFDC2626)
        : (isPending ? const Color(0xFFB45309) : const Color(0xFF047857));

    final IconData icon = isExpired
        ? Icons.cancel_outlined
        : (isPending ? Icons.access_time_rounded : Icons.check_circle_rounded);

    final String label = isExpired
        ? 'KEDALUWARSA'
        : (_isCash
            ? 'BELUM LUNAS (LOKET)'
            : (isPending ? 'PENDING' : 'LUNAS (SETTLEMENT)'));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fgColor, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget: Action Buttons ---
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tombol Simpan E-Tiket / Struk
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'E-Tiket resmi berhasil disimpan ke galeri dokumen!',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12),
                  ),
                  backgroundColor: AppColors.textMain,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.download_rounded,
                color: AppColors.maroon, size: 18),
            label: Text(
              'SIMPAN E-TIKET / STRUK',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.maroon,
                letterSpacing: 0.5,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.maroon, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Tombol Kembali ke Beranda
        SizedBox(
          height: 50,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              'KEMBALI KE BERANDA',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
