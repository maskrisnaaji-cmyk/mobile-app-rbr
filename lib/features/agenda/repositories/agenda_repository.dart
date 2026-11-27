import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/services/user_session.dart';
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

  /// Mengajukan lokakarya / workshop baru oleh user
  Future<Map<String, dynamic>> submitWorkshopProposal({
    required String title,
    required String organizerName,
    required String organizerContact,
    String? organizerEmail,
    String category = 'Lokakarya',
    required String date,
    required String time,
    required String location,
    int price = 0,
    int quota = 25,
    String? description,
    String? image,
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
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic>) {
        if (decoded['data'] is List) {
          list = decoded['data'] as List;
        } else if (decoded['events'] is List) {
          list = decoded['events'] as List;
        } else if (decoded['value'] is List) {
          list = decoded['value'] as List;
        } else {
          list = [];
        }
      } else {
        list = [];
      }

      return list
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
      final userId = UserSession.instance.userId;
      final token = UserSession.instance.token;
      final url = Uri.parse('${ApiConfig.eventsUrl}/$eventId/book');
      final payload = {
        'quantity': quantity,
        if (userId != null) 'user_id': userId,
        if (customerName != null) 'customer_name': customerName,
        if (customerEmail != null) 'customer_email': customerEmail,
        if (orderId != null) 'order_id': orderId,
      };

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> submitWorkshopProposal({
    required String title,
    required String organizerName,
    required String organizerContact,
    String? organizerEmail,
    String category = 'Lokakarya',
    required String date,
    required String time,
    required String location,
    int price = 0,
    int quota = 25,
    String? description,
    String? image,
  }) async {
    final userId = UserSession.instance.userId;
    final token = UserSession.instance.token;
    final response = await http
        .post(
          Uri.parse(ApiConfig.workshopProposalUrl),
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            if (userId != null) 'user_id': userId,
            'title': title,
            'organizer_name': organizerName,
            'organizer_contact': organizerContact,
            'organizer_email': organizerEmail ?? '',
            'category': category,
            'date': date,
            'time': time,
            'location': location,
            'price': price,
            'quota': quota,
            'description': description ?? '',
            'image': image ?? '',
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['message'] ?? 'Gagal mengajukan lokakarya');
    }
  }
}
