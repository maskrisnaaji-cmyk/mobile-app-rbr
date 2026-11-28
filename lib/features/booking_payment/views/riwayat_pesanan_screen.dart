import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/widgets/user_avatar_widget.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/core/widgets/mobile_frame.dart';
import 'package:mobile_app/features/booking_payment/models/payment_model.dart';
import 'package:mobile_app/features/booking_payment/views/struk_pembayaran_view.dart';
import 'package:mobile_app/features/booking_payment/views/struk_tiket_view.dart';
import 'package:mobile_app/features/booking_payment/viewmodels/booking_payment_viewmodel.dart';

/// Halaman Riwayat Pesanan & Tiket
class RiwayatPesananScreen extends StatefulWidget {
  final RiwayatPesananViewModel? viewModel;

  const RiwayatPesananScreen({super.key, this.viewModel});

  @override
  State<RiwayatPesananScreen> createState() => _RiwayatPesananScreenState();
}

class _RiwayatPesananScreenState extends State<RiwayatPesananScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final RiwayatPesananViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? RiwayatPesananViewModel();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.textMain),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Riwayat Pesanan & Tiket',
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.maroonDark,
            ),
          ),
          centerTitle: false,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 14),
              child: Center(child: UserAvatarWidget(radius: 13)),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.maroon,
            unselectedLabelColor: AppColors.greyText,
            indicatorColor: AppColors.maroon,
            indicatorWeight: 2.5,
            labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle:
                GoogleFonts.plusJakartaSans(fontSize: 12.5),
            tabs: const [
              Tab(text: 'Pesanan Kedai'),
              Tab(text: 'Tiket Agenda'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPesananKedaiTab(),
            _buildTiketAgendaTab(),
          ],
        ),
      ),
    );
  }

  // ─── TAB 1: Pesanan Kedai ────────────────────────────────────────────────
  Widget _buildPesananKedaiTab() {
    final list = _viewModel.pesananKedai;
    if (list.isEmpty) {
      return _buildEmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'Belum ada riwayat pesanan kedai.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = list[index];
        return _buildKedaiCard(order);
      },
    );
  }

  Widget _buildKedaiCard(PesananKedaiModel order) {
    final total = _viewModel.formatRupiah(order.total);
    final items = order.items.join(', ');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5EBE6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_cafe_rounded,
                          color: AppColors.maroon, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.orderNumber,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFEFEAE2)),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.access_time_outlined, order.date),
            const SizedBox(height: 5),
            _buildDetailRow(Icons.fastfood_outlined, items),
            const SizedBox(height: 5),
            _buildDetailRow(Icons.table_restaurant_outlined, order.meja),
            const SizedBox(height: 5),
            _buildDetailRow(Icons.payment_outlined, _formatPaymentLabel(order.payment)),
            if (order.vaNumber != null && order.vaNumber!.isNotEmpty) ...[
              const SizedBox(height: 5),
              _buildDetailRow(Icons.pin_outlined, 'No. VA: ${order.vaNumber}'),
            ],
            if (order.billerCode != null &&
                order.billerCode!.isNotEmpty &&
                order.billKey != null &&
                order.billKey!.isNotEmpty) ...[
              const SizedBox(height: 5),
              _buildDetailRow(Icons.pin_outlined,
                  'Biller: ${order.billerCode} • Tagihan: ${order.billKey}'),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Pembayaran',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 10, color: AppColors.greyText)),
                    Text(total,
                        style: GoogleFonts.lora(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.maroon,
                        )),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StrukPembayaranView(
                          orderNumber: order.orderNumber,
                          paymentMethod: _formatPaymentLabel(order.payment),
                          tableName: order.meja,
                          vaNumber: order.vaNumber,
                          billerCode: order.billerCode,
                          billKey: order.billKey,
                          transactionStatus: order.status,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_outlined, size: 14),
                  label: Text('Lihat Struk',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.maroon,
                    side: const BorderSide(color: AppColors.maroon),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── TAB 2: Tiket Agenda ────────────────────────────────────────────────
  Widget _buildTiketAgendaTab() {
    final list = _viewModel.tiketAgenda;
    if (list.isEmpty) {
      return _buildEmptyState(
        icon: Icons.confirmation_num_outlined,
        message: 'Belum ada riwayat tiket agenda.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildTiketCard(list[index]),
    );
  }

  Widget _buildTiketCard(TiketAgendaModel ticket) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5EBE6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.confirmation_num_rounded,
                          color: AppColors.maroon, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ticket.bookingId,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(ticket.status),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFEFEAE2)),
            const SizedBox(height: 10),
            Text(
              ticket.eventTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lora(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: AppColors.maroonDark,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
              decoration: BoxDecoration(
                color: AppColors.maroon.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                ticket.category,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.maroon,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.access_time_outlined, ticket.eventTime),
            const SizedBox(height: 5),
            _buildDetailRow(Icons.location_on_outlined, ticket.location),
            const SizedBox(height: 5),
            _buildDetailRow(
              Icons.confirmation_num_outlined,
              '${ticket.ticketType} • ${ticket.ticketCount} tiket',
            ),
            const SizedBox(height: 5),
            _buildDetailRow(
              Icons.payment_outlined,
              _formatPaymentLabel(ticket.payment),
            ),
            if (ticket.vaNumber != null && ticket.vaNumber!.isNotEmpty) ...[
              const SizedBox(height: 5),
              _buildDetailRow(Icons.pin_outlined, 'No. VA: ${ticket.vaNumber}'),
            ],
            if (ticket.billerCode != null &&
                ticket.billerCode!.isNotEmpty &&
                ticket.billKey != null &&
                ticket.billKey!.isNotEmpty) ...[
              const SizedBox(height: 5),
              _buildDetailRow(Icons.pin_outlined,
                  'Biller: ${ticket.billerCode} • Tagihan: ${ticket.billKey}'),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 10, color: AppColors.greyText)),
                    Text(
                      ticket.totalPrice,
                      style: GoogleFonts.lora(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.maroon,
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StrukTiketView(
                          bookingId: ticket.bookingId,
                          eventTitle: ticket.eventTitle,
                          category: ticket.category,
                          eventTime: ticket.eventTime,
                          eventLocation: ticket.location,
                          ticketType: ticket.ticketType,
                          ticketCount: ticket.ticketCount,
                          totalPrice: ticket.totalPrice,
                          paymentMethod: _formatPaymentLabel(ticket.payment),
                          vaNumber: ticket.vaNumber,
                          billerCode: ticket.billerCode,
                          billKey: ticket.billKey,
                          transactionStatus: ticket.status,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code_2_rounded, size: 14),
                  label: Text('Lihat Tiket',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.maroon,
                    side: const BorderSide(color: AppColors.maroon),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helper Widgets ──────────────────────────────────────────────────────
  static String _formatPaymentLabel(String raw) {
    final lower = raw.toLowerCase().trim();
    switch (lower) {
      case 'qris':
      case 'qris (instan)':
      case 'qris nasional':
        return 'QRIS (INSTAN)';
      case 'bca':
      case 'va_bca':
        return 'BCA Virtual Account';
      case 'bni':
      case 'va_bni':
        return 'BNI Virtual Account';
      case 'bri':
      case 'va_bri':
        return 'BRI Virtual Account';
      case 'echannel':
      case 'mandiri':
      case 'va_mandiri':
        return 'Mandiri Virtual Account';
      case 'permata':
      case 'va_permata':
        return 'Permata Virtual Account';
      case 'cimb':
      case 'va_cimb':
        return 'CIMB Niaga Virtual Account';
      case 'cash':
      case 'kasir':
      case 'tunai':
      case 'bayar di kasir (tunai)':
        return 'Bayar di Kasir (Tunai)';
      case '-':
      case '':
        return '-';
      default:
        return raw;
    }
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: AppColors.greyText),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              color: AppColors.greyText,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase().trim()) {
      case 'settlement':
      case 'paid':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        label = 'SETTLEMENT (LUNAS)';
        break;
      case 'pending':
        bg = const Color(0xFFFEF9C3);
        fg = const Color(0xFFB45309);
        label = 'PENDING';
        break;
      case 'expire':
      case 'expired':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        label = 'EXPIRED';
        break;
      case 'cancel':
      case 'cancelled':
      case 'deny':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        label = 'DIBATALKAN';
        break;
      case 'selesai':
      case 'hadir':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        label = status.toUpperCase();
        break;
      case 'dibatalkan':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        label = 'DIBATALKAN';
        break;
      default:
        bg = const Color(0xFFFEF9C3);
        fg = const Color(0xFFB45309);
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      {required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 52,
              color: AppColors.greyText.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(message,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.greyText)),
        ],
      ),
    );
  }
}
