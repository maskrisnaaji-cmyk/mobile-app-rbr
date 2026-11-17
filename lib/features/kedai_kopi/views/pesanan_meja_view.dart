import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/features/kedai_kopi/models/cart_item_model.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/core/widgets/mobile_frame.dart';
import 'package:mobile_app/features/booking_payment/widgets/payment_option_card.dart';
import 'package:mobile_app/features/booking_payment/widgets/price_summary_card.dart';
import 'package:mobile_app/features/booking_payment/views/qris_payment_view.dart';
import 'package:mobile_app/features/booking_payment/views/va_payment_view.dart';
import 'package:mobile_app/features/booking_payment/views/struk_pembayaran_view.dart';
import 'package:mobile_app/features/kedai_kopi/viewmodels/kedai_kopi_viewmodel.dart';
import 'package:mobile_app/features/kedai_kopi/models/coupon_model.dart';

class PesananMejaView extends StatefulWidget {
  final List<CartItem> cartItems;
  final String tableName;
  final String orderNumber;
  final KedaiKopiViewModel? viewModel;

  const PesananMejaView({
    super.key,
    this.cartItems = const [],
    this.tableName = 'Meja No. 04',
    this.orderNumber = '#ORD-9042',
    this.viewModel,
  });

  @override
  State<PesananMejaView> createState() => _PesananMejaViewState();
}

class _PesananMejaViewState extends State<PesananMejaView> {
  late final KedaiKopiViewModel _viewModel;
  CultureCoupon? _selectedCoupon;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? KedaiKopiViewModel();
    _viewModel.fetchCoupons().then((_) {
      if (mounted) setState(() {});
    });
  }

  List<CartItem> get _effectiveCartItems {
    if (widget.cartItems.isNotEmpty) {
      return widget.cartItems;
    }
    return const [
      CartItem(
        name: 'Kopi Susu Creamy',
        price: 18000,
        quantity: 1,
        note: 'Less Sugar • Less Ice',
      ),
      CartItem(
        name: 'Americano Signature',
        price: 17000,
        quantity: 1,
        note: 'Single Origin • Hot',
      ),
    ];
  }

  int get _subtotal {
    return _effectiveCartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get _totalItemsCount {
    return _effectiveCartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  int get _taxFee => 0;
  int get _discount => _selectedCoupon?.discountFor(_subtotal) ?? 0;
  int get _totalPrice => _subtotal + _taxFee - _discount;

  String _formatRupiah(int price) {
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
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
            icon:
                const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Pesanan Meja',
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Pendopo
              _buildBannerPendopo(),
              const SizedBox(height: 16),

              // Card Detail Outlet
              _buildOutletCard(),
              const SizedBox(height: 16),

              // Ringkasan Menu
              _buildMenuSummary(),
              const SizedBox(height: 16),

              // Kupon & Promo
              _buildPromoSection(),
              const SizedBox(height: 16),

              // Rincian Pembayaran
              PriceSummaryCard(
                subtotalLabel: 'Subtotal ($_totalItemsCount Item)',
                subtotal: _formatRupiah(_subtotal),
                taxFee: _formatRupiah(_taxFee),
                discount:
                    _discount > 0 ? '-${_formatRupiah(_discount)}' : 'Rp 0',
                totalPrice: _formatRupiah(_totalPrice),
              ),
              const SizedBox(height: 16),

              // Metode Pembayaran
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) => _buildPaymentSection(),
              ),
              const SizedBox(height: 24),

              // Tombol Konfirmasi Bayar
              _buildConfirmButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerPendopo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFEDD5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFED7AA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.coffee_rounded,
                color: AppColors.maroon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Racikan Hangat Pendopo',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  'Pesanan Anda diseduh seksama dengan biji kopi sangrai lokal.',
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

  Widget _buildOutletCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KEDAI & GALERI',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.greyText,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.orderNumber,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.maroon,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'RUMAH BUDAYA RATNA',
            style: GoogleFonts.lora(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.goldLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.tableName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.maroon,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '• Dine-in (Di Tempat)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSummary() {
    final items = _effectiveCartItems;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Ringkasan Menu',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.bgCanvas,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${items.length} Menu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greyText,
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Ubah',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.maroon,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Column(
                children: [
                  if (index > 0)
                    const Divider(height: 20, color: AppColors.lightBorder),
                  _buildOrderItem(
                    '${item.quantity}x ${item.name}',
                    _formatRupiah(item.totalPrice),
                    item.note.isNotEmpty
                        ? item.note
                        : (item.category ?? 'Pesanan Kedai'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(String name, String price, String note) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                note,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          price,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildPromoSection() {
    final coupon = _selectedCoupon;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.confirmation_number_outlined,
                      color: AppColors.maroon, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Kupon & Promo Budaya',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
              Text(
                'Tersedia ${_viewModel.coupons.length} kupon',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _showCouponPicker,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: coupon == null
                    ? const Color(0xFFFFF7ED)
                    : const Color(0xFFEFFAF3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: coupon == null
                      ? AppColors.goldLight
                      : const Color(0xFF9AD5AE),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    coupon == null
                        ? Icons.local_offer_outlined
                        : Icons.check_circle,
                    color: coupon == null
                        ? AppColors.maroon
                        : const Color(0xFF16803C),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      coupon == null
                          ? 'Pilih kupon budaya'
                          : '${coupon.code} • ${coupon.description}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.greyText, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCouponPicker() async {
    final selected = await showModalBottomSheet<CultureCoupon>(
      context: context,
      backgroundColor: AppColors.bgCanvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Pilih Kupon Budaya',
                style: GoogleFonts.lora(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pilih satu kupon untuk mendapatkan potongan harga.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.greyText,
                ),
              ),
              const SizedBox(height: 14),
              ..._viewModel.coupons.map(
                (coupon) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => Navigator.pop(context, coupon),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: AppColors.tagBg,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                                Icons.confirmation_number_outlined,
                                color: AppColors.maroon,
                                size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coupon.code,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  coupon.description,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    color: AppColors.greyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: AppColors.greyText),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || selected == null) return;
    setState(() => _selectedCoupon = selected);
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.payment_rounded,
                      color: AppColors.maroon, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Metode Pembayaran',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
              Text(
                'Pilih Salah Satu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PaymentOptionCard(
            title: 'QRIS Nasional',
            badge: 'INSTAN',
            subtitle: 'BCA, GoPay, OVO, ShopeePay, Dana, LinkAja',
            isSelected: _viewModel.selectedPaymentMethod == 0,
            onTap: () => _viewModel.selectPaymentMethod(0),
          ),
          const SizedBox(height: 8),
          PaymentOptionCard(
            title: 'Bayar di Kasir (Tunai)',
            badge: 'Kasir Pendopo',
            subtitle: 'Bayar langsung di meja kasir setelah memesan',
            isSelected: _viewModel.selectedPaymentMethod == 1,
            onTap: () => _viewModel.selectPaymentMethod(1),
          ),
          const SizedBox(height: 8),
          PaymentOptionCard(
            title: 'Transfer Bank (Virtual Account)',
            badge: 'VA 24 JAM',
            subtitle: 'BCA, Mandiri, BNI, BRI, Permata',
            isSelected: _viewModel.selectedPaymentMethod == 2,
            onTap: () => _viewModel.selectPaymentMethod(2),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () async {
          final items = _effectiveCartItems;
          final total = _totalPrice;
          final orderNo = widget.orderNumber;
          final table = widget.tableName;
          final paymentMethod = _viewModel.selectedPaymentMethod;

          final strukView = StrukPembayaranView(
            orderNumber: orderNo,
            tableName: '$table (Dine-In)',
            cartItems: items,
            subtotal: _subtotal,
            totalPrice: total,
            paymentMethod: paymentMethod == 0
                ? 'QRIS (INSTAN)'
                : (paymentMethod == 2 ? 'Transfer Bank (VA)' : 'Tunai Kasir'),
          );

          if (paymentMethod == 0 || paymentMethod == 2) {
            final isQris = paymentMethod == 0;
            final cleanOrder =
                'RBR-KEDAI-${DateTime.now().millisecondsSinceEpoch}';

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(
                child: CircularProgressIndicator(color: AppColors.maroon),
              ),
            );

            // 1. Kirim order ke backend kedai (POST /api/kedai/orders)
            await _viewModel.createKedaiOrder(
              orderCode: cleanOrder,
              tableNumber: table,
              items: items,
              totalPrice: total,
            );

            // 2. Buat charge transaksi (Midtrans)
            final chargeResult = await _viewModel.submitOrderTransaction(
              orderId: cleanOrder,
              grossAmount: total,
              customerName: 'Pelanggan $table',
              paymentType: isQris ? 'qris' : 'bank_transfer',
              bank: 'bca',
              items: items,
            );

            if (!mounted) return;
            Navigator.pop(context); // Tutup loading dialog

            final finalOrderId = chargeResult?['order_id'] ?? cleanOrder;

            if (isQris) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QrisPaymentView(
                    title: 'Pesanan Meja',
                    orderNumber: finalOrderId,
                    badgeText: '$table • Dine-in',
                    totalAmount: _formatRupiah(total),
                    rawAmount: total,
                    qrUrl: chargeResult?['qr_url'],
                    qrString: chargeResult?['qr_string'],
                    buttonLabel: 'CEK STATUS PEMBAYARAN',
                    nextScreen: strukView,
                    kedaiOrderCode: cleanOrder,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VaPaymentView(
                    title: 'Pesanan Meja',
                    orderNumber: finalOrderId,
                    badgeText: table,
                    totalAmount: _formatRupiah(total),
                    rawAmount: total,
                    vaNumber:
                        chargeResult?['va_number'] ?? '5213 1845 9403 1716',
                    bankName:
                        '${(chargeResult?['bank'] ?? 'BCA').toUpperCase()} Virtual Account',
                    buttonLabel: 'CEK STATUS PEMBAYARAN',
                    nextScreen: strukView,
                    kedaiOrderCode: cleanOrder,
                  ),
                ),
              );
            }
            return;
          }

          if (!mounted) return;

          // Daftarkan pesanan kasir / tunai ke backend (status UNPAID)
          await _viewModel.createKedaiOrder(
            orderCode: orderNo,
            tableNumber: table,
            items: items,
            totalPrice: total,
          );

          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => strukView,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.maroon,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'KONFIRMASI BAYAR',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
