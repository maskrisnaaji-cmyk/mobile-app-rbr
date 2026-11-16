class CultureCoupon {
  final int id;
  final String code;
  final String description;
  final String status;
  final String theme;
  final int? discountAmount;
  final int? discountPercent;

  const CultureCoupon({
    required this.id,
    required this.code,
    required this.description,
    required this.status,
    required this.theme,
    this.discountAmount,
    this.discountPercent,
  });

  factory CultureCoupon.fromJson(Map<String, dynamic> json) {
    final description = (json['desc'] ?? json['description'] ?? '').toString();
    final percentMatch = RegExp(r'(\d+)\s*%').firstMatch(description);
    final amountMatch =
        RegExp(r'Rp\s*([\d.]+)', caseSensitive: false).firstMatch(description);

    int? amount;
    if (amountMatch != null) {
      amount = int.tryParse(amountMatch.group(1)!.replaceAll('.', ''));
    }

    return CultureCoupon(
      id: int.tryParse(json['id'].toString()) ?? 0,
      code: (json['code'] ?? '').toString(),
      description: description,
      status: (json['status'] ?? 'Aktif').toString(),
      theme: (json['theme'] ?? 'maroon').toString(),
      discountPercent:
          percentMatch == null ? null : int.tryParse(percentMatch.group(1)!),
      discountAmount: amount,
    );
  }

  int discountFor(int subtotal) {
    final discount = discountPercent != null
        ? subtotal * discountPercent! ~/ 100
        : discountAmount ?? 0;
    return discount.clamp(0, subtotal);
  }
}
