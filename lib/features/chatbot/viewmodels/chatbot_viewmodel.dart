import 'package:flutter/foundation.dart';
import 'package:mobile_app/features/chatbot/models/chat_message_model.dart';
import 'package:mobile_app/features/chatbot/repositories/chatbot_repository.dart';

/// ViewModel untuk mengelola state sesi chat Kurator AI.
class ChatbotViewModel extends ChangeNotifier {
  final ChatbotRepository repository;

  ChatbotViewModel({ChatbotRepository? repository})
      : repository = repository ?? ChatbotRepositoryImpl();

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _inputEnabled = true;
  bool get inputEnabled => _inputEnabled;

  /// Saran topik pertanyaan awal
  static const List<String> suggestions = [
    'Apa saja agenda budaya bulan ini?',
    'Rekomendasikan buku sastra Jawa klasik',
    'Apa itu Napak Tanah Jilid II?',
    'Ceritakan tentang batik Nusantara',
    'Menu signature Kedai Kopi RBR?',
  ];

  /// Inisialisasi pesan sambutan awal jika percakapan masih kosong
  void initWelcomeMessage() {
    if (_messages.isNotEmpty) return;
    addAiMessage(
      text:
          'Sugeng rawuh! 🙏 Saya Arunika Dwipantara, Kurator Budaya Digital Rumah Budaya Ratna. '
          'Saya siap membantu Anda menjelajahi dunia seni, sejarah, koleksi pustaka, dan agenda budaya kami. '
          'Silakan ajukan pertanyaan Anda!',
      category: 'informasi_umum_rbr',
      relatedInfo: '',
    );
  }

  /// Menambahkan pesan dari AI atau sistem
  void addAiMessage({
    required String text,
    String? category,
    String? relatedInfo,
    bool isError = false,
  }) {
    _messages.add(ChatMessage(
      sender: isError ? ChatSender.error : ChatSender.ai,
      text: text,
      category: category,
      relatedInfo:
          (relatedInfo?.trim().isNotEmpty == true) ? relatedInfo : null,
    ));
    notifyListeners();
  }

  /// Mengirim pesan dari pengguna ke backend AI
  Future<void> sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty || _isLoading) return;

    // 1. Tambahkan bubble pesan user
    _messages.add(ChatMessage(sender: ChatSender.user, text: query));
    _isLoading = true;
    _inputEnabled = false;
    notifyListeners();

    // 2. Request ke repository
    try {
      final response = await repository.sendMessage(query);
      addAiMessage(
        text: response.replyMessage.isNotEmpty
            ? response.replyMessage
            : 'Maaf, respons tidak tersedia.',
        category: response.category,
        relatedInfo: response.relatedInfo,
      );
    } on ChatbotException catch (e) {
      addAiMessage(
        text: e.message,
        isError: true,
      );
    } catch (_) {
      addAiMessage(
        text: 'Terjadi kesalahan tak terduga. Silakan coba lagi.',
        isError: true,
      );
    } finally {
      _isLoading = false;
      _inputEnabled = true;
      notifyListeners();
    }
  }

  /// Menghapus semua riwayat percakapan dari state
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
