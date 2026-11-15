/// Pengirim pesan dalam sesi percakapan chatbot.
enum ChatSender { user, ai, error }

/// Model data untuk sebuah pesan di percakapan kurator AI.
class ChatMessage {
  final ChatSender sender;
  final String text;
  final String? category;
  final String? relatedInfo;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.text,
    this.category,
    this.relatedInfo,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Model respons API dari Kurator AI backend.
class ChatbotResponse {
  final String replyMessage;
  final String? category;
  final String? relatedInfo;

  const ChatbotResponse({
    required this.replyMessage,
    this.category,
    this.relatedInfo,
  });

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    return ChatbotResponse(
      replyMessage: json['reply_message']?.toString() ?? '',
      category: json['category']?.toString(),
      relatedInfo: json['related_info']?.toString(),
    );
  }
}
