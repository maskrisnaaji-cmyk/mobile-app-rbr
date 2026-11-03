import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class PaymentService {
  /// Memanggil endpoint POST /api/payment/charge via Midtrans Core API
  static Future<Map<String, dynamic>?> createCharge({
    required String orderId,
    required int grossAmount,
    required String customerName,
    String? customerEmail,
    String? customerPhone,
    required String paymentType, // 'qris' atau 'bank_transfer'
    String bank = 'bca',        // 'bca', 'bni', 'bri', 'mandiri', 'permata'
    String orderType = 'kedai',  // 'kedai' or 'ticket'
    int? eventId,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.paymentChargeUrl);
      final payload = {
        'order_id': orderId,
        'gross_amount': grossAmount,
        'customer_name': customerName,
        'customer_email': customerEmail ?? 'customer@rumahbudayaratna.id',
        'customer_phone': customerPhone ?? '081234567890',
        'payment_type': paymentType,
        'bank': bank,
        'order_type': orderType,
        if (eventId != null) 'event_id': eventId,
        if (items != null) 'items': items,
      };

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('[PaymentService] createCharge error: $e');
      return null;
    }
  }

  /// Cek status transaksi via backend GET /api/payment/status/:orderId
  static Future<Map<String, dynamic>?> checkPaymentStatus(String orderId) async {
    try {
      final url = Uri.parse(ApiConfig.paymentStatusUrl(orderId));
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['status'] != null) {
          return data['status'];
        }
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('[PaymentService] checkPaymentStatus error: $e');
      return null;
    }
  }

  /// Simulasi webhook pembayaran berhasil (Settlement) untuk testing offline / simulator lokal
  static Future<bool> simulateSettlement({
    required String orderId,
    required int grossAmount,
    String paymentType = 'qris',
  }) async {
    try {
      final url = Uri.parse(ApiConfig.paymentNotificationUrl);
      final payload = {
        'order_id': orderId,
        'transaction_status': 'settlement',
        'fraud_status': 'accept',
        'payment_type': paymentType,
        'gross_amount': grossAmount.toString(),
      };

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('[PaymentService] simulateSettlement error: $e');
      return false;
    }
  }
}
