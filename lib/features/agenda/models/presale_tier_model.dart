// lib/features/agenda/models/presale_tier_model.dart

/// Model untuk satu tier/tingkatan presale tiket event.
class PresaleTierModel {
  final int id;
  final int eventId;
  final String tierName;
  final int tierOrder;
  final int price;
  final int quota;
  final int sold;
  final bool isActive;
  final bool isSoldout;
  final bool isCurrentActive;

  const PresaleTierModel({
    required this.id,
    required this.eventId,
    required this.tierName,
    required this.tierOrder,
    required this.price,
    required this.quota,
    required this.sold,
    required this.isActive,
    required this.isSoldout,
    required this.isCurrentActive,
  });

  /// Sisa kuota tiket yang tersedia.
  int get remainingQuota => (quota - sold).clamp(0, quota);

  /// Harga dalam format Rupiah, atau "Gratis" jika 0.
  String get formattedPrice {
    if (price <= 0) return 'Gratis';
    final formatted = price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }

  /// Persentase kemajuan penjualan tiket (0.0 - 1.0).
  double get progressPercent {
    if (quota <= 0) return 0.0;
    return (sold / quota).clamp(0.0, 1.0);
  }

  static bool _parseBool(dynamic val, [bool fallback = false]) {
    if (val == null) return fallback;
    if (val is bool) return val;
    if (val is num) return val == 1;
    final s = val.toString().toLowerCase().trim();
    return s == '1' || s == 'true';
  }

  static int _parseInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString().trim()) ?? fallback;
  }

  factory PresaleTierModel.fromJson(Map<String, dynamic> json) {
    final soldVal = _parseInt(json['sold']);
    final quotaVal = _parseInt(json['quota']);
    final bool isSoldoutVal = json['is_soldout'] != null
        ? _parseBool(json['is_soldout'])
        : (quotaVal > 0 && soldVal >= quotaVal);

    return PresaleTierModel(
      id: _parseInt(json['id']),
      eventId: _parseInt(json['event_id']),
      tierName: json['tier_name']?.toString() ?? '',
      tierOrder: _parseInt(json['tier_order'], 1),
      price: _parseInt(json['price']),
      quota: quotaVal,
      sold: soldVal,
      isActive: _parseBool(json['is_active'], true),
      isSoldout: isSoldoutVal,
      isCurrentActive: _parseBool(json['is_current_active']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'event_id': eventId,
        'tier_name': tierName,
        'tier_order': tierOrder,
        'price': price,
        'quota': quota,
        'sold': sold,
        'is_active': isActive,
        'is_soldout': isSoldout,
        'is_current_active': isCurrentActive,
      };
}
