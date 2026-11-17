import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/services/payment_service.dart';
import 'package:mobile_app/features/kedai_kopi/models/cart_item_model.dart';
import 'package:mobile_app/features/kedai_kopi/models/coupon_model.dart';
import 'package:mobile_app/features/kedai_kopi/models/menu_model.dart';

/// Kontrak repositori untuk fitur Kedai Kopi
abstract class KedaiKopiRepository {
  /// Mengambil daftar menu kedai kopi dari backend
  Future<List<MenuModel>> getMenus();
  Future<List<CultureCoupon>> getCoupons();

  /// Mengirim pesanan meja / charge transaksi kedai
  Future<Map<String, dynamic>?> submitOrder({
    required String orderId,
    required int grossAmount,
    required String customerName,
    required String paymentType,
    required String bank,
    required List<CartItem> items,
  });

  /// Mendaftarkan pesanan baru ke backend kedai (status: UNPAID)
  Future<Map<String, dynamic>?> createKedaiOrder({
    required String orderCode,
    required String tableNumber,
    required List<CartItem> items,
    required int totalPrice,
  });

  /// Mengkonfirmasi pembayaran pesanan kedai (payment_status → PAID)
  Future<bool> confirmKedaiOrderPayment(String orderCode);
}

/// Implementasi [KedaiKopiRepository]
class KedaiKopiRepositoryImpl implements KedaiKopiRepository {
  @override
  Future<List<MenuModel>> getMenus() async {
    final response = await http
        .get(Uri.parse(ApiConfig.kedaiMenusUrl))
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => MenuModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Gagal memuat menu (HTTP ${response.statusCode})');
  }

  @override
  Future<List<CultureCoupon>> getCoupons() async {
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
    throw Exception('Gagal memuat kupon (HTTP ${response.statusCode})');
  }

  @override
  Future<Map<String, dynamic>?> submitOrder({
    required String orderId,
    required int grossAmount,
    required String customerName,
    required String paymentType,
    required String bank,
    required List<CartItem> items,
  }) async {
    return await PaymentService.createCharge(
      orderId: orderId,
      grossAmount: grossAmount,
      customerName: customerName,
      paymentType: paymentType,
      bank: bank,
      orderType: 'kedai',
      items: items
          .map((i) => {
                'id': i.name,
                'name': i.name,
                'price': i.price,
                'quantity': i.quantity,
              })
          .toList(),
    );
  }

  @override
  Future<Map<String, dynamic>?> createKedaiOrder({
    required String orderCode,
    required String tableNumber,
    required List<CartItem> items,
    required int totalPrice,
  }) async {
    try {
      final payload = jsonEncode({
        'order_code': orderCode,
        'table_number': tableNumber,
        'items': items
            .map((i) => {
                  'name': i.name,
                  'quantity': i.quantity,
                  'price': i.price,
                })
            .toList(),
        'total_price': totalPrice,
      });

      final response = await http
          .post(
            Uri.parse(ApiConfig.kedaiOrdersUrl),
            headers: {'Content-Type': 'application/json'},
            body: payload,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> confirmKedaiOrderPayment(String orderCode) async {
    try {
      final response = await http
          .patch(Uri.parse(ApiConfig.kedaiOrderPayUrl(orderCode)))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
