import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/services/user_session.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/core/widgets/mobile_frame.dart';
import 'package:mobile_app/core/widgets/user_avatar_widget.dart';
import 'package:mobile_app/features/pustaka/models/loan_model.dart';
import 'package:mobile_app/features/pustaka/viewmodels/pustaka_viewmodel.dart';
import 'package:mobile_app/features/pustaka/widgets/loan_card_widget.dart';

class PeminjamanBukuScreen extends StatefulWidget {
  final PustakaViewModel? viewModel;

  const PeminjamanBukuScreen({super.key, this.viewModel});

  @override
  State<PeminjamanBukuScreen> createState() => _PeminjamanBukuScreenState();
}

class _PeminjamanBukuScreenState extends State<PeminjamanBukuScreen> {
  late final PustakaViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? PustakaViewModel();
    _fetchLoans();
  }

  void _fetchLoans() {
    _viewModel.fetchLoans(UserSession.instance.token);
  }

  Future<void> _handleExtension(LoanItem loan) async {
    final success = await _viewModel.requestLoanExtension(
      loan,
      UserSession.instance.token,
    );

    if (!mounted) return;

    if (success) {
      _showMessage('Request perpanjangan dikirim. Menunggu konfirmasi admin.');
    } else if (_viewModel.errorMessage != null) {
      _showMessage(_viewModel.errorMessage!);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.plusJakartaSans(fontSize: 12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final loans = _viewModel.loans;
        final isLoading = _viewModel.isLoanLoading;

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
                'Peminjaman Buku Fisik',
                style: GoogleFonts.lora(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.maroonDark,
                ),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.textMain),
                  onPressed: _fetchLoans,
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Center(child: UserAvatarWidget(radius: 13)),
                ),
              ],
            ),
            body: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.maroon),
                  )
                : RefreshIndicator(
                    onRefresh: () async => _fetchLoans(),
                    color: AppColors.maroon,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kartu Status Pustaka Member
                          _buildMemberCard(),
                          const SizedBox(height: 20),

                          Text(
                            'DAFTAR PINJAMAN AKTIF (${loans.length})',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                              color: AppColors.greyText,
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (loans.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.menu_book_rounded,
                                      size: 48,
                                      color: AppColors.lightBorder,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Tidak ada buku yang sedang dipinjam.',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        color: AppColors.greyText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...loans.map(
                              (loan) => LoanCardWidget(
                                loan: loan,
                                onRequestExtension: () => _handleExtension(loan),
                              ),
                            ),
                          const SizedBox(height: 20),

                          // Tata Tertib Peminjaman
                          _buildRulesCard(),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildMemberCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B1B14), Color(0xFF8B261D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.maroon.withValues(alpha: 0.25),
            blurRadius: 12,
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
              Text(
                'KARTU PUSTAKA DIGITAL',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const Icon(Icons.nfc_rounded, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            UserSession.instance.name,
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            UserSession.instance.email,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID: RBR-${DateTime.now().year % 100}9402',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Anggota Aktif',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRulesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.maroon, size: 18),
              const SizedBox(width: 8),
              Text(
                'Ketentuan Peminjaman Pustaka',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildRuleItem('1. Maksimal peminjaman 2 buku fisik sekaligus per anggota.'),
          _buildRuleItem('2. Masa pinjam 14 hari kalender sejak tanggal pengambilan di rak.'),
          _buildRuleItem('3. Pengajuan perpanjangan maksimal 1 kali (7 hari tambahan).'),
          _buildRuleItem('4. Keterlambatan pengembalian dikenakan denda literasi Rp 1.000/hari.'),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          color: AppColors.greyText,
          height: 1.4,
        ),
      ),
    );
  }
}
