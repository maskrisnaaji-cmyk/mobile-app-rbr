import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/mobile_frame.dart';
import 'struk_pembayaran_view.dart';
import 'struk_tiket_view.dart';

/// Halaman Riwayat Pesanan & Tiket
/// Menampilkan ringkasan transaksi Kedai Kopi dan Tiket Agenda,
/// dengan aksi "Lihat Struk" yang mengarahkan ke [StrukPembayaranView] / [StrukTiketView].
class RiwayatPesananScreen extends StatefulWidget {
  const RiwayatPesananScreen({super.key});

  @override
  State<RiwayatPesananScreen> createState() => _RiwayatPesananScreenState();
}

class _RiwayatPesananScreenState extends State<RiwayatPesananScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Data statis riwayat pesanan kedai ---
  final List<Map<String, dynamic>> _pesananKedai = [
    {
      'orderNumber': '#ORD-9042',
      'date': 'Sabtu, 25 Okt 2026 • 14:32 WIB',
      'items': ['Kopi Susu Gula Aren (x1)', 'Pisang Goreng Keju (x2)'],
      'total': 45000,
      'status': 'Selesai',
      'meja': 'Meja No. 04 (Dine-In)',
      'payment': 'QRIS (INSTAN)',
    },
    {
      'orderNumber': '#ORD-8817',
      'date': 'Rabu, 15 Okt 2026 • 11:10 WIB',
      'items': ['Wedang Uwuh (x2)', 'Teh Rempah Nusantara (x1)'],
      'total': 36000,
      'status': 'Selesai',
      'meja': 'Meja No. 02 (Dine-In)',
      'payment': 'QRIS (INSTAN)',
    },
    {
      'orderNumber': '#ORD-8201',
      'date': 'Jum, 03 Okt 2026 • 16:45 WIB',
      'items': ['Kopi Hitam Tubruk (x1)'],
      'total': 15000,
      'status': 'Selesai',
      'meja': 'Meja No. 01 (Dine-In)',
      'payment': 'Tunai',
    },
  ];

  // --- Data statis riwayat tiket agenda ---
  final List<Map<String, dynamic>> _tiketAgenda = [
    {
      'bookingId': '#TKT-3041',
      'eventTitle': 'Napak Tanah Jilid II — Book Club & Pot Luck',
      'category': 'Lokakarya Seni',
      'eventTime': 'Rabu, 28 Sep 2026 • 15:30 WIB',
      'location': 'Ruang Komunal Lt. 2, Rumah Budaya Ratna',
      'ticketType': 'Tiket Reguler',
      'ticketCount': 2,
      'totalPrice': 'Rp 50.000',
      'payment': 'QRIS',
      'status': 'Hadir',
    },
    {
      'bookingId': '#TKT-2988',
      'eventTitle': 'Obrolan Budaya: Dialektika Tradisi & Modernitas',
      'category': 'Diskusi',
      'eventTime': 'Rabu, 08 Okt 2026 • 19:00 WIB',
      'location': 'Pendopo Utama, Rumah Budaya Ratna',
      'ticketType': 'Tiket Gratis (Daftar)',
      'ticketCount': 1,
      'totalPrice': 'Gratis',
      'payment': '-',
      'status': 'Hadir',
    },
    {
      'bookingId': '#TKT-3109',
      'eventTitle': 'Workshop Keramik: Tanah & Tangan',
      'category': 'Workshop',
      'eventTime': 'Min, 11 Okt 2026 • 10:00 WIB',
      'location': 'Studio Kriya Lt. 1, Rumah Budaya Ratna',
      'ticketType': 'Tiket Reguler',
      'ticketCount': 1,
      'totalPrice': 'Rp 75.000',
      'payment': 'Transfer Bank',
      'status': 'Hadir',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}';
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
            'Riwayat Pesanan & Tiket',
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.maroonDark,
            ),
          ),
          centerTitle: false,
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
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5),
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
    if (_pesananKedai.isEmpty) {
      return _buildEmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'Belum ada riwayat pesanan kedai.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _pesananKedai.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = _pesananKedai[index];
        final items = (order['items'] as List<String>).join(', ');
        final total = _formatRupiah(order['total'] as int);
        return _buildKedaiCard(
          orderNumber: order['orderNumber'] as String,
          date: order['date'] as String,
          items: items,
          total: total,
          status: order['status'] as String,
          meja: order['meja'] as String,
          payment: order['payment'] as String,
        );
      },
    );
  }

  Widget _buildKedaiCard({
    required String orderNumber,
    required String date,
    required String items,
    required String total,
    required String status,
    required String meja,
    required String payment,
  }) {
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
            // Header: Nomor pesanan + status
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
                      orderNumber,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFEFEAE2)),
            const SizedBox(height: 10),

            // Tanggal
            _buildDetailRow(Icons.access_time_outlined, date),
            const SizedBox(height: 5),
            // Item
            _buildDetailRow(Icons.fastfood_outlined, items),
            const SizedBox(height: 5),
            // Meja
            _buildDetailRow(Icons.table_restaurant_outlined, meja),
            const SizedBox(height: 5),
            // Pembayaran
            _buildDetailRow(Icons.payment_outlined, payment),
            const SizedBox(height: 12),

            // Footer: total + tombol struk
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: AppColors.greyText,
                      ),
                    ),
                    Text(
                      total,
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
                        builder: (_) => StrukPembayaranView(
                          orderNumber: orderNumber,
                          paymentMethod: payment,
                          tableName: meja,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_outlined, size: 14),
                  label: Text(
                    'Lihat Struk',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.maroon,
                    side: const BorderSide(color: AppColors.maroon),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    if (_tiketAgenda.isEmpty) {
      return _buildEmptyState(
        icon: Icons.confirmation_num_outlined,
        message: 'Belum ada riwayat tiket agenda.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _tiketAgenda.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ticket = _tiketAgenda[index];
        return _buildTiketCard(ticket);
      },
    );
  }

  Widget _buildTiketCard(Map<String, dynamic> ticket) {
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
            // Header: ID Tiket + status
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
                      ticket['bookingId'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(ticket['status'] as String),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFEFEAE2)),
            const SizedBox(height: 10),

            // Judul event
            Text(
              ticket['eventTitle'] as String,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lora(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: AppColors.maroonDark,
              ),
            ),
            const SizedBox(height: 6),

            // Kategori badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
              decoration: BoxDecoration(
                color: AppColors.maroon.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                ticket['category'] as String,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.maroon,
                ),
              ),
            ),
            const SizedBox(height: 8),

            _buildDetailRow(Icons.access_time_outlined, ticket['eventTime'] as String),
            const SizedBox(height: 5),
            _buildDetailRow(Icons.location_on_outlined, ticket['location'] as String),
            const SizedBox(height: 5),
            _buildDetailRow(
              Icons.confirmation_num_outlined,
              '${ticket['ticketType']} • ${ticket['ticketCount']} tiket',
            ),
            const SizedBox(height: 12),

            // Footer: total + tombol struk
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 10, color: AppColors.greyText),
                    ),
                    Text(
                      ticket['totalPrice'] as String,
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
                          bookingId: ticket['bookingId'] as String,
                          eventTitle: ticket['eventTitle'] as String,
                          category: ticket['category'] as String,
                          eventTime: ticket['eventTime'] as String,
                          eventLocation: ticket['location'] as String,
                          ticketType: ticket['ticketType'] as String,
                          ticketCount: ticket['ticketCount'] as int,
                          totalPrice: ticket['totalPrice'] as String,
                          paymentMethod: ticket['payment'] as String,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code_2_rounded, size: 14),
                  label: Text(
                    'Lihat Tiket',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.maroon,
                    side: const BorderSide(color: AppColors.maroon),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'hadir':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case 'dibatalkan':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        break;
      default:
        bg = const Color(0xFFFEF9C3);
        fg = const Color(0xFFB45309);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 52, color: AppColors.greyText.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }
}
