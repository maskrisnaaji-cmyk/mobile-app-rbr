import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/services/payment_service.dart';
import 'package:mobile_app/core/services/user_session.dart';

/// Abstract interface untuk operasi pembayaran.
abstract class BookingPaymentRepository {
  Future<Map<String, dynamic>?> createCharge({
    required String orderId,
    required int grossAmount,
    required String customerName,
    String? customerEmail,
    String? customerPhone,
    required String paymentType,
    String bank,
    String orderType,
    int? eventId,
    List<Map<String, dynamic>>? items,
    String? couponCode,
    dynamic userId,
  });

  Future<Map<String, dynamic>?> checkPaymentStatus(String orderId);

  Future<bool> simulateSettlement({
    required String orderId,
    required int grossAmount,
    String paymentType,
  });

  /// Mendaftarkan pesanan kedai baru ke backend (POST /api/kedai/orders)
  Future<Map<String, dynamic>?> createKedaiOrder({
    required String orderCode,
    required String tableNumber,
    required List<Map<String, dynamic>> items,
    required int totalPrice,
  });

  /// Konfirmasi pembayaran pesanan kedai (PATCH /api/kedai/orders/:id/pay)
  Future<bool> confirmKedaiOrderPayment(String orderCode);

  /// Konfirmasi booking tiket agenda ke backend (POST /api/events/:id/book)
  Future<bool> confirmEventBooking({
    required int eventId,
    int quantity = 1,
    String? customerName,
    String? customerEmail,
    String? orderId,
  });
}

/// Implementasi [BookingPaymentRepository] menggunakan [PaymentService].
class BookingPaymentRepositoryImpl implements BookingPaymentRepository {
  @override
  Future<Map<String, dynamic>?> createCharge({
    required String orderId,
    required int grossAmount,
    required String customerName,
    String? customerEmail,
    String? customerPhone,
    required String paymentType,
    String bank = 'bca',
    String orderType = 'ticket',
    int? eventId,
    List<Map<String, dynamic>>? items,
    String? couponCode,
    dynamic userId,
  }) {
    return PaymentService.createCharge(
      orderId: orderId,
      grossAmount: grossAmount,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      paymentType: paymentType,
      bank: bank,
      orderType: orderType,
      eventId: eventId,
      items: items,
      couponCode: couponCode,
      userId: userId,
    );
  }

  @override
  Future<Map<String, dynamic>?> checkPaymentStatus(String orderId) {
    return PaymentService.checkPaymentStatus(orderId);
  }

  @override
  Future<bool> simulateSettlement({
    required String orderId,
    required int grossAmount,
    String paymentType = 'qris',
  }) {
    return PaymentService.simulateSettlement(
      orderId: orderId,
      grossAmount: grossAmount,
      paymentType: paymentType,
    );
  }

  @override
  Future<Map<String, dynamic>?> createKedaiOrder({
    required String orderCode,
    required String tableNumber,
    required List<Map<String, dynamic>> items,
    required int totalPrice,
  }) async {
    try {
      final userId = UserSession.instance.userId;
      final token = UserSession.instance.token;
      final payload = jsonEncode({
        'order_code': orderCode,
        'table_number': tableNumber,
        if (userId != null) 'user_id': userId,
        'items': items,
        'total_price': totalPrice,
      });

      final response = await http
          .post(
            Uri.parse(ApiConfig.kedaiOrdersUrl),
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
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
      final token = UserSession.instance.token;
      final response = await http
          .patch(
            Uri.parse(ApiConfig.kedaiOrderPayUrl(orderCode)),
            headers: {
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> confirmEventBooking({
    required int eventId,
    int quantity = 1,
    String? customerName,
    String? customerEmail,
    String? orderId,
  }) async {
    try {
      final userId = UserSession.instance.userId;
      final token = UserSession.instance.token;
      final url = Uri.parse('${ApiConfig.eventsUrl}/$eventId/book');
      final payload = jsonEncode({
        'quantity': quantity,
        if (userId != null) 'user_id': userId,
        if (customerName != null) 'customer_name': customerName,
        if (customerEmail != null) 'customer_email': customerEmail,
        if (orderId != null) 'order_id': orderId,
      });

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: payload,
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
