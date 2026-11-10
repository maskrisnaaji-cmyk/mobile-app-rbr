import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/user_session.dart';
import '../widgets/user_avatar_widget.dart';
import '../theme/colors.dart';
import '../widgets/mobile_frame.dart';

class _LoanItem {
  final String? id;
  final String bookCode;
  final String title;
  final String author;
  final String rackLocation;
  final DateTime borrowDate;
  final DateTime dueDate;
  final String status;
  final String extensionStatus;

  const _LoanItem({
    this.id,
    required this.bookCode,
    required this.title,
    required this.author,
    required this.rackLocation,
    required this.borrowDate,
    required this.dueDate,
    this.status = 'active',
    this.extensionStatus = 'none',
  });

  factory _LoanItem.fromJson(Map<String, dynamic> json) {
    return _LoanItem(
      id: json['id']?.toString(),
      bookCode: json['book_code']?.toString() ?? '-',
      title: json['title']?.toString() ?? 'Buku tanpa judul',
      author: json['author']?.toString() ?? 'Penulis tidak diketahui',
      rackLocation: json['rack_location']?.toString() ?? 'Belum ditentukan',
      borrowDate: DateTime.parse(json['borrow_date'].toString()),
      dueDate: DateTime.parse(json['due_date'].toString()),
      status: json['status']?.toString() ?? 'active',
      extensionStatus: json['extension_status']?.toString() ?? 'none',
    );
  }

  String get statusLabel {
    switch (status) {
      case 'overdue':
        return 'TERLAMBAT';
      case 'returned':
        return 'DIKEMBALIKAN';
      default:
        return 'AKTIF';
    }
  }

  bool get isOverdue =>
      status == 'overdue' ||
      (status == 'active' && dueDate.isBefore(DateTime.now()));

  String get daysLabel {
    if (status == 'returned') return 'Selesai';
    final days = dueDate.difference(DateTime.now()).inDays;
    if (days < 0) return 'Lewat ${days.abs()} Hari';
    if (days == 0) return 'Jatuh tempo hari ini';
    return 'Sisa $days Hari';
  }

  String get borrowDateLabel => _formatDate(borrowDate);
  String get dueDateLabel => _formatDate(dueDate);

  static String _formatDate(DateTime date) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class PeminjamanBukuScreen extends StatefulWidget {
  const PeminjamanBukuScreen({super.key});

  @override
  State<PeminjamanBukuScreen> createState() => _PeminjamanBukuScreenState();
}

class _PeminjamanBukuScreenState extends State<PeminjamanBukuScreen> {
  List<_LoanItem> _loans = const [];
  bool _isLoading = true;
  bool _usingDemoData = false;

  @override
  void initState() {
    super.initState();
    _fetchLoans();
  }

  Future<void> _fetchLoans() async {
    setState(() => _isLoading = true);
    try {
      final token = UserSession.instance.token;
      if (token == null) throw Exception('Sesi login tidak ditemukan');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/loans/my'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil peminjaman');
      }
      final data = jsonDecode(response.body);
      if (data is! List) throw Exception('Format data peminjaman tidak valid');
      if (!mounted) return;
      setState(() {
        _loans = data
            .map((item) => _LoanItem.fromJson(item as Map<String, dynamic>))
            .toList();
        _usingDemoData = false;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loans = _demoLoans;
        _usingDemoData = true;
        _isLoading = false;
      });
    }
  }

  List<_LoanItem> get _demoLoans => [
        _LoanItem(
          bookCode: 'PUST-LT-019',
          title: 'LemahTulis',
          author: 'Budi Maryono • Arsip Sastra Jawa Timur',
          rackLocation: 'RAK 2B',
          borrowDate: DateTime(2026, 10, 12),
          dueDate: DateTime(2026, 10, 26),
        ),
        _LoanItem(
          bookCode: 'PUST-MLG-042',
          title: 'Alun-Alun Malang',
          author: 'Dukut Imam Widodo • Babad Sejarah Urban',
          rackLocation: 'RAK 1A',
          borrowDate: DateTime(2026, 10, 14),
          dueDate: DateTime(2026, 10, 28),
        ),
      ];

  Future<void> _requestExtension(_LoanItem loan) async {
    if (_usingDemoData || loan.id == null) {
      _showMessage(
          'Data peminjaman belum tersinkron ke server admin. Muat ulang setelah backend aktif.');
      return;
    }
    if (loan.extensionStatus == 'pending') {
      _showMessage('Request perpanjangan sedang menunggu konfirmasi admin.');
      return;
    }
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/loans/extension'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${UserSession.instance.token}',
            },
            body: jsonEncode(
                {'loanId': int.tryParse(loan.id!), 'extensionDays': 7}),
          )
          .timeout(const Duration(seconds: 8));
      final body = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(body['message'] ?? 'Request perpanjangan gagal');
      }
      _showMessage('Request perpanjangan dikirim. Menunggu konfirmasi admin.');
      await _fetchLoans();
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: GoogleFonts.plusJakartaSans(fontSize: 12)),
        backgroundColor: AppColors.maroon,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
                const Icon(Icons.arrow_back_rounded, color: AppColors.textMain),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Peminjaman Buku',
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.maroonDark,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline_rounded,
                  color: AppColors.textMain, size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Maksimal 2 buku fisik per anggota dengan durasi 14 hari pinjam.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12),
                    ),
                    backgroundColor: AppColors.maroon,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Center(child: UserAvatarWidget(radius: 13)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Kuota Peminjaman
              _buildQuotaBanner(),
              const SizedBox(height: 18),

              // Subjudul Daftar Buku Aktif
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BUKU SEDANG DIPINJAM (${_loans.length})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: AppColors.greyText,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _loans.any((loan) => loan.status == 'overdue')
                          ? 'STATUS: TERLAMBAT'
                          : 'STATUS: AKTIF',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF15803D),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_loans.isEmpty)
                _buildEmptyLoanState()
              else
                ..._loans.map(
                  (loan) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildBookLoanCard(
                      context: context,
                      loan: loan,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Panduan dan Aturan Pengembalian
              _buildReturnRulesCard(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuotaBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.maroon.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.library_books_rounded,
                color: AppColors.maroon, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kartu Anggota: RBR-2026-0881',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.maroon,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_loans.length} dari 2 Kuota Buku Terpakai',
                  style: GoogleFonts.lora(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kembalikan buku sebelum jatuh tempo untuk meminjam judul lain.',
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

  Widget _buildBookLoanCard({
    required BuildContext context,
    required _LoanItem loan,
  }) {
    final isReturned = loan.status == 'returned';
    final isUrgent =
        loan.isOverdue || loan.dueDate.difference(DateTime.now()).inDays <= 3;
    const category = 'Koleksi Pustaka';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.maroon.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.maroon.withValues(alpha: 0.2)),
                ),
                child: const Center(
                  child: Icon(Icons.menu_book_rounded,
                      color: AppColors.maroon, size: 26),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.tagBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.maroon,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loan.statusLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: loan.status == 'returned'
                            ? const Color(0xFF15803D)
                            : loan.isOverdue
                                ? const Color(0xFFDC2626)
                                : AppColors.maroon,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loan.title,
                      style: GoogleFonts.lora(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loan.author,
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
          const SizedBox(height: 12),
          const Divider(color: AppColors.lightBorder, height: 1),
          const SizedBox(height: 10),

          // Detail Tanggal Pinjam & Jatuh Tempo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TANGGAL PINJAM',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    loan.borrowDateLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JATUH TEMPO',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    loan.dueDateLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.maroon,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isUrgent
                        ? const Color(0xFFFECACA)
                        : const Color(0xFFBBF7D0),
                  ),
                ),
                child: Text(
                  loan.daysLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isUrgent
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.place_outlined,
                  size: 14, color: AppColors.greyText),
              const SizedBox(width: 4),
              Text(
                '${loan.bookCode} • ${loan.rackLocation}',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: AppColors.greyText),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tombol Perpanjang & Detail
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isReturned ? null : () => _requestExtension(loan),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.maroon, width: 1.2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                  child: Text(
                    loan.extensionStatus == 'pending'
                        ? 'Menunggu Admin'
                        : loan.extensionStatus == 'approved'
                            ? 'Sudah Diperpanjang'
                            : 'Ajukan Perpanjangan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isReturned ? AppColors.greyText : AppColors.maroon,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _showRackLocation(loan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.maroon,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                ),
                child: Text(
                  'Lokasi Rak',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReturnRulesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADBCE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rule_rounded, color: AppColors.maroon, size: 18),
              const SizedBox(width: 8),
              Text(
                'Ketentuan Peminjaman Pustaka',
                style: GoogleFonts.lora(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Pengembalian buku dilakukan di Meja Sirkulasi Pustaka Lt. 1 Rumah Budaya Ratna.\n'
            '• Setiap judul dapat diperpanjang maksimal 1 kali selama belum dipesan anggota lain.\n'
            '• Keterlambatan dikenakan infaq pemeliharaan koleksi Rp 1.000 / hari per buku.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              height: 1.5,
              color: AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLoanState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.menu_book_outlined,
              color: AppColors.greyText, size: 36),
          const SizedBox(height: 8),
          Text(
            'Belum ada buku yang sedang dipinjam.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }

  void _showRackLocation(_LoanItem loan) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Lokasi Buku',
            style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
        content: Text(
          '${loan.title}\n\nKode: ${loan.bookCode}\nLokasi: ${loan.rackLocation}\n\nSilakan ambil atau kembalikan buku melalui Meja Sirkulasi Pustaka Lt. 1.',
          style: GoogleFonts.plusJakartaSans(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
