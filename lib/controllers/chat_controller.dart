import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class ChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final streamingText = ''.obs;
  final isStreaming = false.obs;

  late Box<ChatMessage> _chatBox;

  // ✅ Free Groq API Key — console.groq.com se lo
  static const _apiKey = 'YOUR_API_KEY';
  static const _model = 'llama-3.3-70b-versatile'; // Free & powerful

  @override
  void onInit() {
    super.onInit();
    _initHive();
  }

  Future<void> _initHive() async {
    _chatBox = await Hive.openBox<ChatMessage>('chat_history');
    messages.assignAll(_chatBox.values.toList());
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    _addMessage(userMsg);

    isLoading.value = true;
    isStreaming.value = true;
    streamingText.value = '';

    try {
      // Build history for Groq
      final history = messages.map((m) => {
        'role': m.isUser ? 'user' : 'assistant',
        'content': m.text,
      }).toList();

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful, friendly, and concise AI assistant.',
            },
            ...history,
          ],
          'max_tokens': 1024,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;

        // Simulate streaming effect
        isStreaming.value = true;
        final buffer = StringBuffer();
        for (int i = 0; i < reply.length; i++) {
          buffer.write(reply[i]);
          streamingText.value = buffer.toString();
          await Future.delayed(const Duration(milliseconds: 10));
        }

        isStreaming.value = false;
        _addMessage(ChatMessage(
          text: reply,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        streamingText.value = '';
      } else {
        throw Exception('Status: ${response.statusCode} — ${response.body}');
      }
    } catch (e) {
      isStreaming.value = false;
      _addMessage(ChatMessage(
        text: '⚠️ Error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearChat() async {
    await _chatBox.clear();
    messages.clear();
  }

  void _addMessage(ChatMessage msg) {
    _chatBox.add(msg);
    messages.add(msg);
  }
}