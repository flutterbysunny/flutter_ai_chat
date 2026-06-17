import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_message.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final ChatController _controller = Get.put(ChatController());
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: buildMessageList(context)),
          _buildInputBar(context),
        ],
      ),
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0A0A0F),
      elevation: 0,
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFF1E1E2A)),
      ),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A28),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2E2E45), width: 1),
            ),
            child: const Icon(Iconsax.cpu, color: Color(0xFF7C6FFF), size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Assistant',
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: -0.3,
                ),
              ),
              Obx(() => Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _controller.isLoading.value
                          ? const Color(0xFF7C6FFF)
                          : const Color(0xFF4CAF82),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _controller.isLoading.value ? 'Thinking...' : 'Ready',
                    style: GoogleFonts.dmSans(
                      color: _controller.isLoading.value
                          ? const Color(0xFF7C6FFF)
                          : const Color(0xFF4CAF82),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )),
            ],
          ),
        ],
      ),
      actions: [
        Obx(() => _controller.messages.isEmpty
            ? const SizedBox()
            : IconButton(
          icon: const Icon(Iconsax.trash, color: Color(0xFF555570), size: 18),
          onPressed: _showClearDialog,
          tooltip: 'Clear chat',
        )),
        const SizedBox(width: 4),
      ],
    );
  }

  // ─── Message List ──────────────────────────────────────────────
  Widget buildMessageList(BuildContext context) {
    return Obx(() {
      scrollToBottom();
      final msgs = _controller.messages;
      final isStreaming = _controller.isStreaming.value;
      final streamText = _controller.streamingText.value;

      return msgs.isEmpty && !isStreaming
          ? buildEmptyState()
          : ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: msgs.length + (isStreaming ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (i == msgs.length && isStreaming) {
            return _buildStreamingBubble(context, streamText);
          }
          return buildMessageBubble(context, msgs[i]);
        },
      );
    });
  }

  // ─── Empty State ───────────────────────────────────────────────
  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A28),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF2E2E45), width: 1),
              ),
              child: const Icon(Iconsax.cpu, color: Color(0xFF7C6FFF), size: 32),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text(
              'AI Assistant',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 8),
            Text(
              'Ask me anything — code, questions,\nexplanations, and more.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: const Color(0xFF555570),
                fontSize: 14,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 250.ms),
            const SizedBox(height: 32),
            buildSuggestions(),
          ],
        ),
      ),
    );
  }

  Widget buildSuggestions() {
    final suggestions = [
      ('Write a Flutter widget', Iconsax.code),
      ('Explain async/await', Iconsax.book_1),
      ('Fix my code', Iconsax.magic_star),
    ];
    return Column(
      children: suggestions
          .asMap()
          .entries
          .map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GestureDetector(
          onTap: () => _textController.text = e.value.$1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFF12121C),
              borderRadius: BorderRadius.circular(12),
              border:
              Border.all(color: const Color(0xFF1E1E2A), width: 1),
            ),
            child: Row(
              children: [
                Icon(e.value.$2,
                    color: const Color(0xFF7C6FFF), size: 16),
                const SizedBox(width: 12),
                Text(
                  e.value.$1,
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFFAAAAAA),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Iconsax.arrow_right_3,
                    color: Color(0xFF333350), size: 14),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: 300 + e.key * 80)))
          .toList(),
    );
  }

  // ─── Message Bubble ────────────────────────────────────────────
  Widget buildMessageBubble(BuildContext context, ChatMessage msg) {
    final isUser = msg.isUser;
    final maxW = MediaQuery.of(context).size.width * 0.82;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            buildAvatar(isUser: false),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: maxW),
                  padding: EdgeInsets.symmetric(
                    horizontal: isUser ? 14 : 0,
                    vertical: isUser ? 11 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF1A1A2E) : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isUser
                        ? Border.all(color: const Color(0xFF2A2A45), width: 1)
                        : null,
                  ),
                  child: isUser
                      ? Text(
                    msg.text,
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 14.5,
                      height: 1.55,
                    ),
                  )
                      : buildMarkdown(msg.text),
                ),
                const SizedBox(height: 4),
                Text(
                  formatTime(msg.timestamp),
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFF333350),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.05, end: 0),
          if (isUser) ...[
            const SizedBox(width: 10),
            buildAvatar(isUser: true),
          ],
        ],
      ),
    );
  }

  // ─── Markdown Builder ──────────────────────────────────────────
  Widget buildMarkdown(String data) {
    return MarkdownBody(
      data: data,
      shrinkWrap: true,
      softLineBreak: true,
      builders: {
        'code': _CodeBlockBuilder(),
      },
      styleSheet: MarkdownStyleSheet(
        p: GoogleFonts.dmSans(
          color: const Color(0xFFDDDDEE),
          fontSize: 14.5,
          height: 1.6,
        ),
        h1: GoogleFonts.dmSans(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        h2: GoogleFonts.dmSans(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        h3: GoogleFonts.dmSans(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        strong: GoogleFonts.dmSans(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14.5,
        ),
        em: GoogleFonts.dmSans(
          color: const Color(0xFFCCCCDD),
          fontStyle: FontStyle.italic,
          fontSize: 14.5,
        ),
        code: GoogleFonts.jetBrainsMono(
          color: const Color(0xFF7C6FFF),
          fontSize: 13,
          backgroundColor: const Color(0xFF12121C),
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFF0D0D18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1E1E2A)),
        ),
        codeblockPadding: const EdgeInsets.all(14),
        blockquoteDecoration: BoxDecoration(
          color: const Color(0xFF12121C),
          borderRadius: BorderRadius.circular(8),
          border: const Border(
            left: BorderSide(color: Color(0xFF7C6FFF), width: 3),
          ),
        ),
        blockquotePadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        listBullet: GoogleFonts.dmSans(
          color: const Color(0xFF7C6FFF),
          fontSize: 14.5,
        ),
        tableHead: GoogleFonts.dmSans(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
        ),
        tableBody: GoogleFonts.dmSans(
          color: const Color(0xFFCCCCDD),
          fontSize: 13.5,
        ),
        tableBorder: TableBorder.all(color: const Color(0xFF1E1E2A)),
        blockSpacing: 10,
      ),
    );
  }

  // ─── Streaming Bubble ──────────────────────────────────────────
  Widget _buildStreamingBubble(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildAvatar(isUser: false),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.82,
              ),
              padding: const EdgeInsets.only(top: 4),
              child: text.isEmpty
                  ? _buildTypingIndicator()
                  : buildMarkdown(text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
              (i) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF7C6FFF),
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .moveY(
            begin: 0,
            end: -5,
            delay: Duration(milliseconds: i * 160),
            duration: 380.ms,
            curve: Curves.easeInOut,
          )
              .then()
              .moveY(begin: -5, end: 0, duration: 380.ms),
        ),
      ),
    );
  }

  Widget buildAvatar({required bool isUser}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF1A1A2E) : const Color(0xFF13131F),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: isUser ? const Color(0xFF2A2A45) : const Color(0xFF1E1E2A),
          width: 1,
        ),
      ),
      child: Icon(
        isUser ? Iconsax.user : Iconsax.cpu,
        color: isUser ? const Color(0xFF7C6FFF) : const Color(0xFF4CAF82),
        size: 15,
      ),
    );
  }

  // ─── Input Bar ─────────────────────────────────────────────────
  Widget _buildInputBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0F),
        border: Border(top: BorderSide(color: Color(0xFF1E1E2A), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF12121C),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E1E2A)),
              ),
              child: TextField(
                controller: _textController,
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: 14.5,
                ),
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Message AI Assistant...',
                  hintStyle: GoogleFonts.dmSans(
                    color: const Color(0xFF333350),
                    fontSize: 14.5,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(() => GestureDetector(
            onTap: _controller.isLoading.value
                ? null
                : () {
              final text = _textController.text;
              if (text.trim().isNotEmpty) {
                _textController.clear();
                _controller.sendMessage(text);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _controller.isLoading.value
                    ? const Color(0xFF1A1A28)
                    : const Color(0xFF7C6FFF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                _controller.isLoading.value
                    ? Iconsax.pause
                    : Iconsax.send_1,
                color: _controller.isLoading.value
                    ? const Color(0xFF333350)
                    : Colors.white,
                size: 18,
              ),
            ),
          )),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────
  String formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _showClearDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF12121C),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear Chat',
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        content: Text(
          'All messages will be permanently deleted.',
          style: GoogleFonts.dmSans(
            color: const Color(0xFF888899),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(color: const Color(0xFF555570)),
            ),
          ),
          TextButton(
            onPressed: () {
              _controller.clearChat();
              Get.back();
            },
            child: Text(
              'Delete',
              style: GoogleFonts.dmSans(
                color: const Color(0xFFFF5C5C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Custom Code Block Builder (Scrollable + Copy) ────────────────
class _CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(element, TextStyle? preferredStyle) {
    final code = element.textContent;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E1E2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar with copy button
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF1E1E2A)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'code',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF555570),
                    fontSize: 11,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    Get.snackbar(
                      '',
                      '',
                      titleText: const SizedBox(),
                      messageText: Text(
                        'Copied to clipboard',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      backgroundColor: const Color(0xFF1A1A28),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(12),
                      borderRadius: 10,
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Iconsax.copy,
                          color: Color(0xFF555570), size: 13),
                      const SizedBox(width: 5),
                      Text(
                        'Copy',
                        style: GoogleFonts.dmSans(
                          color: const Color(0xFF555570),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Scrollable code content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(14),
            child: SelectableText(
              code,
              style: GoogleFonts.jetBrainsMono(
                color: const Color(0xFFCCCCEE),
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}