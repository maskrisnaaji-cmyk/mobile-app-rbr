// lib/features/agenda/repositories/presale_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/features/agenda/models/presale_tier_model.dart';

/// Kontrak repositori untuk data presale tiket.
abstract class PresaleRepository {
  /// Mengambil semua tier presale untuk [eventId].
  Future<List<PresaleTierModel>> getPresaleTiers(int eventId);

  /// Mengambil tier presale yang sedang aktif untuk [eventId].
  /// Mengembalikan null jika tidak ada atau 404.
  Future<PresaleTierModel?> getActiveTier(int eventId);

  /// Menjual [quantity] tiket pada tier [tierId].
  /// Mengembalikan map hasil atau map berisi key 'error' jika 409.
  Future<Map<String, dynamic>> sellTickets(int tierId, int quantity);
}

/// Implementasi [PresaleRepository] menggunakan HTTP ke backend.
class PresaleRepositoryImpl implements PresaleRepository {
  final http.Client _client;

  PresaleRepositoryImpl({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<PresaleTierModel>> getPresaleTiers(int eventId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/presale/event/$eventId');
    final response = await _client.get(url).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final dynamic body = jsonDecode(response.body);
      final List<dynamic> list = body is List ? body : (body['data'] as List? ?? []);
      return list
          .map((item) =>
              PresaleTierModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<PresaleTierModel?> getActiveTier(int eventId) async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}/presale/event/$eventId/active');
    final response = await _client.get(url).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final dynamic body = jsonDecode(response.body);
      final Map<String, dynamic> data =
          body is Map<String, dynamic> ? body : (body['data'] as Map<String, dynamic>);
      return PresaleTierModel.fromJson(data);
    }
    if (response.statusCode == 404) return null;
    return null;
  }

  @override
  Future<Map<String, dynamic>> sellTickets(int tierId, int quantity) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/presale/tiers/$tierId/sell');
    final response = await _client
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'quantity': quantity}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    if (response.statusCode == 409) {
      final body = jsonDecode(response.body);
      return {
        'error': (body is Map ? body['message'] : null) ?? 'Kuota habis',
        'status': 409,
      };
    }
    return {
      'error': 'Terjadi kesalahan (HTTP ${response.statusCode})',
      'status': response.statusCode,
    };
  }
}
