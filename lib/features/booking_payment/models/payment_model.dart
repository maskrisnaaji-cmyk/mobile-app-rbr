/// Model data untuk item dalam riwayat pesanan kedai.
class PesananKedaiModel {
  final String orderNumber;
  final String date;
  final List<String> items;
  final int total;
  final String status;
  final String meja;
  final String payment;
  final String? vaNumber;
  final String? billerCode;
  final String? billKey;

  const PesananKedaiModel({
    required this.orderNumber,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
    required this.meja,
    required this.payment,
    this.vaNumber,
    this.billerCode,
    this.billKey,
  });
}

/// Model data untuk item dalam riwayat tiket agenda.
class TiketAgendaModel {
  final String bookingId;
  final String eventTitle;
  final String category;
  final String eventTime;
  final String location;
  final String ticketType;
  final int ticketCount;
  final String totalPrice;
  final String payment;
  final String status;
  final String? vaNumber;
  final String? billerCode;
  final String? billKey;

  const TiketAgendaModel({
    required this.bookingId,
    required this.eventTitle,
    required this.category,
    required this.eventTime,
    required this.location,
    required this.ticketType,
    required this.ticketCount,
    required this.totalPrice,
    required this.payment,
    required this.status,
    this.vaNumber,
    this.billerCode,
    this.billKey,
  });
}

/// Model data untuk hasil response pembayaran QRIS / charge Midtrans.
class QrisPaymentData {
  final String? qrCodeUrl;
  final String? qrString;
  final String? orderId;
  final int? grossAmount;
  final String? transactionStatus;

  const QrisPaymentData({
    this.qrCodeUrl,
    this.qrString,
    this.orderId,
    this.grossAmount,
    this.transactionStatus,
  });

  /// Factory untuk memetakan response API backend-rbr secara menyeluruh,
  /// termasuk parsing array actions Midtrans jika ada.
  factory QrisPaymentData.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const QrisPaymentData();

    // 1. Ekstraksi qr_string langsung atau dari nested data
    String? qrStr = map['qr_string']?.toString() ??
        map['data']?['qr_string']?.toString() ??
        map['qr_code']?.toString() ??
        map['data']?['qr_code']?.toString();

    // 2. Ekstraksi qr_code_url / qr_url
    String? qrUrl = map['qr_code_url']?.toString() ??
        map['qr_url']?.toString() ??
        map['data']?['qr_code_url']?.toString() ??
        map['data']?['qr_url']?.toString();

    // 3. Fallback ekstraksi dari array `actions` Midtrans Core API jika qrUrl kosong
    // format actions: [{ "name": "generate-qr-code", "method": "GET", "url": "..." }]
    if (qrUrl == null || qrUrl.isEmpty) {
      final actions = map['actions'] ?? map['data']?['actions'];
      if (actions is List) {
        for (final item in actions) {
          if (item is Map) {
            final name = item['name']?.toString().toLowerCase();
            if (name == 'generate-qr-code' || name == 'qr-code') {
              final actionUrl = item['url']?.toString();
              if (actionUrl != null && actionUrl.isNotEmpty) {
                qrUrl = actionUrl;
                break;
              }
            }
          }
        }
        if ((qrUrl == null || qrUrl.isEmpty) && actions.isNotEmpty) {
          final first = actions.first;
          if (first is Map && first['url'] != null) {
            qrUrl = first['url'].toString();
          }
        }
      }
    }

    return QrisPaymentData(
      qrCodeUrl:
          (qrUrl != null && qrUrl.trim().isNotEmpty) ? qrUrl.trim() : null,
      qrString:
          (qrStr != null && qrStr.trim().isNotEmpty) ? qrStr.trim() : null,
      orderId:
          map['order_id']?.toString() ?? map['data']?['order_id']?.toString(),
      grossAmount: (map['gross_amount'] as num?)?.toInt() ??
          (map['data']?['gross_amount'] as num?)?.toInt(),
      transactionStatus: map['transaction_status']?.toString() ??
          map['data']?['transaction_status']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'qr_code_url': qrCodeUrl,
      'qr_url': qrCodeUrl,
      'qr_string': qrString,
      if (orderId != null) 'order_id': orderId,
      if (grossAmount != null) 'gross_amount': grossAmount,
      if (transactionStatus != null) 'transaction_status': transactionStatus,
    };
  }
}
