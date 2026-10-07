import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/payment_option_card.dart';
import '../widgets/price_summary_card.dart';

class PesananMejaView extends StatefulWidget {
  const PesananMejaView({super.key});

  @override
  State<PesananMejaView> createState() => _PesananMejaViewState();
}

class _PesananMejaViewState extends State<PesananMejaView> {
  int _selectedPaymentMethod = 0; // 0: QRIS, 1: Tunai Kasir, 2: Transfer Bank

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgCanvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
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

            // Rincian Pembayaran (menggunakan Widget PriceSummaryCard)
            const PriceSummaryCard(
              subtotal: 'Rp 35.000',
              taxFee: 'Rp 0',
              discount: '-Rp 0',
              totalPrice: 'Rp 35.000',
            ),
            const SizedBox(height: 16),

            // Metode Pembayaran (menggunakan Widget PaymentOptionCard)
            _buildPaymentSection(),
            const SizedBox(height: 24),

            // Tombol Konfirmasi Bayar
            _buildConfirmButton(),
            const SizedBox(height: 20),
          ],
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
            child: const Icon(Icons.coffee_rounded, color: AppColors.maroon, size: 20),
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
                  '#ORD-9042',
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
                  'Meja No. 04',
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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.bgCanvas,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '2 Menu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greyText,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'Ubah',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.maroon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildOrderItem('1x Kopi Susu Creamy', 'Rp 18.000', 'Less Sugar • Less Ice'),
          const Divider(height: 20, color: AppColors.lightBorder),
          _buildOrderItem('1x Americano Signature', 'Rp 17.000', 'Single Origin • Hot'),
        ],
      ),
    );
  }

  Widget _buildOrderItem(String name, String price, String note) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
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
                  const Icon(Icons.confirmation_number_outlined, color: AppColors.maroon, size: 18),
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
                'Tersedia 1 kupon',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.goldLight),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'KUPONBUDAYA',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.check_circle, color: AppColors.maroon, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Diterapkan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.maroon,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
                  const Icon(Icons.payment_rounded, color: AppColors.maroon, size: 18),
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
            isSelected: _selectedPaymentMethod == 0,
            onTap: () => setState(() => _selectedPaymentMethod = 0),
          ),
          const SizedBox(height: 8),
          PaymentOptionCard(
            title: 'Bayar di Kasir (Tunai)',
            badge: 'Kasir Pendopo',
            subtitle: 'Bayar langsung di meja kasir setelah memesan',
            isSelected: _selectedPaymentMethod == 1,
            onTap: () => setState(() => _selectedPaymentMethod = 1),
          ),
          const SizedBox(height: 8),
          PaymentOptionCard(
            title: 'Transfer Bank (Virtual Account)',
            badge: 'VA 24 JAM',
            subtitle: 'BCA, Mandiri, BNI, BRI, Permata',
            isSelected: _selectedPaymentMethod == 2,
            onTap: () => setState(() => _selectedPaymentMethod = 2),
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
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pesanan berhasil dibuat!')),
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
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}