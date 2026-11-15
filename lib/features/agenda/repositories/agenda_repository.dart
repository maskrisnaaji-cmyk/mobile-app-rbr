import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/features/agenda/models/event_model.dart';

/// Kontrak repositori untuk mengambil data agenda / acara
abstract class AgendaRepository {
  /// Mengambil daftar semua agenda dari backend
  Future<List<EventModel>> getEvents();
}

/// Implementasi [AgendaRepository] yang berkomunikasi via HTTP ke backend
class AgendaRepositoryImpl implements AgendaRepository {
  @override
  Future<List<EventModel>> getEvents() async {
    final response = await http.get(Uri.parse(ApiConfig.eventsUrl)).timeout(
          const Duration(seconds: 8),
        );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => EventModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat agenda (HTTP ${response.statusCode})');
    }
  }
}
