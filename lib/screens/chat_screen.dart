import 'package:flutter/material.dart';
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

  void _scrollToBottom() {
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
      backgroundColor: const Color(0xFF0F0F14),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(context)),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF16161F),
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Iconsax.cpu, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gemini AI',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16,
                )),
              Obx(() => Text(
                _controller.isLoading.value ? 'Typing...' : 'Online',
                style: GoogleFonts.spaceGrotesk(
                  color: _controller.isLoading.value
                      ? const Color(0xFF6C63FF)
                      : const Color(0xFF3ECFCF),
                  fontSize: 11,
                ),
              )),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Iconsax.trash, color: Colors.white54, size: 20),
          onPressed: _showClearDialog,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMessageList(BuildContext context) {
    return Obx(() {
      _scrollToBottom();
      final msgs = _controller.messages;
      final isStreaming = _controller.isStreaming.value;
      final streamText = _controller.streamingText.value;

      return msgs.isEmpty && !isStreaming
          ? _buildEmptyState()
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: msgs.length + (isStreaming ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i == msgs.length && isStreaming) {
                  return _buildStreamingBubble(streamText);
                }
                return _buildMessageBubble(msgs[i],context);
              },
            );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Iconsax.cpu, color: Colors.white, size: 40),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text('Gemini AI Assistant',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700,
            )).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text('Ask me anything...',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white38, fontSize: 14,
            )).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg,BuildContext context) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAvatar(isUser: false),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF8B85FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isUser ? null : const Color(0xFF1E1E2A),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: isUser
                  ? Text(msg.text,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white, fontSize: 14.5, height: 1.5,
                      ))
                  : MarkdownBody(
                      data: msg.text,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.spaceGrotesk(
                          color: Colors.white, fontSize: 14.5, height: 1.5,
                        ),
                        code: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFF3ECFCF),
                          fontSize: 13,
                          backgroundColor: const Color(0xFF0F0F14),
                        ),
                      ),
                    ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _buildAvatar(isUser: true),
        ],
      ),
    );
  }

  Widget _buildStreamingBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAvatar(isUser: false),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: Get.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E2A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: text.isEmpty ? _buildTypingIndicator()
                  : MarkdownBody(
                      data: text,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.spaceGrotesk(
                          color: Colors.white, fontSize: 14.5, height: 1.5,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) =>
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 7, height: 7,
          decoration: const BoxDecoration(
            color: Color(0xFF6C63FF), shape: BoxShape.circle,
          ),
        ).animate(onPlay: (c) => c.repeat())
          .moveY(begin: 0, end: -6,
            delay: Duration(milliseconds: i * 150),
            duration: 400.ms, curve: Curves.easeInOut)
          .then()
          .moveY(begin: -6, end: 0, duration: 400.ms),
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUser
              ? [const Color(0xFF6C63FF), const Color(0xFF8B85FF)]
              : [const Color(0xFF3ECFCF), const Color(0xFF6C63FF)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isUser ? Iconsax.user : Iconsax.cpu,
        color: Colors.white, size: 14,
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF16161F),
        border: Border(top: BorderSide(color: Color(0xFF2A2A38), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2A2A38)),
              ),
              child: TextField(
                controller: _textController,
                style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 14.5),
                maxLines: 4, minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Ask anything...',
                  hintStyle: GoogleFonts.spaceGrotesk(
                    color: Colors.white24, fontSize: 14.5,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(() => GestureDetector(
            onTap: _controller.isLoading.value ? null : () {
              final text = _textController.text;
              if (text.trim().isNotEmpty) {
                _textController.clear();
                _controller.sendMessage(text);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: _controller.isLoading.value
                    ? const LinearGradient(
                        colors: [Color(0xFF2A2A38), Color(0xFF2A2A38)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _controller.isLoading.value ? Iconsax.pause : Iconsax.send_1,
                color: Colors.white, size: 20,
              ),
            ),
          )),
        ],
      ),
    );
  }

  void _showClearDialog() {
    Get.dialog(AlertDialog(
      backgroundColor: const Color(0xFF1E1E2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Clear Chat?',
        style: GoogleFonts.spaceGrotesk(
          color: Colors.white, fontWeight: FontWeight.w700,
        )),
      content: Text('Poori chat history delete ho jaayegi.',
        style: GoogleFonts.spaceGrotesk(color: Colors.white60)),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel',
            style: GoogleFonts.spaceGrotesk(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () { _controller.clearChat(); Get.back(); },
          child: Text('Clear',
            style: GoogleFonts.spaceGrotesk(color: const Color(0xFF6C63FF))),
        ),
      ],
    ));
  }
}
