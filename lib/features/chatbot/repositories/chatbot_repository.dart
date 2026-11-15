import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/features/chatbot/models/chat_message_model.dart';

/// Exception khusus untuk kesalahan komunikasi dengan Chatbot API.
class ChatbotException implements Exception {
  final String message;
  const ChatbotException(this.message);

  @override
  String toString() => message;
}

/// Abstract contract untuk repositori Chatbot Kurator AI.
abstract class ChatbotRepository {
  Future<ChatbotResponse> sendMessage(String message);
}

/// Implementasi [ChatbotRepository] menggunakan HTTP client dan API Config.
class ChatbotRepositoryImpl implements ChatbotRepository {
  final http.Client _client;

  ChatbotRepositoryImpl({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<ChatbotResponse> sendMessage(String message) async {
    try {
      final response = await _client
          .post(
            Uri.parse(ApiConfig.aiChatUrl),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({'message': message}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final data = body['data'] as Map<String, dynamic>?;

        if (data != null) {
          return ChatbotResponse.fromJson(data);
        } else {
          throw const ChatbotException(
            'Respons dari server tidak dapat dibaca. Silakan coba lagi.',
          );
        }
      } else if (response.statusCode == 400) {
        throw const ChatbotException(
          'Pertanyaan tidak valid. Silakan tulis pertanyaan yang lebih jelas.',
        );
      } else if (response.statusCode == 503) {
        throw const ChatbotException(
          'Layanan AI Kurator sedang tidak tersedia. Silakan coba beberapa saat lagi.',
        );
      } else {
        throw ChatbotException(
          'Gagal menghubungi Kurator AI (Error ${response.statusCode}). Periksa koneksi Anda.',
        );
      }
    } on http.ClientException catch (e) {
      throw ChatbotException(
        'Tidak dapat terhubung ke server. Pastikan backend berjalan.\n\n(${e.message})',
      );
    } on ChatbotException {
      rethrow;
    } catch (_) {
      throw const ChatbotException(
        'Terjadi kesalahan tak terduga. Silakan coba lagi.',
      );
    }
  }
}
