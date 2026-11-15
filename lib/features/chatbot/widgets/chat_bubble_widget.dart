import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/colors.dart';
import 'package:mobile_app/features/chatbot/models/chat_message_model.dart';

/// Widget Avatar kurator AI Arunika Dwipantara
class AiAvatarWidget extends StatelessWidget {
  final bool isError;
  final double size;

  const AiAvatarWidget({
    super.key,
    this.isError = false,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isError ? const Color(0xFFFEE2E2) : AppColors.maroon,
        border: Border.all(
          color: isError
              ? const Color(0xFFFCA5A5)
              : AppColors.maroon.withValues(alpha: 0.4),
        ),
      ),
      child: Center(
        child: isError
            ? Icon(Icons.error_outline,
                color: const Color(0xFFDC2626), size: size * 0.5)
            : Text('✦',
                style: TextStyle(
                    fontSize: size * 0.44, color: Colors.white)),
      ),
    );
  }
}

/// Widget komponen UI gelembung chat (chat bubble) untuk percakapan
class ChatBubbleWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatBubbleWidget({
    super.key,
    required this.message,
  });

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Mengembalikan (label, warna, icon) untuk setiap kategori dari AI
  static (String, Color, IconData) categoryInfo(String category) {
    switch (category) {
      case 'budaya_jawa':
        return (
          'Budaya Jawa',
          const Color(0xFF7C3AED),
          Icons.auto_stories_outlined,
        );
      case 'sastra_nusantara':
        return (
          'Sastra Nusantara',
          const Color(0xFF0369A1),
          Icons.menu_book_outlined,
        );
      case 'kuliner_heritage':
        return (
          'Kuliner Heritage',
          const Color(0xFFB45309),
          Icons.local_cafe_outlined,
        );
      case 'koleksi_pustaka':
        return (
          'Koleksi Pustaka',
          const Color(0xFF0F766E),
          Icons.library_books_outlined,
        );
      case 'agenda_acara':
        return (
          'Agenda Acara',
          const Color(0xFF0284C7),
          Icons.event_outlined,
        );
      case 'sejarah_seni':
        return (
          'Sejarah Seni',
          const Color(0xFF9D174D),
          Icons.palette_outlined,
        );
      case 'informasi_umum_rbr':
        return ('Info RBR', AppColors.maroon, Icons.home_outlined);
      case 'di_luar_topik':
        return (
          'Di Luar Topik',
          AppColors.greyText,
          Icons.help_outline_rounded,
        );
      default:
        return (
          'Kurator AI',
          AppColors.maroon,
          Icons.auto_awesome_outlined,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == ChatSender.user;
    final isError = message.sender == ChatSender.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Avatar AI (kiri)
          if (!isUser) ...[
            AiAvatarWidget(isError: isError),
            const SizedBox(width: 8),
          ],

          // Bubble content
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Bubble utama
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.74,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.maroon
                        : isError
                            ? const Color(0xFFFEF2F2)
                            : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: (!isUser)
                        ? Border.all(
                            color: isError
                                ? const Color(0xFFFECACA)
                                : AppColors.lightBorder,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isUser
                      ? _buildUserBubbleContent(message)
                      : _buildAiBubbleContent(context, message, isError: isError),
                ),

                // Related Info card (hanya untuk AI, jika ada)
                if (!isUser &&
                    !isError &&
                    message.relatedInfo != null &&
                    message.relatedInfo!.isNotEmpty)
                  _buildRelatedInfoCard(context, message.relatedInfo!),

                // Timestamp
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 2, right: 2),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      color: AppColors.greyText.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Avatar User (kanan)
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.maroon.withValues(alpha: 0.12),
                border:
                    Border.all(color: AppColors.maroon.withValues(alpha: 0.3)),
              ),
              child:
                  const Icon(Icons.person, color: AppColors.maroon, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserBubbleContent(ChatMessage msg) {
    return SelectableText(
      msg.text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13.5,
        color: Colors.white,
        height: 1.5,
      ),
    );
  }

  Widget _buildAiBubbleContent(
    BuildContext context,
    ChatMessage msg, {
    bool isError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge kategori (hanya jika bukan error & ada kategori)
        if (!isError && msg.category != null && msg.category != 'error')
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: _buildCategoryBadge(msg.category!),
          ),

        // Teks balasan
        SelectableText(
          msg.text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: isError ? const Color(0xFF991B1B) : AppColors.darkText,
            height: 1.55,
          ),
        ),

        // Aksi salin teks
        if (!isError)
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: msg.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Teks disalin',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                    backgroundColor: AppColors.maroon,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_outlined,
                        size: 11,
                        color: AppColors.greyText.withValues(alpha: 0.6)),
                    const SizedBox(width: 3),
                    Text(
                      'Salin',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: AppColors.greyText.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryBadge(String category) {
    final info = categoryInfo(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: info.$2.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: info.$2.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.$3, size: 11, color: info.$2),
          const SizedBox(width: 4),
          Text(
            info.$1,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: info.$2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedInfoCard(BuildContext context, String info) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.74),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 14, color: AppColors.gold),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              info,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: const Color(0xFF92400E),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
