import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/mobile_frame.dart';
import 'struk_tiket_view.dart';

class BookingCheckoutView extends StatefulWidget {
  final String eventTitle;
  final String category;
  final String time;
  final String location;
  final String basePath;
  final String basePrice;

  const BookingCheckoutView({
    super.key,
    this.eventTitle = 'Napak Tanah Jilid II Book Club & Pot Luck',
    this.category = 'Lokakarya Seni',
    this.time = '10 Sep • 15:30 WIB',
    this.location = 'Ruang Komunal Lt. 2, Rumah Budaya Ratna',
    this.basePath = '',
    this.basePrice = 'Rp 25.000',
  });

  @override
  State<BookingCheckoutView> createState() => _BookingCheckoutViewState();
}

class _BookingCheckoutViewState extends State<BookingCheckoutView> {
  final _formKey = GlobalKey<FormState>();

  // State Pilihan Tiket (0 = Presale, 1 = Reguler)
  int _selectedTicketType = 0;
  int _ticketQuantity = 1;

  final int _presalePrice = 25000;
  final int _regulerPrice = 35000;

  // Controllers Form Informasi Pemesan
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Budi Santoso');
    _emailController = TextEditingController(text: 'budi.santoso@gmail.com');
    _phoneController = TextEditingController(text: '0812-3456-7890');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  int get _currentUnitPrice => _selectedTicketType == 0 ? _presalePrice : _regulerPrice;
  int get _totalAmount => _currentUnitPrice * _ticketQuantity;

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
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
            'Detail Lokakarya / Checkout',
            style: GoogleFonts.lora(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline_rounded, color: AppColors.textMain, size: 20),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Informasi Event Card
                _buildEventInfoCard(),
                const SizedBox(height: 16),

                // 2. Pilihan Jenis Tiket
                _buildTicketTypeSection(),
                const SizedBox(height: 16),

                // 3. Pengatur Jumlah Tiket (+ / -)
                _buildTicketQuantitySection(),
                const SizedBox(height: 16),

                // 4. Form Informasi Pemesan
                _buildBookerFormSection(),
                const SizedBox(height: 16),

                // 5. Ringkasan Biaya
                _buildPriceSummaryCard(),
                const SizedBox(height: 20),

                // 6. Tombol Lanjut ke Pembayaran
                _buildSubmitButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget: Informasi Event ---
  Widget _buildEventInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
                  const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
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
              const Icon(Icons.access_time_rounded, size: 13, color: AppColors.maroon),
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
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.maroon),
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
    );
  }

  // --- Widget: Pilihan Jenis Tiket ---
  Widget _buildTicketTypeSection() {
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
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pilihan 1: Presale Ticket
          _buildTicketTypeCard(
            index: 0,
            title: 'Tiket Presale (Early Bird)',
            badge: 'HEMAT 28% • Kuota Terbatas',
            badgeColor: const Color(0xFF047857),
            badgeBgColor: const Color(0xFF10B981).withValues(alpha: 0.12),
            price: _formatRupiah(_presalePrice),
            description: 'Akses penuh lokakarya, booklet materi, dan free kopi seduh.',
          ),
          const SizedBox(height: 10),

          // Pilihan 2: Reguler Ticket
          _buildTicketTypeCard(
            index: 1,
            title: 'Tiket Reguler (On The Spot)',
            badge: 'TERSEDIA',
            badgeColor: AppColors.maroon,
            badgeBgColor: AppColors.maroon.withValues(alpha: 0.08),
            price: _formatRupiah(_regulerPrice),
            description: 'Akses lokakarya dan sertifikat kehadiran digital.',
          ),
        ],
      ),
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
  }) {
    final isSelected = _selectedTicketType == index;
    return InkWell(
      onTap: () => setState(() => _selectedTicketType = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.maroon.withValues(alpha: 0.03) : AppColors.bgCanvas,
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
                    isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                    color: isSelected ? AppColors.maroon : AppColors.textMuted,
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
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
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
  );
}

  // --- Widget: Pengatur Jumlah Tiket (+ dan -) ---
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
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          // Stepper + / -
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCanvas,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 16, color: AppColors.maroon),
                  onPressed: _ticketQuantity > 1
                      ? () => setState(() => _ticketQuantity--)
                      : null,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 32),
                  alignment: Alignment.center,
                  child: Text(
                    '$_ticketQuantity',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 16, color: AppColors.maroon),
                  onPressed: _ticketQuantity < 5
                      ? () => setState(() => _ticketQuantity++)
                      : null,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget: Form Informasi Pemesan ---
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
              const Icon(Icons.badge_outlined, color: AppColors.maroon, size: 17),
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
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),

          // Nama Lengkap
          _buildFormField(
            controller: _nameController,
            label: 'Nama Lengkap',
            icon: Icons.person_outline_rounded,
            hint: 'Contoh: Budi Santoso',
            validator: (value) => value == null || value.trim().isEmpty ? 'Nama wajib diisi' : null,
          ),
          const SizedBox(height: 12),

          // Email Aktif
          _buildFormField(
            controller: _emailController,
            label: 'Email Aktif (Pengiriman E-Tiket)',
            icon: Icons.mail_outline_rounded,
            hint: 'Contoh: budi@gmail.com',
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value == null || !value.contains('@') ? 'Email tidak valid' : null,
          ),
          const SizedBox(height: 12),

          // No. WhatsApp
          _buildFormField(
            controller: _phoneController,
            label: 'No. WhatsApp (Notifikasi Booking)',
            icon: Icons.phone_android_rounded,
            hint: 'Contoh: 081234567890',
            keyboardType: TextInputType.phone,
            validator: (value) => value == null || value.trim().length < 8 ? 'Nomor HP tidak valid' : null,
          ),
        ],
      ),
    );
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
              borderSide: const BorderSide(color: AppColors.maroon, width: 1.5),
            ),
          ),
        ),
      ],
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
            '$_ticketQuantity x ${_selectedTicketType == 0 ? "Tiket Presale" : "Tiket Reguler"}',
            _formatRupiah(_totalAmount),
          ),
          _buildPriceRow('Biaya Admin Platform', 'Gratis (Rp 0)'),
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
                _formatRupiah(_totalAmount),
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

  Widget _buildPriceRow(String label, String value) {
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
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget: Tombol Lanjut ke Pembayaran ---
  Widget _buildSubmitButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StrukTiketView(
                  bookingId: '#TKT-9042',
                  eventTitle: widget.eventTitle,
                  category: widget.category,
                  eventTime: widget.time,
                  eventLocation: widget.location,
                  buyerName: _nameController.text.trim(),
                  buyerEmail: _emailController.text.trim(),
                  buyerPhone: _phoneController.text.trim(),
                  ticketType: _selectedTicketType == 0 ? 'Presale' : 'Reguler',
                  ticketCount: _ticketQuantity,
                  totalPrice: _formatRupiah(_totalAmount),
                ),
              ),
            );
          }
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
              'LANJUT KE PEMBAYARAN',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
