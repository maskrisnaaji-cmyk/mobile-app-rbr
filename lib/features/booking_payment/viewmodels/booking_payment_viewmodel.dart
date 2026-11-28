import 'package:flutter/foundation.dart';
import 'package:mobile_app/features/agenda/models/presale_tier_model.dart';
import 'package:mobile_app/features/agenda/repositories/presale_repository.dart';
import 'package:mobile_app/features/booking_payment/models/payment_model.dart';
import 'package:mobile_app/features/booking_payment/repositories/booking_payment_repository.dart';

// ---------------------------------------------------------------------------
// BookingCheckoutViewModel
// Mengelola state untuk halaman checkout tiket agenda.
// ---------------------------------------------------------------------------

/// Enum metode pembayaran pada checkout tiket (disamakan seragam dengan modul Kedai Kopi).
enum CheckoutPaymentMethod {
  qris(
    label: 'QRIS Nasional',
    description: 'BCA, GoPay, OVO, ShopeePay, Dana, LinkAja',
    badge: 'INSTAN',
  ),
  cash(
    label: 'Bayar di Kasir (Tunai)',
    description: 'Bayar langsung di loket tiket / meja kasir setelah memesan',
    badge: 'Loket Tiket',
  ),
  bankTransfer(
    label: 'Transfer Bank (Virtual Account)',
    description: 'BCA, Mandiri, BNI, BRI, Permata',
    badge: 'VA 24 JAM',
  );

  const CheckoutPaymentMethod({
    required this.label,
    required this.description,
    this.badge,
  });

  final String label;
  final String description;
  final String? badge;
}

class BookingCheckoutViewModel extends ChangeNotifier {
  final BookingPaymentRepository repository;
  final PresaleRepository presaleRepository;

  BookingCheckoutViewModel({
    BookingPaymentRepository? repository,
    PresaleRepository? presaleRepository,
  })  : repository = repository ?? BookingPaymentRepositoryImpl(),
        presaleRepository = presaleRepository ?? PresaleRepositoryImpl();

  final int presalePrice = 25000;
  final int regulerPrice = 35000;

  int _selectedTicketType = 0;
  int get selectedTicketType => _selectedTicketType;

  int _ticketQuantity = 1;
  int get ticketQuantity => _ticketQuantity;

  CheckoutPaymentMethod _selectedPaymentMethod = CheckoutPaymentMethod.qris;
  CheckoutPaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;

  String _selectedBank = 'bca'; // Bank aktif saat memilih VA
  String get selectedBank => _selectedBank;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // --- Presale fields ---
  List<PresaleTierModel> _presaleTiers = [];
  PresaleTierModel? _selectedPresaleTier;
  bool _isPresaleMode = false;
  bool _isLoadingPresale = false;

  List<PresaleTierModel> get presaleTiers => _presaleTiers;
  PresaleTierModel? get selectedPresaleTier => _selectedPresaleTier;
  bool get isPresaleMode => _isPresaleMode;
  bool get isLoadingPresale => _isLoadingPresale;

  /// Status apakah semua kuota tiket (Presale 1, 2, Reguler) sudah habis
  bool get isSoldOut {
    if (_isLoadingPresale) return false;
    if (_isPresaleMode) {
      if (_presaleTiers.isEmpty) return false;
      return _selectedPresaleTier == null || _selectedPresaleTier!.remainingQuota <= 0;
    }
    return false;
  }

  /// Kuota maksimal yang dapat dibeli oleh pengguna (maksimal 5 atau sisa kuota tier aktif)
  int get maxAllowedQuantity {
    if (isSoldOut) return 0;
    if (_isPresaleMode && _selectedPresaleTier != null) {
      final rem = _selectedPresaleTier!.remainingQuota;
      if (rem <= 0) return 0;
      return rem < 5 ? rem : 5;
    }
    return 5;
  }

  int get currentUnitPrice {
    if (_isPresaleMode && _selectedPresaleTier != null) {
      return _selectedPresaleTier!.price;
    }
    return _selectedTicketType == 0 ? presalePrice : regulerPrice;
  }

  int get totalAmount => currentUnitPrice * _ticketQuantity;

  String formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  void selectTicketType(int index) {
    if (_selectedTicketType != index) {
      _selectedTicketType = index;
      notifyListeners();
    }
  }

  void decrementQuantity() {
    final minQty = maxAllowedQuantity > 0 ? 1 : 0;
    if (_ticketQuantity > minQty) {
      _ticketQuantity--;
      notifyListeners();
    }
  }

  void incrementQuantity() {
    if (_ticketQuantity < maxAllowedQuantity) {
      _ticketQuantity++;
      notifyListeners();
    }
  }

  void selectPaymentMethod(CheckoutPaymentMethod method) {
    if (_selectedPaymentMethod != method) {
      _selectedPaymentMethod = method;
      notifyListeners();
    }
  }

  /// Memilih bank untuk Virtual Account
  void selectBank(String bank) {
    if (_selectedBank != bank) {
      _selectedBank = bank;
      notifyListeners();
    }
  }

  /// Memuat daftar tier presale untuk event tertentu.
  /// Menentukan secara otomatis tier yang sedang aktif berurutan: Presale 1 -> Presale 2 -> Reguler.
  Future<void> loadPresaleTiers(int eventId) async {
    _isLoadingPresale = true;
    notifyListeners();

    try {
      final tiers = await presaleRepository.getPresaleTiers(eventId);
      _presaleTiers = tiers;
      _isPresaleMode = tiers.isNotEmpty;

      if (tiers.isNotEmpty) {
        // Cari tier aktif berurutan:
        // 1. Yang ditandai isCurrentActive && !isSoldout && remainingQuota > 0
        // 2. Fallback ke tier pertama berurutan yang belum sold out (remainingQuota > 0)
        PresaleTierModel? active;
        final activeMatches = tiers.where(
          (t) => t.isCurrentActive && !t.isSoldout && t.remainingQuota > 0,
        ).toList();

        if (activeMatches.isNotEmpty) {
          active = activeMatches.first;
        } else {
          final availableMatches = tiers.where(
            (t) => !t.isSoldout && t.remainingQuota > 0,
          ).toList();
          if (availableMatches.isNotEmpty) {
            active = availableMatches.first;
          }
        }

        _selectedPresaleTier = active;

        // Validasi dan sesuaikan jumlah tiket berdasarkan sisa kuota tier aktif
        if (active == null) {
          _ticketQuantity = 0;
        } else {
          final maxQty = active.remainingQuota < 5 ? active.remainingQuota : 5;
          if (_ticketQuantity > maxQty) {
            _ticketQuantity = maxQty;
          } else if (_ticketQuantity <= 0 && maxQty > 0) {
            _ticketQuantity = 1;
          }
        }
      }
    } catch (_) {
      _presaleTiers = [];
      _isPresaleMode = false;
      _selectedPresaleTier = null;
    } finally {
      _isLoadingPresale = false;
      notifyListeners();
    }
  }

  /// Memilih tier presale yang diinginkan pengguna (opsional/internal).
  void selectPresaleTier(PresaleTierModel tier) {
    _selectedPresaleTier = tier;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> submitCheckout({
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String eventTitle,
    int? eventId,
    String? couponCode,
    dynamic userId,
  }) async {
    if (isSoldOut || _ticketQuantity <= 0) {
      return {
        'error': 'Tiket sudah habis (Sold Out).',
        'quota_exceeded': true,
      };
    }

    _isSubmitting = true;
    notifyListeners();

    final orderId = 'RBR-TKT-${DateTime.now().millisecondsSinceEpoch}';
    final isQris = _selectedPaymentMethod == CheckoutPaymentMethod.qris;
    final isCash = _selectedPaymentMethod == CheckoutPaymentMethod.cash;

    final paymentTypeString = isQris
        ? 'qris'
        : (isCash ? 'cash' : 'bank_transfer');

    if (_isPresaleMode && _selectedPresaleTier != null) {
      final sellRes = await presaleRepository.sellTickets(
        _selectedPresaleTier!.id,
        _ticketQuantity,
      );
      if (sellRes.containsKey('error') && sellRes['status'] == 409) {
        if (eventId != null) {
          await loadPresaleTiers(eventId);
        }
        _isSubmitting = false;
        notifyListeners();
        return {
          'error': sellRes['error'] ?? 'Kuota presale telah habis.',
          'quota_exceeded': true,
        };
      }
    }

    final ticketItemName = _isPresaleMode && _selectedPresaleTier != null
        ? 'Tiket ${_selectedPresaleTier!.tierName}: $eventTitle'
        : 'Tiket: $eventTitle';

    final result = await repository.createCharge(
      orderId: orderId,
      grossAmount: totalAmount,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      paymentType: paymentTypeString,
      bank: isCash ? 'cash' : _selectedBank,
      orderType: 'ticket',
      eventId: eventId,
      items: [
        {
          'id': eventId?.toString() ?? 'TKT',
          'name': ticketItemName,
          'price': totalAmount ~/ _ticketQuantity,
          'quantity': _ticketQuantity,
        }
      ],
      couponCode: (couponCode != null && couponCode.isNotEmpty) ? couponCode : null,
      userId: userId,
    );

    // Normalisasi mapping response QRIS dari backend-rbr & Midtrans (termasuk actions)
    final qrisData = QrisPaymentData.fromMap(result);
    if (result != null) {
      if (qrisData.qrCodeUrl != null) {
        result['qr_code_url'] = qrisData.qrCodeUrl;
        result['qr_url'] = qrisData.qrCodeUrl;
      }
      if (qrisData.qrString != null) {
        result['qr_string'] = qrisData.qrString;
      }
    }

    _isSubmitting = false;
    notifyListeners();

    return {
      'charge_result': result,
      'order_id': result?['order_id'] ?? orderId,
      'is_qris': isQris,
      'is_cash': isCash,
      'qr_code_url': qrisData.qrCodeUrl,
      'qr_string': qrisData.qrString,
    };
  }

  /// Mendaftarkan pesanan kedai baru ke backend (POST /api/kedai/orders)
  Future<Map<String, dynamic>?> createKedaiOrder({
    required String orderCode,
    required String tableNumber,
    required List<Map<String, dynamic>> items,
    required int totalPrice,
  }) async {
    return await repository.createKedaiOrder(
      orderCode: orderCode,
      tableNumber: tableNumber,
      items: items,
      totalPrice: totalPrice,
    );
  }
}

// ---------------------------------------------------------------------------
// PaymentStatusViewModel
// Mengelola state cek status pembayaran (shared: QRIS & VA).
// ---------------------------------------------------------------------------

class PaymentStatusViewModel extends ChangeNotifier {
  final BookingPaymentRepository repository;

  PaymentStatusViewModel({BookingPaymentRepository? repository})
      : repository = repository ?? BookingPaymentRepositoryImpl();

  bool _isChecking = false;
  bool get isChecking => _isChecking;

  bool _isExpired = false;
  bool get isExpired => _isExpired;

  DateTime? _expiredAt;
  DateTime? get expiredAt => _expiredAt;

  Map<String, dynamic>? _lastStatusData;
  Map<String, dynamic>? get lastStatusData => _lastStatusData;

  /// Cek status pembayaran via backend.
  /// Mengembalikan true jika pembayaran sudah settlement/paid.
  Future<bool> checkStatus(String orderId) async {
    _isChecking = true;
    notifyListeners();

    final statusData = await repository.checkPaymentStatus(orderId);
    if (statusData != null) {
      final qrisData = QrisPaymentData.fromMap(statusData);
      if (qrisData.qrCodeUrl != null) {
        statusData['qr_code_url'] = qrisData.qrCodeUrl;
        statusData['qr_url'] = qrisData.qrCodeUrl;
      }
      if (qrisData.qrString != null) {
        statusData['qr_string'] = qrisData.qrString;
      }
    }
    _lastStatusData = statusData;

    _isChecking = false;

    final txStatus =
        (statusData?['transaction_status'] ?? '').toString().toLowerCase();
    _isExpired = statusData?['is_expired'] == true || txStatus == 'expire';

    if (statusData?['expired_at'] != null) {
      _expiredAt = DateTime.tryParse(statusData!['expired_at'].toString());
    }

    notifyListeners();

    return statusData?['is_paid'] == true ||
        txStatus == 'settlement' ||
        txStatus == 'paid';
  }

  /// Simulasi settlement untuk demo/testing.
  Future<bool> simulateSettlement({
    required String orderId,
    required int grossAmount,
    String paymentType = 'qris',
  }) async {
    _isChecking = true;
    notifyListeners();

    final success = await repository.simulateSettlement(
      orderId: orderId,
      grossAmount: grossAmount,
      paymentType: paymentType,
    );

    _isChecking = false;
    notifyListeners();

    return success;
  }

  /// Konfirmasi pelunasan pesanan kedai ke backend (PATCH /api/kedai/orders/:id/pay)
  Future<bool> confirmKedaiOrderPayment(String orderCode) async {
    return await repository.confirmKedaiOrderPayment(orderCode);
  }

  /// Konfirmasi booking tiket agenda ke backend (POST /api/events/:id/book)
  Future<bool> confirmEventBooking({
    required int eventId,
    int quantity = 1,
    String? customerName,
    String? customerEmail,
    String? orderId,
  }) async {
    return await repository.confirmEventBooking(
      eventId: eventId,
      quantity: quantity,
      customerName: customerName,
      customerEmail: customerEmail,
      orderId: orderId,
    );
  }
}

// ---------------------------------------------------------------------------
// RiwayatPesananViewModel
// Mengelola data statis riwayat pesanan kedai dan tiket agenda.
// ---------------------------------------------------------------------------

class RiwayatPesananViewModel extends ChangeNotifier {
  final List<PesananKedaiModel> pesananKedai = const [
    PesananKedaiModel(
      orderNumber: '#ORD-9042',
      date: 'Sabtu, 25 Okt 2026 • 14:32 WIB',
      items: ['Kopi Susu Gula Aren (x1)', 'Pisang Goreng Keju (x2)'],
      total: 45000,
      status: 'settlement',
      meja: 'Meja No. 04 (Dine-In)',
      payment: 'qris',
    ),
    PesananKedaiModel(
      orderNumber: '#ORD-8817',
      date: 'Rabu, 15 Okt 2026 • 11:10 WIB',
      items: ['Wedang Uwuh (x2)', 'Teh Rempah Nusantara (x1)'],
      total: 36000,
      status: 'settlement',
      meja: 'Meja No. 02 (Dine-In)',
      payment: 'bca',
      vaNumber: '8830 9042 1817 000',
    ),
    PesananKedaiModel(
      orderNumber: '#ORD-8201',
      date: 'Jum, 03 Okt 2026 • 16:45 WIB',
      items: ['Kopi Hitam Tubruk (x1)'],
      total: 15000,
      status: 'settlement',
      meja: 'Meja No. 01 (Dine-In)',
      payment: 'kasir',
    ),
    PesananKedaiModel(
      orderNumber: '#ORD-7955',
      date: 'Sel, 21 Okt 2026 • 09:15 WIB',
      items: ['V60 Manual Brew (x1)', 'Kopi Susu Creamy (x1)'],
      total: 43000,
      status: 'pending',
      meja: 'Meja No. 06 (Dine-In)',
      payment: 'echannel',
      billerCode: '70012',
      billKey: '90421817001',
    ),
    PesananKedaiModel(
      orderNumber: '#ORD-7730',
      date: 'Sen, 20 Okt 2026 • 13:00 WIB',
      items: ['Americano Signature (x2)'],
      total: 34000,
      status: 'expire',
      meja: 'Meja No. 03 (Dine-In)',
      payment: 'bri',
      vaNumber: '1280 9042 1817 003',
    ),
  ];

  final List<TiketAgendaModel> tiketAgenda = const [
    TiketAgendaModel(
      bookingId: '#TKT-3041',
      eventTitle: 'Napak Tanah Jilid II — Book Club & Pot Luck',
      category: 'Lokakarya Seni',
      eventTime: 'Rabu, 28 Sep 2026 • 15:30 WIB',
      location: 'Ruang Komunal Lt. 2, Rumah Budaya Ratna',
      ticketType: 'Tiket Reguler',
      ticketCount: 2,
      totalPrice: 'Rp 50.000',
      payment: 'qris',
      status: 'settlement',
    ),
    TiketAgendaModel(
      bookingId: '#TKT-2988',
      eventTitle: 'Obrolan Budaya: Dialektika Tradisi & Modernitas',
      category: 'Diskusi',
      eventTime: 'Rabu, 08 Okt 2026 • 19:00 WIB',
      location: 'Pendopo Utama, Rumah Budaya Ratna',
      ticketType: 'Tiket Gratis (Daftar)',
      ticketCount: 1,
      totalPrice: 'Gratis',
      payment: '-',
      status: 'hadir',
    ),
    TiketAgendaModel(
      bookingId: '#TKT-3109',
      eventTitle: 'Workshop Keramik: Tanah & Tangan',
      category: 'Workshop',
      eventTime: 'Min, 11 Okt 2026 • 10:00 WIB',
      location: 'Studio Kriya Lt. 1, Rumah Budaya Ratna',
      ticketType: 'Tiket Presale 1',
      ticketCount: 1,
      totalPrice: 'Rp 75.000',
      payment: 'echannel',
      status: 'settlement',
      billerCode: '70012',
      billKey: '31090001882',
    ),
    TiketAgendaModel(
      bookingId: '#TKT-3200',
      eventTitle: 'Pameran Seni Rupa: Bumi & Langit',
      category: 'Pameran',
      eventTime: 'Sab, 18 Okt 2026 • 10:00 WIB',
      location: 'Galeri Utama, Rumah Budaya Ratna',
      ticketType: 'Tiket Presale 2',
      ticketCount: 2,
      totalPrice: 'Rp 100.000',
      payment: 'bni',
      status: 'pending',
      vaNumber: '9880 3200 1817 002',
    ),
    TiketAgendaModel(
      bookingId: '#TKT-3315',
      eventTitle: 'Festival Musik Tradisi Nusantara',
      category: 'Festival',
      eventTime: 'Min, 26 Okt 2026 • 18:00 WIB',
      location: 'Pendopo Utama, Rumah Budaya Ratna',
      ticketType: 'Tiket Reguler',
      ticketCount: 1,
      totalPrice: 'Rp 60.000',
      payment: 'kasir',
      status: 'hadir',
    ),
    TiketAgendaModel(
      bookingId: '#TKT-3420',
      eventTitle: 'Kelas Membatik Corak Klasik',
      category: 'Lokakarya',
      eventTime: 'Sab, 01 Nov 2026 • 09:00 WIB',
      location: 'Pendopo Timur, Rumah Budaya Ratna',
      ticketType: 'Tiket Presale 1',
      ticketCount: 1,
      totalPrice: 'Rp 80.000',
      payment: 'permata',
      status: 'expire',
      vaNumber: '8520 3420 1817 004',
    ),
    TiketAgendaModel(
      bookingId: '#TKT-3510',
      eventTitle: 'Pentas Tari Bedhaya Kraton',
      category: 'Pertunjukan',
      eventTime: 'Min, 09 Nov 2026 • 19:30 WIB',
      location: 'Pendopo Utama, Rumah Budaya Ratna',
      ticketType: 'Tiket Reguler',
      ticketCount: 1,
      totalPrice: 'Rp 65.000',
      payment: 'cimb',
      status: 'settlement',
      vaNumber: '5910 3510 1817 005',
    ),
  ];

  String formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}';
  }
}
