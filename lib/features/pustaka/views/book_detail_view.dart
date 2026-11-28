import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/features/pustaka/models/book_model.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/core/services/user_session.dart';
import 'package:mobile_app/features/pustaka/views/facsimile_webview_view.dart';
import 'package:mobile_app/features/pustaka/viewmodels/pustaka_viewmodel.dart';
import 'package:mobile_app/features/pustaka/views/koleksi_favorit_screen.dart';
import 'package:mobile_app/features/pustaka/views/peminjaman_buku_screen.dart';

class BookDetailView extends StatefulWidget {
  final Book book;
  final String? coverImage;

  BookDetailView({
    super.key,
    Book? book,
    this.coverImage,
  }) : book = book ?? Book.dummyBooks.first;

  @override
  State<BookDetailView> createState() => _BookDetailViewState();
}

class _BookDetailViewState extends State<BookDetailView> {
  int _selectedTabIndex = 0;
  bool _isBookmarked = false;
  late Book _currentBook;
  final PustakaViewModel _pustakaViewModel = PustakaViewModel();

  @override
  void initState() {
    super.initState();
    _currentBook = widget.book;
    if (_currentBook.status.isEmpty) {
      _currentBook = _currentBook.copyWith(status: 'TERSEDIA');
    }
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final saved = await _pustakaViewModel.isBookFavorite(book.title);
    if (mounted) {
      setState(() {
        _isBookmarked = saved;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    final nowSaved = await _pustakaViewModel.toggleFavorite(book);
    if (!mounted) return;
    setState(() {
      _isBookmarked = nowSaved;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              nowSaved ? Icons.bookmark_added_rounded : Icons.bookmark_remove_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                nowSaved
                    ? 'Buku "${book.title}" berhasil disimpan ke Koleksi Favorit.'
                    : 'Buku "${book.title}" dihapus dari Koleksi Favorit.',
                style: GoogleFonts.plusJakartaSans(fontSize: 12),
              ),
            ),
          ],
        ),
        action: nowSaved
            ? SnackBarAction(
                label: 'Lihat Koleksi',
                textColor: const Color(0xFFFBC02D),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KoleksiFavoritScreen(viewModel: _pustakaViewModel),
                    ),
                  );
                },
              )
            : null,
        backgroundColor: AppColors.maroonDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Book get book => _currentBook;

  String get coverImagePath {
    if (widget.coverImage != null && widget.coverImage!.trim().isNotEmpty) {
      return widget.coverImage!.trim();
    }
    if (book.coverImage.trim().isNotEmpty) {
      return book.coverImage.trim();
    }
    final slug = book.title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return 'assets/images/$slug.jpg';
  }

  bool get isAvailable => book.isAvailable;

  Color get statusTextColor =>
      isAvailable ? const Color(0xFF2E7D32) : const Color(0xFFB45309);

  Color get statusBgColor =>
      isAvailable ? const Color(0xFFE8F5E9) : const Color(0xFFFEF3C7);

  Color get coverBaseColor {
    final titleLower = book.title.toLowerCase();
    if (titleLower.contains('jibril')) {
      return const Color(0xFF4A1822); // Maroon Klasik
    } else if (titleLower.contains('anjing') || titleLower.contains('lek')) {
      return const Color(0xFF1E3A5F); // Deep Navy
    } else if (titleLower.contains('peri')) {
      return const Color(0xFF14532D); // Deep Forest Green
    } else if (titleLower.contains('lipstik') || titleLower.contains('tejo')) {
      return const Color(0xFF581C87); // Deep Purple
    }
    return const Color(0xFF332A24);
  }

  String _formatIndonesianDate(DateTime date) {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dayName = days[date.weekday % 7];
    final monthName = months[date.month - 1];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  void _showBorrowFormModal() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: UserSession.instance.name);
    final emailController = TextEditingController(text: UserSession.instance.email);
    final phoneController = TextEditingController();
    final identityController = TextEditingController();
    final notesController = TextEditingController();
    int selectedDurationDays = 7;
    bool agreeTerms = false;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          final dueDate = DateTime.now().add(Duration(days: selectedDurationDays));
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(modalContext).size.height * 0.90,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle & Header
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.maroon.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.assignment_ind_rounded, color: AppColors.maroon, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Form Pengajuan Peminjaman',
                              style: GoogleFonts.lora(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                            Text(
                              'Lengkapi data diri sebelum meminjam buku fisik',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.greyText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20, color: Colors.grey),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Form Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 16,
                      bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kartu Ringkasan Buku
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF7F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.lightBorder),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: coverBaseColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.book_rounded, color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        style: GoogleFonts.lora(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.maroonDark,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${book.author} • Rak: ${book.shelfLocation}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: AppColors.greyText,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: statusBgColor,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isAvailable ? 'Tersedia di Rak' : 'Sedang Dipinjam (Reservasi)',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: statusTextColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Section: Data Diri Peminjam
                          Text(
                            'Data Diri Peminjam',
                            style: GoogleFonts.lora(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Nama Lengkap
                          _buildFormField(
                            controller: nameController,
                            label: 'Nama Lengkap Peminjam *',
                            hint: 'Masukkan nama sesuai kartu identitas',
                            icon: Icons.person_outline_rounded,
                            validator: (val) => (val == null || val.trim().isEmpty)
                                ? 'Nama lengkap wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          // Nomor Identitas
                          _buildFormField(
                            controller: identityController,
                            label: 'Nomor Identitas (NIK / KTA / NIM) *',
                            hint: 'Contoh: 3271xxxxxxxxxxxx atau KTA-1029',
                            icon: Icons.badge_outlined,
                            validator: (val) => (val == null || val.trim().isEmpty)
                                ? 'Nomor identitas wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          // Nomor WhatsApp / HP
                          _buildFormField(
                            controller: phoneController,
                            label: 'Nomor WhatsApp / HP Aktif *',
                            hint: 'Contoh: 081234567890',
                            icon: Icons.phone_android_rounded,
                            keyboardType: TextInputType.phone,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Nomor WhatsApp/HP wajib diisi';
                              }
                              if (val.trim().length < 8) {
                                return 'Nomor HP tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Email
                          _buildFormField(
                            controller: emailController,
                            label: 'Alamat Email *',
                            hint: 'Contoh: ratna@budaya.id',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Alamat email wajib diisi';
                              }
                              if (!val.contains('@') || !val.contains('.')) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Section: Durasi Peminjaman
                          Text(
                            'Durasi Peminjaman',
                            style: GoogleFonts.lora(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildDurationChip(
                                label: '3 Hari',
                                days: 3,
                                selectedDays: selectedDurationDays,
                                onSelected: () => setModalState(() => selectedDurationDays = 3),
                              ),
                              const SizedBox(width: 8),
                              _buildDurationChip(
                                label: '7 Hari (Standar)',
                                days: 7,
                                selectedDays: selectedDurationDays,
                                onSelected: () => setModalState(() => selectedDurationDays = 7),
                              ),
                              const SizedBox(width: 8),
                              _buildDurationChip(
                                label: '14 Hari (Riset)',
                                days: 14,
                                selectedDays: selectedDurationDays,
                                onSelected: () => setModalState(() => selectedDurationDays = 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF7F2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2DCD2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.event_available_rounded, size: 18, color: AppColors.maroon),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Estimasi Pengembalian: ${_formatIndonesianDate(dueDate)}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Catatan Tambahan (Opsional)
                          _buildFormField(
                            controller: notesController,
                            label: 'Catatan Riset / Kebutuhan (Opsional)',
                            hint: 'Misal: Untuk bahan telaah karya sastra modern...',
                            icon: Icons.notes_rounded,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 14),

                          // Checkbox Persetujuan
                          Theme(
                            data: ThemeData(unselectedWidgetColor: Colors.grey.shade400),
                            child: CheckboxListTile(
                              value: agreeTerms,
                              contentPadding: EdgeInsets.zero,
                              activeColor: AppColors.maroon,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(
                                'Saya menyatakan data diri di atas benar, bersedia mematuhi tata tertib Pustaka RBR, dan bertanggung jawab menjaga fisik buku.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.darkText,
                                ),
                              ),
                              onChanged: (val) {
                                setModalState(() {
                                  agreeTerms = val ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }
                                      if (!agreeTerms) {
                                        ScaffoldMessenger.of(modalContext).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Harap centang persetujuan tata tertib peminjaman.',
                                              style: GoogleFonts.plusJakartaSans(fontSize: 12),
                                            ),
                                            backgroundColor: Colors.red.shade700,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        );
                                        return;
                                      }

                                      setModalState(() => isSubmitting = true);
                                      final success = await _pustakaViewModel.requestLoan(
                                        book: book,
                                        durationDays: selectedDurationDays,
                                        memberName: nameController.text.trim(),
                                        memberEmail: emailController.text.trim(),
                                        memberPhone: phoneController.text.trim(),
                                        identityNumber: identityController.text.trim(),
                                        notes: notesController.text.trim(),
                                        token: UserSession.instance.token,
                                      );
                                      setModalState(() => isSubmitting = false);

                                      if (!mounted) return;
                                      if (success) {
                                        setState(() {
                                          _currentBook = _currentBook.copyWith(status: 'DIPINJAM');
                                        });
                                        if (_currentBook.id.isNotEmpty) {
                                          _pustakaViewModel.updateBookStatus(_currentBook.id, 'DIPINJAM');
                                        }
                                        _pustakaViewModel.updateBookStatus(_currentBook.title, 'DIPINJAM');
                                        _pustakaViewModel.fetchBooks();

                                        if (modalContext.mounted) {
                                          Navigator.pop(modalContext);
                                        }
                                        _showBorrowSuccessDialog(
                                          memberName: nameController.text.trim(),
                                          dueDate: dueDate,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              _pustakaViewModel.errorMessage ?? 'Pengajuan peminjaman gagal dikirim.',
                                              style: GoogleFonts.plusJakartaSans(fontSize: 12),
                                            ),
                                            backgroundColor: Colors.red.shade700,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.maroon,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(
                                      isAvailable
                                          ? 'Konfirmasi & Ajukan Peminjaman'
                                          : 'Konfirmasi Reservasi Antrean',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.darkText),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade400),
            prefixIcon: Icon(icon, size: 20, color: AppColors.maroon),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFFAF7F2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2DCD2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2DCD2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.maroon, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationChip({
    required String label,
    required int days,
    required int selectedDays,
    required VoidCallback onSelected,
  }) {
    final isSelected = days == selectedDays;
    return Expanded(
      child: GestureDetector(
        onTap: onSelected,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.maroon : const Color(0xFFFAF7F2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.maroon : const Color(0xFFE2DCD2),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.darkText,
            ),
          ),
        ),
      ),
    );
  }

  void _showBorrowSuccessDialog({
    required String memberName,
    required DateTime dueDate,
  }) {
    final loanCode = 'RBR-PINJAM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32),
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pengajuan Peminjaman Berhasil!',
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.maroonDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Data diri dan permohonan Anda telah tercatat di Pustaka Rumah Budaya Ratna.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.greyText,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Kode Peminjaman', loanCode, isBold: true),
                    const Divider(height: 14),
                    _buildReceiptRow('Buku', book.title),
                    const SizedBox(height: 6),
                    _buildReceiptRow('Peminjam', memberName),
                    const SizedBox(height: 6),
                    _buildReceiptRow('Batas Pengembalian', _formatIndonesianDate(dueDate)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.maroon),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Tunjukkan kode peminjaman atau kartu identitas saat mengambil fisik buku di meja kurator.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PeminjamanBukuScreen(viewModel: _pustakaViewModel),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_long_rounded, size: 18),
                  label: Text(
                    'Lihat Status Peminjaman',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.maroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Kembali ke Halaman Buku',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greyText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppColors.greyText,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? AppColors.maroon : AppColors.darkText,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showFacsimilePreview() async {
    String? digitalUrl = book.digitalUrl?.trim();

    // Jika digitalUrl belum terisi pada instance lokal, sinkronisasi dari backend buku
    if (digitalUrl == null || digitalUrl.isEmpty) {
      if (book.id.isNotEmpty) {
        try {
          final res = await http
              .get(Uri.parse('${ApiConfig.booksUrl}/${book.id}'))
              .timeout(const Duration(seconds: 4));
          if (res.statusCode == 200) {
            final data = jsonDecode(res.body);
            if (data is Map<String, dynamic>) {
              final fetched = (data['digital_url'] ?? data['digitalUrl'])?.toString().trim();
              if (fetched != null && fetched.isNotEmpty) {
                digitalUrl = fetched;
              }
            }
          }
        } catch (e) {
          debugPrint('[BookDetail] Cek digitalUrl backend notice: $e');
        }
      }
    }

    if (!mounted) return;

    if (digitalUrl != null && digitalUrl.isNotEmpty) {
      // Tampilkan pilihan mode tampilan: In-App E-Faksimili Viewer atau Browser / PDF Eksternal
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (modalCtx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBC02D).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_stories, color: Color(0xFF3E2723), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pratinjau E-Faksimili Digital',
                            style: GoogleFonts.lora(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          Text(
                            book.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.greyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE2DCD2)),
                  ),
                  leading: const Icon(Icons.chrome_reader_mode_rounded, color: AppColors.maroon, size: 26),
                  title: Text(
                    'Buka di In-App E-Faksimili Viewer',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                  subtitle: Text(
                    'Baca dokumen PDF/E-Faksimili langsung di dalam aplikasi',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.greyText),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.maroon),
                  onTap: () {
                    Navigator.pop(modalCtx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FacsimileWebViewView(
                          title: book.title,
                          url: digitalUrl!,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE2DCD2)),
                  ),
                  leading: const Icon(Icons.open_in_browser_rounded, color: Color(0xFFB45309), size: 26),
                  title: Text(
                    'Buka di Browser / PDF Eksternal',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                  subtitle: Text(
                    'Buka tautan file naskah pada browser atau aplikasi pembaca PDF eksternal',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.greyText),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.maroon),
                  onTap: () async {
                    Navigator.pop(modalCtx);
                    final uri = Uri.parse(digitalUrl!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Tidak dapat membuka URL: $digitalUrl',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12),
                            ),
                            backgroundColor: Colors.red.shade700,
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Versi digital e-faksimili belum tersedia untuk buku ini.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.maroon,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0), // Latar cream lembut
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480), // Menjaga proporsi Mobile
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              // 1. Header Navigation Bar (Di dalam mobile frame 480px)
              _buildHeaderNavigation(),

              // 2. Konten Scrollable
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Section (Sampul & Status Badge)
                      _buildHeroSection(),

                      // Informasi Judul, Penulis, Spesifikasi & Aksi
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBookTitleAndAuthor(),
                            const SizedBox(height: 18),

                            // Grid Spesifikasi Buku (4 Kolom)
                            _buildSpecificationGrid(),
                            const SizedBox(height: 20),

                            // Tombol Aksi Utama & Sekunder
                            _buildActionButtons(),
                            const SizedBox(height: 24),

                            // Tab Bar Segmented Control
                            _buildTabBar(),
                            const SizedBox(height: 16),

                            // Konten Tab Dinamis (Sinopsis / Preservasi / Riwayat)
                            _buildTabContent(),
                            const SizedBox(height: 28),

                            // Section "Karya Terkait"
                            _buildRelatedSection(),
                            const SizedBox(height: 28),

                            // Footer Banner
                            _buildFooterBanner(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Header Navigation Bar (Mobile App Bar) ---
  Widget _buildHeaderNavigation() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 16,
        bottom: 8,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.maroon,
              size: 20,
            ),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          Expanded(
            child: Text(
              'Detail Buku',
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: _isBookmarked ? AppColors.maroon : AppColors.darkText,
              size: 22,
            ),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.darkText,
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tautan katalog ${book.title} disalin ke clipboard',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12),
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.maroon,
                ),
              );
            },
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.maroon.withValues(alpha: 0.12),
            child: Text(
              book.author.isNotEmpty ? book.author[0] : 'R',
              style: GoogleFonts.lora(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.maroon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Hero Section (Sampul & Status Badge) ---
  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F5F0), // Latar krem sangat muda / abu-abu lembut
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Baris Atas Sampul: Badge Status (Kiri) & Badge Lokasi (Kanan)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge Status Dinamis (Tersedia / Dipinjam)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusTextColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusTextColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      book.status,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Badge Lokasi Rak Dinamis
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shelves, size: 14, color: AppColors.maroon),
                    const SizedBox(width: 5),
                    Text(
                      book.shelfLocation,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Gambar Sampul Buku: Terpusat di tengah dengan bayangan halus & sudut rounded
          Center(
            child: Container(
              width: 170,
              height: 245,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: coverBaseColor.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: coverImagePath.startsWith('http')
                    ? Image.network(
                        coverImagePath,
                        width: 170,
                        height: 245,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildBookCoverArt(),
                      )
                    : Image.asset(
                        coverImagePath,
                        width: 170,
                        height: 245,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildBookCoverArt(),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Desain visual sampul buku dinamis berdasarkan parameter book
  Widget _buildBookCoverArt() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            coverBaseColor.withValues(alpha: 0.85),
            coverBaseColor,
            Colors.black.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Efek lipatan punggung buku di sisi kiri
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 12,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.white.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),

          // Border ornamen klasik
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFC59B27).withValues(alpha: 0.4),
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Detail teks pada sampul
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      book.category.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 7.5,
                        letterSpacing: 1.2,
                        color: const Color(0xFFEAD8AD),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 24,
                      height: 1,
                      color: const Color(0xFFC59B27),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      book.author.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lora(
                        fontSize: 11,
                        letterSpacing: 1.6,
                        color: const Color(0xFFF5EBE6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      book.title.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lora(
                        fontSize: 16,
                        height: 1.15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFE082),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Icon(
                      Icons.auto_stories,
                      size: 22,
                      color: Color(0xFFC59B27),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'EDISI KOLEKSI PUSTAKA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 7,
                        letterSpacing: 1.2,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${book.year} • RUMAH BUDAYA RATNA',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 7.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: const Color(0xFFC59B27),
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

  // --- Informasi Judul & Penulis Dinamis ---
  Widget _buildBookTitleAndAuthor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtitle: Kategori Buku
        Text(
          book.category.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
            color: const Color(0xFFB48324), // Cokelat / gold
          ),
        ),
        const SizedBox(height: 6),

        // Judul Utama Dinamis
        Text(
          book.title,
          style: GoogleFonts.lora(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),

        // Penulis Dinamis + Badge Centang Emas/Verified
        Row(
          children: [
            Text(
              book.author,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.maroon,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.verified,
              size: 16,
              color: Color(0xFFC59B27), // Emas
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Deskripsi Penulis
        Text(
          'Sastrawan & Budayawan Terkemuka Nusantara',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            color: AppColors.greyText,
          ),
        ),
        const SizedBox(height: 10),

        // Rating & Review Dinamis
        Row(
          children: [
            const Icon(
              Icons.star_rounded,
              color: Color(0xFFFFB300),
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              book.rating.toStringAsFixed(1),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '•',
              style: TextStyle(color: Colors.grey.shade400),
            ),
            const SizedBox(width: 8),
            Text(
              '${book.reviewCount} telaah kuratorial',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Grid Spesifikasi Buku Dinamis (4 Kolom) ---
  Widget _buildSpecificationGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F0), // Latar abu-abu / krem muda halus
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEBE6DC)),
      ),
      child: Row(
        children: [
          // Kolom 1: Tahun (book.year), Sub-label (Cet. 1)
          _buildSpecColumn(
            book.year,
            'Cet. 1',
          ),
          _buildVerticalDivider(),

          // Kolom 2: Tebal (book.pageCount), Sub-label (Halaman)
          _buildSpecColumn(
            book.pageCount,
            'Halaman',
          ),
          _buildVerticalDivider(),

          // Kolom 3: Bahasa (book.language), Sub-label (Nusantara)
          _buildSpecColumn(
            book.language,
            'Melayu/IDN',
          ),
          _buildVerticalDivider(),

          // Kolom 4: Kondisi (book.condition), Sub-label (Terawat - Teks Hijau)
          _buildSpecColumn(
            book.condition.split(' ').first,
            book.condition.contains(' ')
                ? book.condition.substring(book.condition.indexOf(' ') + 1)
                : 'Terawat',
            subLabelColor: const Color(0xFF2E7D32),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecColumn(String value, String subLabel, {Color? subLabelColor}) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subLabel,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: subLabelColor != null ? FontWeight.bold : FontWeight.w500,
              color: subLabelColor ?? AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 28,
      color: const Color(0xFFE2DCD2),
    );
  }

  // --- Tombol Aksi Utama & Sekunder ---
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Tombol Utama: Ajukan Peminjaman Fisik (Aktif hanya jika status TERSEDIA)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: isAvailable ? _showBorrowFormModal : null,
            icon: Icon(
              isAvailable ? Icons.assignment_ind_rounded : Icons.block_rounded,
              size: 20,
            ),
            label: Text(
              isAvailable ? 'Ajukan Peminjaman Fisik' : 'Buku Sedang Dipinjam',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isAvailable ? AppColors.maroon : Colors.grey.shade400,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Row Tombol Sekunder
        Row(
          children: [
            // Kiri: Simpan Koleksi (Tersimpan ke Menu Koleksi Favorit)
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: _toggleBookmark,
                  icon: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    size: 18,
                    color: AppColors.maroon,
                  ),
                  label: Text(
                    _isBookmarked ? 'Tersimpan' : 'Simpan Koleksi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.maroon,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _isBookmarked ? const Color(0xFFFBE9E7) : const Color(0xFFF5EBE6),
                    side: BorderSide(
                      color: _isBookmarked ? AppColors.maroon.withValues(alpha: 0.4) : const Color(0xFFEAD8D0),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Kanan: Pratinjau E-Faksimili (In-App PDF Viewer / Link Eksternal)
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _showFacsimilePreview,
                  icon: const Icon(Icons.auto_stories, size: 18),
                  label: Text(
                    'Pratinjau E-Faksimili',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3E2723),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFBC02D), // Kuning Emas
                    foregroundColor: const Color(0xFF3E2723),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Tab Bar Segmented Control ---
  Widget _buildTabBar() {
    final tabs = ['Sinopsis', 'Preservasi & Rak', 'Riwayat Baca'];

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1.5),
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppColors.maroon : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.maroon : AppColors.greyText,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- Konten Tab Dinamis ---
  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildSynopsisCard();
      case 1:
        return _buildPreservationTab();
      case 2:
        return _buildReadingHistoryTab();
      default:
        return _buildSynopsisCard();
    }
  }

  // Tab 1: Konten Sinopsis Dinamis (Card Putih)
  Widget _buildSynopsisCard() {
    final defaultTags = [
      '#${book.category.replaceAll(' ', '')}',
      '#Arsip${book.year}',
      '#RumahBudayaRatna',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gema Moral & Pergolakan Batin',
            style: GoogleFonts.lora(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 10),

          // Teks Sinopsis dari book.synopsis
          Text(
            book.synopsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              height: 1.6,
              color: const Color(0xFF4A4441),
            ),
          ),
          const SizedBox(height: 14),

          // Tags / Hashtags (Pill chips)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: defaultTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EBE6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8DDD7)),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.maroon,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Tab 2: Preservasi & Rak
  Widget _buildPreservationTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.maroon, size: 20),
              const SizedBox(width: 8),
              Text(
                'Protokol Konservasi Arsip',
                style: GoogleFonts.lora(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPreservationRow('Kondisi Fisik', book.condition),
          _buildPreservationRow('Lokasi Rak', '${book.shelfLocation} (Pustaka Lantai 2)'),
          _buildPreservationRow('Suhu Ruang Rak', '20°C ± 2°C (Ruang Khusus RBR)'),
          _buildPreservationRow('Kelembapan', '50% RH (Stabil Terpantau)'),
          _buildPreservationRow('Kode Registrasi', 'RBR-ARS-${book.year}-${book.id.padLeft(4, '0')}'),
        ],
      ),
    );
  }

  Widget _buildPreservationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: AppColors.greyText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab 3: Riwayat Baca
  Widget _buildReadingHistoryTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catatan Telaah & Pengkaji',
            style: GoogleFonts.lora(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Naskah ini telah ditelaah oleh ${book.reviewCount} kurator & peneliti drama/sastra nusantara. Peminjaman fisik tercatat aktif untuk kajian pustaka berlisensi Rumah Budaya Ratna.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.5,
              color: AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }

  // --- Section "Karya Terkait" ---
  Widget _buildRelatedSection() {
    final otherBooks =
        Book.dummyBooks.where((b) => b.id != book.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Koleksi Pustaka Lainnya',
                    style: GoogleFonts.lora(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Koleksi naskah, sastra, & sejarah nusantara',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Row(
                  children: [
                    Text(
                      'Semua',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.maroon,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.maroon,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Horizontal ListView Card Buku Terkait
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: otherBooks.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final relatedBook = otherBooks[index];
              return _buildRelatedBookCard(relatedBook);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedBookCard(Book item) {
    final available = item.status.toLowerCase().contains('tersedia');
    final sColor = available ? const Color(0xFF2E7D32) : const Color(0xFFB45309);
    final sBg = available ? const Color(0xFFE8F5E9) : const Color(0xFFFEF3C7);

    final relatedImage = item.coverImage.trim().isNotEmpty
        ? item.coverImage.trim()
        : 'assets/images/${item.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '')}.jpg';

    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailView(
              book: item,
              coverImage: relatedImage,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 128,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Thumbnail dengan Badge Status
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                    child: (relatedImage.startsWith('http://') || relatedImage.startsWith('https://'))
                        ? Image.network(
                            relatedImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: AppColors.maroonDark,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.menu_book_outlined,
                                        size: 26,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.title,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.lora(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Image.asset(
                            relatedImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.maroonDark,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.menu_book_outlined,
                              size: 26,
                              color: Colors.white70,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lora(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ),

                  // Badge Status
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: sBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        available ? 'Tersedia' : 'Dipinjam',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: sColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Teks Judul & Tahun
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tahun ${item.year}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      color: AppColors.greyText,
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

  // --- Footer Banner ---
  Widget _buildFooterBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F0), // Latar abu-abu lembut / krem
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEBE6DC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ikon Rumah Budaya (Kuning)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFBC02D).withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance,
              color: Color(0xFFB48324), // Emas / Kuning tua
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Teks & Deskripsi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rumah Budaya Ratna',
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.maroon,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Penyimpanan resmi naskah warisan sastra & drama nusantara.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    height: 1.4,
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
}
