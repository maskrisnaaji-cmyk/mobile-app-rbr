import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/features/agenda/models/event_model.dart';

/// Kontrak repositori untuk mengambil data agenda / acara
abstract class AgendaRepository {
  /// Mengambil daftar semua agenda dari backend
  Future<List<EventModel>> getEvents();

  /// Memesan tiket agenda langsung ke backend (POST /api/events/:id/book)
  Future<bool> bookEvent({
    required dynamic eventId,
    int quantity = 1,
    String? customerName,
    String? customerEmail,
    String? orderId,
  });
}

/// Implementasi [AgendaRepository] yang berkomunikasi via HTTP ke backend
class AgendaRepositoryImpl implements AgendaRepository {
  @override
  Future<List<EventModel>> getEvents() async {
    final response = await http
        .get(
          Uri.parse(ApiConfig.eventsUrl),
          headers: {'Cache-Control': 'no-cache'},
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => EventModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat agenda (HTTP ${response.statusCode})');
    }
  }

  @override
  Future<bool> bookEvent({
    required dynamic eventId,
    int quantity = 1,
    String? customerName,
    String? customerEmail,
    String? orderId,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.eventsUrl}/$eventId/book');
      final payload = {
        'quantity': quantity,
        if (customerName != null) 'customer_name': customerName,
        if (customerEmail != null) 'customer_email': customerEmail,
        if (orderId != null) 'order_id': orderId,
      };

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
