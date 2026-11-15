/// Model data untuk item dalam riwayat pesanan kedai.
class PesananKedaiModel {
  final String orderNumber;
  final String date;
  final List<String> items;
  final int total;
  final String status;
  final String meja;
  final String payment;

  const PesananKedaiModel({
    required this.orderNumber,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
    required this.meja,
    required this.payment,
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
  });
}
