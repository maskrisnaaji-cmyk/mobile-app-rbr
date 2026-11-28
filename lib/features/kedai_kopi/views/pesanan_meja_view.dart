import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/core/services/user_session.dart';
import 'package:mobile_app/features/kedai_kopi/models/cart_item_model.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/core/widgets/mobile_frame.dart';
import 'package:mobile_app/features/booking_payment/widgets/payment_option_card.dart';
import 'package:mobile_app/features/booking_payment/widgets/price_summary_card.dart';
import 'package:mobile_app/features/booking_payment/views/qris_payment_view.dart';
import 'package:mobile_app/features/booking_payment/views/va_payment_view.dart';
import 'package:mobile_app/features/booking_payment/views/struk_pembayaran_view.dart';
import 'package:mobile_app/features/booking_payment/models/payment_model.dart';
import 'package:mobile_app/features/kedai_kopi/viewmodels/kedai_kopi_viewmodel.dart';
import 'package:mobile_app/features/kedai_kopi/models/coupon_model.dart';
import 'package:mobile_app/features/notification/viewmodels/notification_viewmodel.dart';

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
  bool _isCurrentUserVerified = false;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? KedaiKopiViewModel();
    _viewModel.fetchCoupons().then((_) {
      if (mounted) setState(() {});
    });
    _loadUserVerificationStatus();
  }

  Future<void> _loadUserVerificationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null && mounted) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final isVerified = userMap['is_verified'] == 1 ||
            userMap['is_verified'] == true ||
            userMap['is_verified'] == '1';
        setState(() => _isCurrentUserVerified = isVerified);
      }
    } catch (_) {}
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
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
                Flexible(
                  child: _viewModel.coupons.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'Belum ada kupon promo aktif.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.greyText,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _viewModel.coupons.length,
                          itemBuilder: (context, index) {
                            final coupon = _viewModel.coupons[index];
                            final isDisabled = coupon.isVerifiedOnly &&
                                !(_isCurrentUserVerified ||
                                    UserSession.instance.isVerified);
                            final isSelected =
                                _selectedCoupon?.code == coupon.code;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Opacity(
                                opacity: isDisabled ? 0.5 : 1.0,
                                child: InkWell(
                                  onTap: isDisabled
                                      ? null
                                      : () => Navigator.pop(context, coupon),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(13),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.maroon
                                            : AppColors.lightBorder,
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(9),
                                          decoration: BoxDecoration(
                                            color: isDisabled
                                                ? const Color(0xFFF5F5F5)
                                                : AppColors.tagBg,
                                            borderRadius:
                                                BorderRadius.circular(9),
                                          ),
                                          child: Icon(
                                            isDisabled
                                                ? Icons.lock_outline_rounded
                                                : Icons
                                                    .confirmation_number_outlined,
                                            color: isDisabled
                                                ? AppColors.greyText
                                                : AppColors.maroon,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    coupon.code,
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isDisabled
                                                          ? AppColors.greyText
                                                          : AppColors.darkText,
                                                    ),
                                                  ),
                                                  if (coupon.discountLabel
                                                      .isNotEmpty) ...[
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.maroon
                                                            .withValues(
                                                                alpha: 0.08),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Text(
                                                        coupon.discountLabel,
                                                        style: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              AppColors.maroon,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                coupon.description,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 10,
                                                  color: AppColors.greyText,
                                                ),
                                              ),
                                              if (coupon.isVerifiedOnly) ...[
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .verified_user_outlined,
                                                      size: 11,
                                                      color: isDisabled
                                                          ? AppColors.greyText
                                                          : const Color(
                                                              0xFF047857),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      'Khusus Member Terverifikasi',
                                                      style: GoogleFonts
                                                          .plusJakartaSans(
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isDisabled
                                                            ? AppColors.greyText
                                                            : const Color(
                                                                0xFF047857),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          isDisabled
                                              ? Icons.block_rounded
                                              : Icons.chevron_right_rounded,
                                          color: AppColors.greyText,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                if (_selectedCoupon != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context, null);
                        setState(() => _selectedCoupon = null);
                      },
                      child: Center(
                        child: Text(
                          'Batalkan pilihan kupon',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.maroon,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!mounted) return;
    if (selected != null) {
      setState(() => _selectedCoupon = selected);
    }
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
            subtitle: 'BCA, BNI, BRI, Mandiri, Permata, CIMB',
            isSelected: _viewModel.selectedPaymentMethod == 2,
            onTap: () => _viewModel.selectPaymentMethod(2),
          ),
          // ── Sub-panel pemilih bank VA ─────────────────────────────────
          if (_viewModel.selectedPaymentMethod == 2) ...[
            const SizedBox(height: 10),
            _buildBankSelector(),
          ],
        ],
      ),
    );
  }

  static const _kBankOptions = [
    {'code': 'bca',      'label': 'BCA'},
    {'code': 'bni',      'label': 'BNI'},
    {'code': 'bri',      'label': 'BRI'},
    {'code': 'echannel', 'label': 'Mandiri'},
    {'code': 'permata',  'label': 'Permata'},
    {'code': 'cimb',     'label': 'CIMB'},
  ];

  Widget _buildBankSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _kBankOptions.map((b) {
        final isActive = _viewModel.selectedBank == b['code'];
        return GestureDetector(
          onTap: () => _viewModel.selectBank(b['code']!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.maroon.withValues(alpha: 0.1)
                  : AppColors.bgCanvas,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive ? AppColors.maroon : AppColors.lightBorder,
                width: isActive ? 1.5 : 1,
              ),
            ),
            child: Text(
              b['label']!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight:
                    isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? AppColors.maroon : AppColors.greyText,
              ),
            ),
          ),
        );
      }).toList(),
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
          final isQris = paymentMethod == 0;
          final isVa = paymentMethod == 2;

          final strukView = StrukPembayaranView(
            orderNumber: orderNo,
            tableName: '$table (Dine-In)',
            cartItems: items,
            subtotal: _subtotal,
            totalPrice: total,
            paymentMethod: isQris
                ? 'QRIS (INSTAN)'
                : (isVa ? 'Transfer Bank (VA)' : 'Bayar di Kasir (Tunai)'),
          );

          if (isQris || isVa) {
            // ── Alur Pembayaran Midtrans Sandbox (QRIS & Virtual Account) ────
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
            final createdOrder = await _viewModel.createKedaiOrder(
              orderCode: cleanOrder,
              tableNumber: table,
              items: items,
              totalPrice: total,
            );
            NotificationViewModel.instance.fetchNotifications();

            if (createdOrder == null) {
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Pesanan gagal dikirim ke kedai. Coba lagi.')),
              );
              return;
            }

            // 2. Buat charge transaksi (Midtrans Sandbox: QRIS atau Bank Transfer VA)
            final chargeResult = await _viewModel.submitOrderTransaction(
              orderId: cleanOrder,
              grossAmount: total,
              customerName: 'Pelanggan $table',
              paymentType: isQris ? 'qris' : 'bank_transfer',
              bank: isQris ? '' : _viewModel.selectedBank,
              items: items,
              couponCode: _selectedCoupon?.code,
              userId: UserSession.instance.userId,
            );
            if (!mounted) return;
            Navigator.pop(context); // Tutup loading dialog

            // Tangani kegagalan charge / validasi kupon
            if (chargeResult?['error'] == true) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Pembayaran Gagal'),
                  content: Text(
                    chargeResult?['message'] as String? ??
                        'Terjadi kesalahan saat memproses pembayaran.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
              return;
            }

            final finalOrderId = chargeResult?['order_id'] ?? cleanOrder;
            final paidAmount =
                (chargeResult?['gross_amount'] as num?)?.toInt() ?? total;

            DateTime? createdAt;
            DateTime? expiredAt;
            if (chargeResult?['created_at'] != null) {
              createdAt =
                  DateTime.tryParse(chargeResult!['created_at'].toString());
            }
            if (chargeResult?['expired_at'] != null) {
              expiredAt =
                  DateTime.tryParse(chargeResult!['expired_at'].toString());
            }

            if (isQris) {
              final qrisData = QrisPaymentData.fromMap(chargeResult);
              final effectiveQrUrl = qrisData.qrCodeUrl ??
                  chargeResult?['qr_code_url'] as String? ??
                  chargeResult?['qr_url'] as String?;
              final effectiveQrString =
                  qrisData.qrString ?? chargeResult?['qr_string'] as String?;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QrisPaymentView(
                    title: 'Pesanan Meja',
                    orderNumber: finalOrderId,
                    badgeText: '$table • Dine-in',
                    totalAmount: _formatRupiah(paidAmount),
                    rawAmount: paidAmount,
                    qrUrl: effectiveQrUrl,
                    qrString: effectiveQrString,
                    buttonLabel: 'CEK STATUS PEMBAYARAN',
                    nextScreen: strukView,
                    kedaiOrderCode: cleanOrder,
                    createdAt: createdAt,
                    expiredAt: expiredAt,
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
                    badgeText: '$table • Dine-in',
                    totalAmount: _formatRupiah(paidAmount),
                    rawAmount: paidAmount,
                    vaNumber: chargeResult?['va_number'] as String? ??
                        chargeResult?['permata_va_number'] as String? ??
                        '—',
                    bankName:
                        '${(chargeResult?['bank'] ?? _viewModel.selectedBank).toString().toUpperCase()} Virtual Account',
                    billerCode: chargeResult?['biller_code'] as String?,
                    billKey: chargeResult?['bill_key'] as String?,
                    buttonLabel: 'CEK STATUS PEMBAYARAN',
                    nextScreen: strukView,
                    kedaiOrderCode: cleanOrder,
                    createdAt: createdAt,
                    expiredAt: expiredAt,
                  ),
                ),
              );
            }
            return;
          }

          // ── Alur Pembayaran "Bayar di Kasir (Tunai)" ──────────────────────
          if (!mounted) return;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(color: AppColors.maroon),
            ),
          );

          // 1. Daftarkan pesanan kasir / tunai ke backend (POST /api/kedai/orders)
          final createdOrder = await _viewModel.createKedaiOrder(
            orderCode: orderNo,
            tableNumber: table,
            items: items,
            totalPrice: total,
          );
          NotificationViewModel.instance.fetchNotifications();

          // 2. Catat transaksi kasir (POST /api/payment/charge dengan payment_type: 'cash')
          await _viewModel.submitOrderTransaction(
            orderId: orderNo,
            grossAmount: total,
            customerName: 'Pelanggan $table',
            paymentType: 'cash',
            bank: '',
            items: items,
            couponCode: _selectedCoupon?.code,
            userId: UserSession.instance.userId,
          );

          if (!mounted) return;
          Navigator.pop(context); // Tutup loading

          if (createdOrder == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Pesanan gagal dikirim ke kedai. Coba lagi.')),
            );
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.maroon,
              content: Text(
                  'Pesanan berhasil dibuat. Silakan lakukan pembayaran di meja kasir dalam 30 menit.'),
              duration: Duration(seconds: 3),
            ),
          );

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
