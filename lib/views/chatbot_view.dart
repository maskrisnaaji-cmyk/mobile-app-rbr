import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../theme/colors.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

enum _Sender { user, ai, error }

class _ChatMessage {
  final _Sender sender;
  final String text;
  final String? category;
  final String? relatedInfo;
  final DateTime timestamp;

  _ChatMessage({
    required this.sender,
    required this.text,
    this.category,
    this.relatedInfo,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

// ─── Main View ────────────────────────────────────────────────────────────────

class ChatbotView extends StatefulWidget {
  const ChatbotView({super.key});

  @override
  State<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _inputEnabled = true;

  // Animasi controller untuk typing indicator
  late AnimationController _typingAnimController;
  late Animation<double> _typingAnim;

  // Saran pertanyaan awal
  static const List<String> _suggestions = [
    'Apa saja agenda budaya bulan ini?',
    'Rekomendasikan buku sastra Jawa klasik',
    'Apa itu Napak Tanah Jilid II?',
    'Ceritakan tentang batik Nusantara',
    'Menu signature Kedai Kopi RBR?',
  ];

  @override
  void initState() {
    super.initState();

    // Animasi dot typing
    _typingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _typingAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _typingAnimController, curve: Curves.easeInOut),
    );

    // Pesan sambutan awal dari Ratna AI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addAiMessage(
        text:
            'Sugeng rawuh! 🙏 Saya Ratna AI, Kurator budaya digital Rumah Budaya Ratna.\n\n'
            'Saya siap membantu Anda menjelajahi dunia seni, sastra Nusantara, agenda budaya, '
            'koleksi pustaka, dan kuliner heritage kami.\n\n'
            'Silakan ajukan pertanyaan Anda!',
        category: 'informasi_umum_rbr',
        relatedInfo: '',
      );
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _typingAnimController.dispose();
    super.dispose();
  }

  // ─── Logika Chat ──────────────────────────────────────────────────────────

  void _addAiMessage({
    required String text,
    String? category,
    String? relatedInfo,
    bool isError = false,
  }) {
    setState(() {
      _messages.add(_ChatMessage(
        sender: isError ? _Sender.error : _Sender.ai,
        text: text,
        category: category,
        relatedInfo: (relatedInfo?.trim().isNotEmpty == true) ? relatedInfo : null,
      ));
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final query = _inputController.text.trim();
    if (query.isEmpty || _isLoading) return;

    // Tambahkan bubble pesan user
    setState(() {
      _messages.add(_ChatMessage(sender: _Sender.user, text: query));
      _isLoading = true;
      _inputEnabled = false;
    });
    _inputController.clear();
    _scrollToBottom();

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.aiChatUrl),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({'message': query}),
          )
          .timeout(const Duration(seconds: 30));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final data = body['data'] as Map<String, dynamic>?;

        if (data != null) {
          _addAiMessage(
            text: data['reply_message']?.toString() ??
                'Maaf, respons tidak tersedia.',
            category: data['category']?.toString(),
            relatedInfo: data['related_info']?.toString(),
          );
        } else {
          _addAiMessage(
            text: 'Respons dari server tidak dapat dibaca. Silakan coba lagi.',
            isError: true,
          );
        }
      } else if (response.statusCode == 400) {
        _addAiMessage(
          text: 'Pertanyaan tidak valid. Silakan tulis pertanyaan yang lebih jelas.',
          isError: true,
        );
      } else if (response.statusCode == 503) {
        _addAiMessage(
          text: 'Layanan AI Kurator sedang tidak tersedia. Silakan coba beberapa saat lagi.',
          isError: true,
        );
      } else {
        _addAiMessage(
          text: 'Gagal menghubungi Kurator AI (Error ${response.statusCode}). Periksa koneksi Anda.',
          isError: true,
        );
      }
    } on http.ClientException catch (e) {
      if (!mounted) return;
      _addAiMessage(
        text: 'Tidak dapat terhubung ke server. Pastikan backend berjalan.\n\n(${e.message})',
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;
      _addAiMessage(
        text: 'Terjadi kesalahan tak terduga. Silakan coba lagi.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _inputEnabled = true;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EFE8),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (_isLoading) _buildTypingIndicator(),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.maroon,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          // Avatar Ratna AI
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Text('✦', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ratna AI',
                style: GoogleFonts.lora(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Kurator Budaya Digital',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Indikator online
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4ADE80),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Online',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Tombol clear chat
        IconButton(
          icon: const Icon(Icons.delete_sweep_outlined, size: 20),
          tooltip: 'Bersihkan percakapan',
          onPressed: _messages.isEmpty
              ? null
              : () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: Text('Bersihkan Percakapan?',
                          style: GoogleFonts.lora(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.maroonDark)),
                      content: Text(
                          'Semua riwayat chat akan dihapus dari tampilan.',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5, color: AppColors.greyText)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Batal',
                              style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.greyText,
                                  fontWeight: FontWeight.w600)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _messages.clear());
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.maroon,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Hapus',
                              style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
        ),
      ],
    );
  }

  // ─── Daftar Pesan ─────────────────────────────────────────────────────────

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];

        // Tampilkan label tanggal jika berbeda hari atau item pertama
        final showDateLabel = index == 0 ||
            !_isSameDay(_messages[index - 1].timestamp, msg.timestamp);

        return Column(
          children: [
            if (showDateLabel) _buildDateLabel(msg.timestamp),
            _buildBubble(msg),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Ornamen AI
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.maroon,
                  AppColors.maroon.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.maroon.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Text('✦', style: TextStyle(fontSize: 32, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ratna AI',
            style: GoogleFonts.lora(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.maroonDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Kurator Budaya Digital Rumah Budaya Ratna',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.greyText,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Mulai percakapan dengan salah satu topik:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.greyText,
            ),
          ),
          const SizedBox(height: 12),
          ..._suggestions.map((s) => _buildSuggestionChip(s)),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () {
        _inputController.text = text;
        _sendMessage();
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome_outlined,
                size: 15, color: AppColors.maroon),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: AppColors.darkText,
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 16, color: AppColors.greyText),
          ],
        ),
      ),
    );
  }

  // ─── Bubble Chat ──────────────────────────────────────────────────────────

  Widget _buildBubble(_ChatMessage msg) {
    final isUser = msg.sender == _Sender.user;
    final isError = msg.sender == _Sender.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Avatar AI (kiri)
          if (!isUser) ...[
            _buildAiAvatar(isError: isError),
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
                      ? _buildUserBubbleContent(msg)
                      : _buildAiBubbleContent(msg, isError: isError),
                ),

                // Related Info card (hanya untuk AI, jika ada)
                if (!isUser &&
                    !isError &&
                    msg.relatedInfo != null &&
                    msg.relatedInfo!.isNotEmpty)
                  _buildRelatedInfoCard(msg.relatedInfo!),

                // Timestamp
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 2, right: 2),
                  child: Text(
                    _formatTime(msg.timestamp),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      color: AppColors.greyText.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Avatar User (kanan) — placeholder tipis
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.maroon.withValues(alpha: 0.12),
                border: Border.all(color: AppColors.maroon.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.person, color: AppColors.maroon, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAiAvatar({bool isError = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isError
            ? const Color(0xFFFEE2E2)
            : AppColors.maroon,
        border: Border.all(
          color: isError
              ? const Color(0xFFFCA5A5)
              : AppColors.maroon.withValues(alpha: 0.4),
        ),
      ),
      child: Center(
        child: isError
            ? const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 16)
            : const Text('✦', style: TextStyle(fontSize: 14, color: Colors.white)),
      ),
    );
  }

  Widget _buildUserBubbleContent(_ChatMessage msg) {
    return SelectableText(
      msg.text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13.5,
        color: Colors.white,
        height: 1.5,
      ),
    );
  }

  Widget _buildAiBubbleContent(_ChatMessage msg, {bool isError = false}) {
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
    final info = _categoryInfo(category);
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

  Widget _buildRelatedInfoCard(String info) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.74),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.35)),
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

  // ─── Typing Indicator ─────────────────────────────────────────────────────

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          _buildAiAvatar(),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _typingAnim,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  // Tiap dot punya delay berbeda
                  final delay = i * 0.33;
                  final val = ((_typingAnim.value - delay).clamp(0.0, 1.0));
                  return Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.maroon.withValues(alpha: 0.3 + val * 0.7),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Ratna AI sedang berpikir…',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppColors.greyText.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Input Bar ────────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0
            ? 10
            : (MediaQuery.of(context).padding.bottom > 0
                ? MediaQuery.of(context).padding.bottom + 8
                : 12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFEDE8E0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Tombol saran cepat
          IconButton(
            onPressed: _showSuggestionsSheet,
            icon: const Icon(Icons.auto_awesome_outlined,
                color: AppColors.maroon, size: 22),
            tooltip: 'Saran Pertanyaan',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 6),

          // TextField
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F6F0),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: TextField(
                controller: _inputController,
                enabled: _inputEnabled,
                maxLines: null,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: AppColors.darkText,
                ),
                decoration: InputDecoration(
                  hintText: 'Tanyakan seputar budaya RBR…',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.greyText.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Tombol Kirim
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isLoading
                      ? AppColors.maroon.withValues(alpha: 0.45)
                      : AppColors.maroon,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.maroon.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Sheet Saran ───────────────────────────────────────────────────

  void _showSuggestionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Saran Pertanyaan',
              style: GoogleFonts.lora(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.maroonDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ketuk untuk langsung bertanya',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5, color: AppColors.greyText),
            ),
            const SizedBox(height: 14),
            ..._suggestions.map((s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.auto_awesome_outlined,
                      color: AppColors.maroon, size: 18),
                  title: Text(s,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, color: AppColors.darkText)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _inputController.text = s;
                    _sendMessage();
                  },
                )),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildDateLabel(DateTime dt) {
    final now = DateTime.now();
    String label;
    if (_isSameDay(dt, now)) {
      label = 'Hari ini';
    } else if (_isSameDay(dt, now.subtract(const Duration(days: 1)))) {
      label = 'Kemarin';
    } else {
      label = '${dt.day}/${dt.month}/${dt.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.greyText.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5, color: AppColors.greyText),
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Mengembalikan (label, warna, icon) untuk setiap kategori dari AI
  (String, Color, IconData) _categoryInfo(String category) {
    switch (category) {
      case 'budaya_jawa':
        return ('Budaya Jawa', const Color(0xFF7C3AED), Icons.auto_stories_outlined);
      case 'sastra_nusantara':
        return ('Sastra Nusantara', const Color(0xFF0369A1), Icons.menu_book_outlined);
      case 'kuliner_heritage':
        return ('Kuliner Heritage', const Color(0xFFB45309), Icons.local_cafe_outlined);
      case 'koleksi_pustaka':
        return ('Koleksi Pustaka', const Color(0xFF0F766E), Icons.library_books_outlined);
      case 'agenda_acara':
        return ('Agenda Acara', const Color(0xFF0284C7), Icons.event_outlined);
      case 'sejarah_seni':
        return ('Sejarah Seni', const Color(0xFF9D174D), Icons.palette_outlined);
      case 'informasi_umum_rbr':
        return ('Info RBR', AppColors.maroon, Icons.home_outlined);
      case 'di_luar_topik':
        return ('Di Luar Topik', AppColors.greyText, Icons.help_outline_rounded);
      default:
        return ('Kurator AI', AppColors.maroon, Icons.auto_awesome_outlined);
    }
  }
}

