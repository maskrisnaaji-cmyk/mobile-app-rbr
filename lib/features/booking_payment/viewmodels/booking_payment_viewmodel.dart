import 'package:flutter/foundation.dart';
import 'package:mobile_app/features/booking_payment/models/payment_model.dart';
import 'package:mobile_app/features/booking_payment/repositories/booking_payment_repository.dart';

// ---------------------------------------------------------------------------
// BookingCheckoutViewModel
// Mengelola state untuk halaman checkout tiket agenda.
// ---------------------------------------------------------------------------

/// Enum metode pembayaran pada checkout tiket.
enum CheckoutPaymentMethod {
  qris(
    label: 'QRIS Nasional',
    description: 'GoPay, OVO, DANA, ShopeePay, & m-Banking',
    badge: 'INSTAN',
  ),
  bankTransfer(
    label: 'Transfer Bank VA',
    description: 'BCA, Mandiri, BNI, BRI (Verifikasi Otomatis)',
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

  BookingCheckoutViewModel({BookingPaymentRepository? repository})
      : repository = repository ?? BookingPaymentRepositoryImpl();

  final int presalePrice = 25000;
  final int regulerPrice = 35000;

  int _selectedTicketType = 0;
  int get selectedTicketType => _selectedTicketType;

  int _ticketQuantity = 1;
  int get ticketQuantity => _ticketQuantity;

  CheckoutPaymentMethod _selectedPaymentMethod = CheckoutPaymentMethod.qris;
  CheckoutPaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  int get currentUnitPrice =>
      _selectedTicketType == 0 ? presalePrice : regulerPrice;
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
    if (_ticketQuantity > 1) {
      _ticketQuantity--;
      notifyListeners();
    }
  }

  void incrementQuantity() {
    if (_ticketQuantity < 5) {
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

  Future<Map<String, dynamic>?> submitCheckout({
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String eventTitle,
    int? eventId,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    final orderId = 'RBR-TKT-${DateTime.now().millisecondsSinceEpoch}';
    final isQris = _selectedPaymentMethod == CheckoutPaymentMethod.qris;

    final result = await repository.createCharge(
      orderId: orderId,
      grossAmount: totalAmount,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      paymentType: isQris ? 'qris' : 'bank_transfer',
      bank: 'bca',
      orderType: 'ticket',
      eventId: eventId,
      items: [
        {
          'id': eventId?.toString() ?? 'TKT',
          'name': 'Tiket: $eventTitle',
          'price': totalAmount ~/ _ticketQuantity,
          'quantity': _ticketQuantity,
        }
      ],
    );

    _isSubmitting = false;
    notifyListeners();

    return {
      'charge_result': result,
      'order_id': result?['order_id'] ?? orderId,
      'is_qris': isQris,
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

  /// Cek status pembayaran via backend.
  /// Mengembalikan true jika pembayaran sudah settlement/paid.
  Future<bool> checkStatus(String orderId) async {
    _isChecking = true;
    notifyListeners();

    final statusData = await repository.checkPaymentStatus(orderId);

    _isChecking = false;
    notifyListeners();

    final txStatus =
        (statusData?['transaction_status'] ?? '').toString().toLowerCase();
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
      status: 'Selesai',
      meja: 'Meja No. 04 (Dine-In)',
      payment: 'QRIS (INSTAN)',
    ),
    PesananKedaiModel(
      orderNumber: '#ORD-8817',
      date: 'Rabu, 15 Okt 2026 • 11:10 WIB',
      items: ['Wedang Uwuh (x2)', 'Teh Rempah Nusantara (x1)'],
      total: 36000,
      status: 'Selesai',
      meja: 'Meja No. 02 (Dine-In)',
      payment: 'QRIS (INSTAN)',
    ),
    PesananKedaiModel(
      orderNumber: '#ORD-8201',
      date: 'Jum, 03 Okt 2026 • 16:45 WIB',
      items: ['Kopi Hitam Tubruk (x1)'],
      total: 15000,
      status: 'Selesai',
      meja: 'Meja No. 01 (Dine-In)',
      payment: 'Tunai',
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
      payment: 'QRIS',
      status: 'Hadir',
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
      status: 'Hadir',
    ),
    TiketAgendaModel(
      bookingId: '#TKT-3109',
      eventTitle: 'Workshop Keramik: Tanah & Tangan',
      category: 'Workshop',
      eventTime: 'Min, 11 Okt 2026 • 10:00 WIB',
      location: 'Studio Kriya Lt. 1, Rumah Budaya Ratna',
      ticketType: 'Tiket Reguler',
      ticketCount: 1,
      totalPrice: 'Rp 75.000',
      payment: 'Transfer Bank',
      status: 'Hadir',
    ),
  ];

  String formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}';
  }
}
