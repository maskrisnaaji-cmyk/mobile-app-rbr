import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/services/payment_service.dart';
import 'package:mobile_app/features/kedai_kopi/models/cart_item_model.dart';
import 'package:mobile_app/features/kedai_kopi/models/menu_model.dart';

/// Kontrak repositori untuk fitur Kedai Kopi
abstract class KedaiKopiRepository {
  /// Mengambil daftar menu kedai kopi dari backend
  Future<List<MenuModel>> getMenus();

  /// Mengirim pesanan meja / charge transaksi kedai
  Future<Map<String, dynamic>?> submitOrder({
    required String orderId,
    required int grossAmount,
    required String customerName,
    required String paymentType,
    required String bank,
    required List<CartItem> items,
  });
}

/// Implementasi [KedaiKopiRepository]
class KedaiKopiRepositoryImpl implements KedaiKopiRepository {
  @override
  Future<List<MenuModel>> getMenus() async {
    final response = await http
        .get(Uri.parse(ApiConfig.menusUrl))
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
}
