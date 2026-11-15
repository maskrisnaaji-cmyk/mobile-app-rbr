/// Model data untuk peminjaman buku fisik perpustakaan
class LoanItem {
  final String? id;
  final String bookCode;
  final String title;
  final String author;
  final String rackLocation;
  final DateTime borrowDate;
  final DateTime dueDate;
  final String status;
  final String extensionStatus;

  const LoanItem({
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

  factory LoanItem.fromJson(Map<String, dynamic> json) {
    return LoanItem(
      id: json['id']?.toString(),
      bookCode: json['book_code']?.toString() ?? json['bookCode']?.toString() ?? '-',
      title: json['title']?.toString() ?? 'Buku tanpa judul',
      author: json['author']?.toString() ?? 'Penulis tidak diketahui',
      rackLocation: json['rack_location']?.toString() ?? json['rackLocation']?.toString() ?? 'Belum ditentukan',
      borrowDate: json['borrow_date'] != null
          ? DateTime.parse(json['borrow_date'].toString())
          : (json['borrowDate'] != null ? DateTime.parse(json['borrowDate'].toString()) : DateTime.now()),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'].toString())
          : (json['dueDate'] != null ? DateTime.parse(json['dueDate'].toString()) : DateTime.now().add(const Duration(days: 14))),
      status: json['status']?.toString() ?? 'active',
      extensionStatus: json['extension_status']?.toString() ?? json['extensionStatus']?.toString() ?? 'none',
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
      status == 'overdue' || (status == 'active' && dueDate.isBefore(DateTime.now()));

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

  static List<LoanItem> get demoLoans => [
        LoanItem(
          bookCode: 'PUST-LT-019',
          title: 'LemahTulis',
          author: 'Budi Maryono • Arsip Sastra Jawa Timur',
          rackLocation: 'RAK 2B',
          borrowDate: DateTime(2026, 10, 12),
          dueDate: DateTime(2026, 10, 26),
        ),
        LoanItem(
          bookCode: 'PUST-MLG-042',
          title: 'Alun-Alun Malang',
          author: 'Dukut Imam Widodo • Babad Sejarah Urban',
          rackLocation: 'RAK 1A',
          borrowDate: DateTime(2026, 10, 14),
          dueDate: DateTime(2026, 10, 28),
        ),
      ];
}
