import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/core/services/user_session.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/core/widgets/mobile_frame.dart';
import 'package:mobile_app/features/agenda/widgets/presale_tier_card.dart';
import 'package:mobile_app/features/booking_payment/views/qris_payment_view.dart';
import 'package:mobile_app/features/booking_payment/views/va_payment_view.dart';
import 'package:mobile_app/features/booking_payment/views/struk_tiket_view.dart';
import 'package:mobile_app/features/booking_payment/widgets/payment_option_card.dart';
import 'package:mobile_app/features/booking_payment/viewmodels/booking_payment_viewmodel.dart';
import 'package:mobile_app/features/kedai_kopi/models/coupon_model.dart';

const Color _paymentTerracotta = Color(0xFF8B2B1B);

class BookingCheckoutView extends StatefulWidget {
  final String eventTitle;
  final String category;
  final String time;
  final String location;
  final String basePath;
  final String basePrice;
  final String? eventImage;
  final String? eventImageFallback;
  final int? eventId;
  final BookingCheckoutViewModel? viewModel;

  const BookingCheckoutView({
    super.key,
    this.eventTitle = 'Napak Tanah Jilid II Book Club & Pot Luck',
    this.category = 'Lokakarya Seni',
    this.time = '10 Sep • 15:30 WIB',
    this.location = 'Ruang Komunal Lt. 2, Rumah Budaya Ratna',
    this.basePath = '',
    this.basePrice = 'Rp 25.000',
    this.eventImage,
    this.eventImageFallback,
    this.eventId,
    this.viewModel,
  });

  @override
  State<BookingCheckoutView> createState() => _BookingCheckoutViewState();
}

class _BookingCheckoutViewState extends State<BookingCheckoutView> {
  final _formKey = GlobalKey<FormState>();
  late final BookingCheckoutViewModel _viewModel;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  // --- Kupon Promo ---
  List<CultureCoupon> _coupons = [];
  CultureCoupon? _selectedCoupon;
  bool _isCurrentUserVerified = false;

  int get _discount =>
      _selectedCoupon?.discountFor(_viewModel.totalAmount) ?? 0;
  int get _finalTotal => _viewModel.totalAmount - _discount;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? BookingCheckoutViewModel();
    _nameController = TextEditingController(text: 'Budi Santoso');
    _emailController = TextEditingController(text: 'budi.santoso@gmail.com');
    _phoneController = TextEditingController(text: '0812-3456-7890');

    // Jika eventId ada, coba load presale tiers
    if (widget.eventId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _viewModel.loadPresaleTiers(widget.eventId!);
      });
    }
    _loadCoupons();
    _loadUserVerifiedStatus();
  }

  Future<void> _loadCoupons() async {
    try {
      final fetched = await CultureCoupon.fetchAll();
      if (mounted) setState(() => _coupons = fetched);
    } catch (_) {}
  }

  Future<void> _loadUserVerifiedStatus() async {
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
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
                'Booking Tiket / Checkout',
                style: GoogleFonts.lora(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline_rounded,
                      color: AppColors.textMain, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildEventInfoCard(),
                    const SizedBox(height: 16),
                    _buildTicketTypeSection(),
                    const SizedBox(height: 16),
                    _buildTicketQuantitySection(),
                    const SizedBox(height: 16),
                    _buildBookerFormSection(),
                    const SizedBox(height: 16),
                    _buildCouponSection(),
                    const SizedBox(height: 16),
                    _buildPaymentMethodSection(),
                    const SizedBox(height: 16),
                    _buildPriceSummaryCard(),
                    const SizedBox(height: 20),
                    _buildSubmitButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Widget: Informasi Event ---
  Widget _buildEventInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventBanner(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.tagBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.category,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.maroon,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFF59E0B), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Pilihan Komunitas',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.eventTitle,
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 13, color: AppColors.maroon),
                    const SizedBox(width: 6),
                    Text(
                      widget.time,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.maroon),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.location,
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
        ],
      ),
    );
  }

  Widget _buildEventBanner() {
    final image = widget.eventImage;
    if (image == null || image.isEmpty) return const SizedBox.shrink();

    Widget fallback() {
      final fb = widget.eventImageFallback;
      if (fb == null || fb.isEmpty) {
        return Container(color: _paymentTerracotta);
      }
      return Image.asset(fb,
          width: double.infinity,
          height: 170,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(color: _paymentTerracotta));
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: image.startsWith('http')
          ? Image.network(image,
              width: double.infinity,
              height: 170,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback())
          : Image.asset(
              image.startsWith('/') ? image.substring(1) : image,
              width: double.infinity,
              height: 170,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback()),
    );
  }

  // --- Widget: Pilihan Jenis Tiket ---
  Widget _buildTicketTypeSection() {
    // --- Presale mode: tampilkan tier presale dinamis ---
    if (_viewModel.isPresaleMode || _viewModel.isLoadingPresale) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PILIHAN JENIS TIKET',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.textMuted,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.maroon.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'PRESALE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.maroon,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Loading spinner
            if (_viewModel.isLoadingPresale)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(color: AppColors.maroon),
                ),
              )
            else
              _buildPresaleTierList(),
          ],
        ),
      );
    }

    // --- Mode normal: tampilkan card tiket statis ---
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PILIHAN JENIS TIKET',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                'Pilih salah satu',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTicketTypeCard(
            index: 0,
            title: 'Tiket Presale (Early Bird)',
            badge: 'HEMAT 28% • Kuota Terbatas',
            badgeColor: const Color(0xFF047857),
            badgeBgColor: const Color(0xFF10B981).withValues(alpha: 0.12),
            price: _viewModel.formatRupiah(_viewModel.presalePrice),
            description:
                'Akses penuh lokakarya, booklet materi, dan free kopi seduh.',
          ),
          const SizedBox(height: 10),
          _buildTicketTypeCard(
            index: 1,
            title: 'Tiket Reguler',
            badge: 'TERSEDIA',
            badgeColor: AppColors.maroon,
            badgeBgColor: AppColors.maroon.withValues(alpha: 0.08),
            price: _viewModel.formatRupiah(_viewModel.regulerPrice),
            description: 'Akses lokakarya dan sertifikat kehadiran digital.',
          ),
          const SizedBox(height: 10),
          _buildTicketTypeCard(
            index: 2,
            title: 'Tiket OTS (On The Spot)',
            badge: 'HANYA DI VENUE',
            badgeColor: AppColors.textMuted,
            badgeBgColor: AppColors.border,
            price: 'Rp 45.000',
            description:
                'Hanya dapat dibeli langsung di lokasi acara (tidak dapat dibeli melalui aplikasi).',
            enabled: false,
          ),
        ],
      ),
    );
  }

  /// Menampilkan list tier presale secara inline.
  Widget _buildPresaleTierList() {
    final tiers = _viewModel.presaleTiers;

    if (tiers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Belum ada data tier presale',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppColors.textMuted),
          ),
        ),
      );
    }

    final allSoldOut =
        tiers.every((t) => t.isSoldout || !t.isActive);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Banner semua sold out
        if (allSoldOut)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFDC2626), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Semua kuota presale habis — Tiket tidak tersedia',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Daftar PresaleTierCard
        ...List.generate(tiers.length, (i) {
          final tier = tiers[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i < tiers.length - 1 ? 10 : 0),
            child: PresaleTierCard(
              tier: tier,
              isSelected: _viewModel.selectedPresaleTier?.id == tier.id,
              onTap: (tier.isCurrentActive && !tier.isSoldout)
                  ? () => _viewModel.selectPresaleTier(tier)
                  : null,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTicketTypeCard({
    required int index,
    required String title,
    required String badge,
    required Color badgeColor,
    required Color badgeBgColor,
    required String price,
    required String description,
    bool enabled = true,
  }) {
    final isSelected = _viewModel.selectedTicketType == index;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: InkWell(
        onTap: enabled ? () => _viewModel.selectTicketType(index) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.maroon.withValues(alpha: 0.03)
                : AppColors.bgCanvas,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.maroon : AppColors.border,
              width: isSelected ? 1.6 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: !enabled
                            ? AppColors.textMuted
                            : isSelected
                                ? AppColors.maroon
                                : AppColors.textMuted,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 26.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 10, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$price / orang',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.maroon,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget: Jumlah Tiket ---
  Widget _buildTicketQuantitySection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'JUMLAH TIKET',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Maksimal 5 tiket per akun',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCanvas,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove,
                      size: 16, color: AppColors.maroon),
                  onPressed: _viewModel.ticketQuantity > 1
                      ? _viewModel.decrementQuantity
                      : null,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 32),
                  alignment: Alignment.center,
                  child: Text(
                    '${_viewModel.ticketQuantity}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add,
                      size: 16, color: AppColors.maroon),
                  onPressed: _viewModel.ticketQuantity < 5
                      ? _viewModel.incrementQuantity
                      : null,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget: Form Pemesan ---
  Widget _buildBookerFormSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_outlined,
                  color: AppColors.maroon, size: 17),
              const SizedBox(width: 8),
              Text(
                'INFORMASI PEMESAN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'E-Tiket akan diterbitkan sesuai nama dan kontak di bawah ini.',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 10, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          _buildFormField(
            controller: _nameController,
            label: 'Nama Lengkap',
            icon: Icons.person_outline_rounded,
            hint: 'Contoh: Budi Santoso',
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
          ),
          const SizedBox(height: 12),
          _buildFormField(
            controller: _emailController,
            label: 'Email Aktif (Pengiriman E-Tiket)',
            icon: Icons.mail_outline_rounded,
            hint: 'Contoh: budi@gmail.com',
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                v == null || !v.contains('@') ? 'Email tidak valid' : null,
          ),
          const SizedBox(height: 12),
          _buildFormField(
            controller: _phoneController,
            label: 'No. WhatsApp (Notifikasi Booking)',
            icon: Icons.phone_android_rounded,
            hint: 'Contoh: 081234567890',
            keyboardType: TextInputType.phone,
            validator: (v) =>
                v == null || v.trim().length < 8 ? 'Nomor HP tidak valid' : null,
          ),
        ],
      ),
    );
  }

  // --- Widget: Kupon & Promo ---
  Widget _buildCouponSection() {
    final coupon = _selectedCoupon;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.confirmation_number_outlined,
                  color: AppColors.maroon, size: 17),
              const SizedBox(width: 8),
              Text(
                'KUPON & PROMO',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _showCouponPickerSheet,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgCanvas,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: coupon != null ? AppColors.maroon : AppColors.border,
                  width: coupon != null ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    coupon != null
                        ? Icons.check_circle_outline_rounded
                        : Icons.local_offer_outlined,
                    color: coupon != null
                        ? AppColors.maroon
                        : AppColors.textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: coupon != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                coupon.code,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.maroon,
                                ),
                              ),
                              Text(
                                coupon.description,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            _coupons.isEmpty
                                ? 'Memuat kupon...'
                                : 'Pilih kupon promo',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (coupon != null) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() => _selectedCoupon = null),
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
          ],
        ],
      ),
    );
  }

  Future<void> _showCouponPickerSheet() async {
    final selected = await showModalBottomSheet<CultureCoupon>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.65,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Pilih Kupon Budaya',
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: _coupons.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Belum ada kupon tersedia.'),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        itemCount: _coupons.length,
                        itemBuilder: (_, index) {
                          final coupon = _coupons[index];
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
                                    : () => Navigator.pop(ctx, coupon),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.maroon
                                          : AppColors.border,
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
                                                    fontWeight: FontWeight.bold,
                                                    color: isDisabled
                                                        ? AppColors.greyText
                                                        : AppColors.textMain,
                                                  ),
                                                ),
                                                if (coupon
                                                    .discountLabel.isNotEmpty) ...[
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
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: Text(
                                                      coupon.discountLabel,
                                                      style: GoogleFonts
                                                          .plusJakartaSans(
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors.maroon,
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
                                                color: AppColors.textMuted,
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
                                        color: AppColors.textMuted,
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
                  padding: const EdgeInsets.only(top: 6, bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx, null);
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
    );
    if (!mounted) return;
    if (selected != null) setState(() => _selectedCoupon = selected);
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textMain,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 16, color: AppColors.maroon),
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textMuted.withValues(alpha: 0.6),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            filled: true,
            fillColor: AppColors.bgCanvas,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.maroon, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // --- Widget: Metode Pembayaran (Disamakan Total dengan Modul Kedai Kopi) ---
  Widget _buildPaymentMethodSection() {
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
            isSelected:
                _viewModel.selectedPaymentMethod == CheckoutPaymentMethod.qris,
            onTap: () =>
                _viewModel.selectPaymentMethod(CheckoutPaymentMethod.qris),
          ),
          const SizedBox(height: 8),
          PaymentOptionCard(
            title: 'Bayar di Kasir (Tunai)',
            badge: 'Loket Tiket',
            subtitle: 'Bayar langsung di loket tiket / meja kasir setelah memesan',
            isSelected:
                _viewModel.selectedPaymentMethod == CheckoutPaymentMethod.cash,
            onTap: () =>
                _viewModel.selectPaymentMethod(CheckoutPaymentMethod.cash),
          ),
          const SizedBox(height: 8),
          PaymentOptionCard(
            title: 'Transfer Bank (Virtual Account)',
            badge: 'VA 24 JAM',
            subtitle: 'BCA, Mandiri, BNI, BRI, Permata',
            isSelected: _viewModel.selectedPaymentMethod ==
                CheckoutPaymentMethod.bankTransfer,
            onTap: () => _viewModel
                .selectPaymentMethod(CheckoutPaymentMethod.bankTransfer),
          ),
        ],
      ),
    );
  }

  // --- Widget: Ringkasan Biaya ---
  Widget _buildPriceSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RINCIAN PEMBAYARAN',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          _buildPriceRow(
            '${_viewModel.ticketQuantity} x ${_viewModel.isPresaleMode && _viewModel.selectedPresaleTier != null ? _viewModel.selectedPresaleTier!.tierName : (_viewModel.selectedTicketType == 0 ? "Tiket Presale" : "Tiket Reguler")}',
            _viewModel.formatRupiah(_viewModel.totalAmount),
          ),
          _buildPriceRow('Biaya Admin Platform', 'Gratis (Rp 0)'),
          if (_discount > 0)
            _buildPriceRow(
              'Diskon Kupon (${_selectedCoupon?.code ?? ""})',
              '- ${_viewModel.formatRupiah(_discount)}',
              valueColor: const Color(0xFF047857),
            ),
          const Divider(color: AppColors.border, height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Biaya',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              Text(
                _viewModel.formatRupiah(_finalTotal),
                style: GoogleFonts.lora(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.maroon,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: AppColors.textMuted)),
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textMain)),
        ],
      ),
    );
  }

  // --- Widget: Tombol Submit ---
  Widget _buildSubmitButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _viewModel.isSubmitting
            ? null
            : () async {
                if (!(_formKey.currentState?.validate() ?? false)) return;

                final buyerName = _nameController.text.trim();
                final buyerEmail = _emailController.text.trim();
                final buyerPhone = _phoneController.text.trim();

                final ticketTypeName = _viewModel.isPresaleMode &&
                        _viewModel.selectedPresaleTier != null
                    ? _viewModel.selectedPresaleTier!.tierName
                    : (_viewModel.selectedTicketType == 0
                        ? 'Presale'
                        : 'Reguler');

                if (!mounted) return;
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.maroon),
                  ),
                );

                final result = await _viewModel.submitCheckout(
                  customerName: buyerName,
                  customerEmail: buyerEmail,
                  customerPhone: buyerPhone,
                  eventTitle: widget.eventTitle,
                  eventId: widget.eventId,
                  couponCode: _selectedCoupon?.code,
                  userId: UserSession.instance.userId,
                );

                if (!mounted) return;
                Navigator.pop(context);

                if (result != null && result['quota_exceeded'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFFDC2626),
                      content: Text(
                        result['error']?.toString() ??
                            'Kuota presale telah habis. Sistem telah mengalihkan ke tier berikutnya.',
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  );
                  return;
                }

                final chargeResult =
                    result?['charge_result'] as Map<String, dynamic>?;

                // Tangani kegagalan charge / validasi kupon
                if (chargeResult?['error'] == true) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Pembayaran Gagal'),
                      content: Text(
                        chargeResult?['message'] as String? ??
                            'Terjadi kesalahan saat memproses pembayaran tiket.',
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

                final finalOrderId =
                    result?['order_id'] as String? ?? '';
                final isQris = result?['is_qris'] as bool? ?? true;
                final isCash = result?['is_cash'] as bool? ?? false;
                final badgeText =
                    '${_viewModel.ticketQuantity} x ${_viewModel.selectedTicketType == 0 ? "Presale" : "Reguler"}';
                final paidAmount =
                    (chargeResult?['gross_amount'] as num?)?.toInt() ??
                        _finalTotal;

                final eTicketView = StrukTiketView(
                  bookingId:
                      'RBR-TKT-${DateTime.now().millisecondsSinceEpoch}',
                  eventTitle: widget.eventTitle,
                  category: widget.category,
                  eventTime: widget.time,
                  eventLocation: widget.location,
                  buyerName: buyerName,
                  buyerEmail: buyerEmail,
                  buyerPhone: buyerPhone,
                  ticketType: ticketTypeName,
                  ticketCount: _viewModel.ticketQuantity,
                  totalPrice: _viewModel.formatRupiah(paidAmount),
                  paymentMethod: _viewModel.selectedPaymentMethod.label,
                );

                if (isCash) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => eTicketView,
                    ),
                  );
                } else if (isQris) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QrisPaymentView(
                        title: 'Instruksi Pembayaran QRIS',
                        orderNumber: finalOrderId,
                        badgeText: badgeText,
                        totalAmount: _viewModel.formatRupiah(paidAmount),
                        rawAmount: paidAmount,
                        qrUrl: chargeResult?['qr_url'],
                        qrString: chargeResult?['qr_string'],
                        buttonLabel: 'CEK STATUS PEMBAYARAN',
                        nextScreen: eTicketView,
                        eventId: widget.eventId,
                        ticketQuantity: _viewModel.ticketQuantity,
                        customerName: buyerName,
                        customerEmail: buyerEmail,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VaPaymentView(
                        title: 'Instruksi Pembayaran VA',
                        orderNumber: finalOrderId,
                        badgeText: badgeText,
                        totalAmount: _viewModel.formatRupiah(paidAmount),
                        rawAmount: paidAmount,
                        vaNumber: chargeResult?['va_number'] ??
                            '5213 1845 9403 1716',
                        bankName:
                            '${(chargeResult?['bank'] ?? 'BCA').toUpperCase()} Virtual Account',
                        buttonLabel: 'CEK STATUS PEMBAYARAN',
                        nextScreen: eTicketView,
                        eventId: widget.eventId,
                        ticketQuantity: _viewModel.ticketQuantity,
                        customerName: buyerName,
                        customerEmail: buyerEmail,
                      ),
                    ),
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.maroon,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
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
