import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';

class CultureCoupon {
  final int id;
  final String code;
  final String description;
  final String status;
  final String theme;
  final String discountType; // 'percent' atau 'fixed'
  final int discountValue;
  final String targetMember; // 'all' atau 'verified'

  const CultureCoupon({
    required this.id,
    required this.code,
    required this.description,
    required this.status,
    required this.theme,
    this.discountType = 'percent',
    this.discountValue = 0,
    this.targetMember = 'all',
  });

  bool get isVerifiedOnly =>
      targetMember.toLowerCase() == 'verified' ||
      targetMember.toLowerCase() == 'terverifikasi';

  bool get isPercent =>
      discountType.toLowerCase() == 'percent' ||
      discountType.toLowerCase() == 'percentage' ||
      discountType == '%';

  /// Kompatibilitas mundur dengan kode lama
  int? get discountPercent => isPercent ? discountValue : null;
  int? get discountAmount => !isPercent ? discountValue : null;

  String get discountLabel {
    if (isPercent) {
      return '$discountValue% OFF';
    }
    return 'Rp ${_formatNumber(discountValue)}';
  }

  static String _formatNumber(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  factory CultureCoupon.fromJson(Map<String, dynamic> json) {
    final description = (json['desc'] ?? json['description'] ?? '').toString();
    final percentMatch = RegExp(r'(\d+)\s*%').firstMatch(description);
    final amountMatch =
        RegExp(r'Rp\s*([\d.]+)', caseSensitive: false).firstMatch(description);

    String type = (json['discount_type'] ?? '').toString().toLowerCase();
    int value = int.tryParse(json['discount_value']?.toString() ?? '') ?? 0;

    // Fallback regex jika discount_type atau discount_value tidak ada
    if (type.isEmpty || value == 0) {
      if (percentMatch != null) {
        type = 'percent';
        value = int.tryParse(percentMatch.group(1)!) ?? 0;
      } else if (amountMatch != null) {
        type = 'fixed';
        value = int.tryParse(amountMatch.group(1)!.replaceAll('.', '')) ?? 0;
      } else {
        type = 'percent';
      }
    }

    final targetMember =
        (json['target_member'] ?? json['target'] ?? 'all').toString();

    return CultureCoupon(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      code: (json['code'] ?? '').toString().toUpperCase(),
      description: description,
      status: (json['status'] ?? 'Aktif').toString(),
      theme: (json['theme'] ?? 'maroon').toString(),
      discountType: type,
      discountValue: value,
      targetMember: targetMember,
    );
  }

  /// Menghitung diskon berdasarkan subtotal.
  /// Memastikan gross_amount minimal Rp 1 untuk validitas Midtrans.
  int discountFor(int subtotal) {
    if (subtotal <= 1) return 0;

    int discount;
    if (isPercent) {
      discount = (subtotal * discountValue) ~/ 100;
    } else {
      discount = discountValue;
    }

    // Maksimal diskon adalah subtotal - 1 agar gross_amount >= 1 (aturan Midtrans)
    final maxDiscount = subtotal - 1;
    return discount.clamp(0, maxDiscount);
  }

  /// Mengambil seluruh kupon aktif dari backend
  static Future<List<CultureCoupon>> fetchAll() async {
    final response = await http
        .get(Uri.parse(ApiConfig.couponsUrl))
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => CultureCoupon.fromJson(item as Map<String, dynamic>))
          .where((coupon) => coupon.status.toLowerCase() == 'aktif')
          .toList();
    }
    return [];
  }
}
