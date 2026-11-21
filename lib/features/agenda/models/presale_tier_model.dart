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

  factory PresaleTierModel.fromJson(Map<String, dynamic> json) {
    final soldVal = (json['sold'] as num?)?.toInt() ?? 0;
    final quotaVal = (json['quota'] as num?)?.toInt() ?? 0;
    return PresaleTierModel(
      id: (json['id'] as num).toInt(),
      eventId: (json['event_id'] as num).toInt(),
      tierName: json['tier_name'] as String? ?? '',
      tierOrder: (json['tier_order'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toInt() ?? 0,
      quota: quotaVal,
      sold: soldVal,
      isActive: json['is_active'] as bool? ?? false,
      isSoldout: json['is_soldout'] as bool? ?? (soldVal >= quotaVal),
      isCurrentActive: json['is_current_active'] as bool? ?? false,
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
