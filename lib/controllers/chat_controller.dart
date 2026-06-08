import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message.dart';

class ChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final streamingText = ''.obs;
  final isStreaming = false.obs;

  late Box<ChatMessage> _chatBox;
  late GenerativeModel _model;
  late ChatSession _chat;

  static const _apiKey = 'YOUR_API_KEY_HERE';

  @override
  void onInit() {
    super.onInit();
    _initHive();
    _initGemini();
  }

  Future<void> _initHive() async {
    _chatBox = await Hive.openBox<ChatMessage>('chat_history');
    messages.assignAll(_chatBox.values.toList());
  }

  void _initGemini() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.8,
        maxOutputTokens: 1024,
      ),
      systemInstruction: Content.system(
        'You are a helpful, friendly, and concise AI assistant.',
      ),
    );

    final history = messages.map((m) {
      return Content(m.isUser ? 'user' : 'model', [TextPart(m.text)]);
    }).toList();

    _chat = _model.startChat(history: history);
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
      final response = _chat.sendMessageStream(Content.text(text.trim()));
      final buffer = StringBuffer();

      await for (final chunk in response) {
        buffer.write(chunk.text ?? '');
        streamingText.value = buffer.toString();
      }

      isStreaming.value = false;
      _addMessage(ChatMessage(
        text: buffer.toString(),
        isUser: false,
        timestamp: DateTime.now(),
      ));
      streamingText.value = '';
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
    _initGemini();
  }

  void _addMessage(ChatMessage msg) {
    _chatBox.add(msg);
    messages.add(msg);
  }
}
