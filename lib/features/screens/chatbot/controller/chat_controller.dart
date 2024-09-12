import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygemini/features/screens/chatbot/controller/chathistory_controller.dart';
import 'package:mygemini/data/models/message.dart';
import 'package:mygemini/data/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatController extends GetxController {
  final TextEditingController textC = TextEditingController();
  final RxList<Message> list = <Message>[].obs;
  final RxString userName = ''.obs;
  final ChatHistoryController chatHistoryController =
      Get.find<ChatHistoryController>();
  final RxBool isLoading = false.obs;
  final RxString currentChatId = RxString('');

  // New: Maintain a conversation context
  final RxList<Map<String, String>> conversationContext =
      <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserName();
    ever(list, (_) => saveChatHistory());
  }

  Future<void> loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('username') ?? '';
  }

  void startNewChat() {
    list.clear();
    currentChatId.value = '';
    conversationContext.clear(); // Clear the conversation context
  }

  void addToContext(Map<String, String> message) {
    conversationContext.add(message);
    if (conversationContext.length > 10) {
      // Limit to last 10 messages
      conversationContext.removeAt(0);
    }
  }

  Future<void> askQuestion() async {
    if (textC.text.trim().isNotEmpty) {
      final userMsg = Message(msg: textC.text, msgType: MessageType.user);
      list.add(userMsg);

      // Add user message to conversation context
      conversationContext.add({"role": "user", "content": userMsg.msg});

      textC.clear();

      isLoading.value = true;
      try {
        // Pass the entire conversation context to the API
        String response = await APIs.geminiAPI(conversationContext);
        final botMsg = Message(msg: response, msgType: MessageType.bot);
        list.add(botMsg);

        // Add bot response to conversation context
        conversationContext.add({"role": "assistant", "content": botMsg.msg});
      } catch (e) {
        Get.snackbar('Error', 'Failed to get response: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> saveChatHistory() async {
    if (list.isNotEmpty) {
      final now = DateTime.now();
      final formattedDate = DateFormat('MMM d, yyyy HH:mm').format(now);
      String title = currentChatId.value.isEmpty
          ? "Chat on $formattedDate"
          : currentChatId.value;

      ChatHistory chatHistory = ChatHistory(
        title: title,
        messages: list.toList(),
        timestamp: now,
        context: conversationContext.toList(), // Save the conversation context
      );

      chatHistoryController.updateChatHistory(chatHistory);
      if (currentChatId.value.isEmpty) {
        currentChatId.value = title;
      }
    }
  }

  void loadChat(ChatHistory chatHistory) {
    list.assignAll(chatHistory.messages);
    currentChatId.value = chatHistory.title;
    conversationContext
        .assignAll(chatHistory.context ?? []); // Load the conversation context
  }

  String get chatTitle => currentChatId.value.isEmpty
      ? "New Chat"
      : currentChatId.value.replaceAll("Chat on ", "");

  ChatHistory get currentChatHistory => ChatHistory(
        title: currentChatId.value,
        messages: list.toList(),
        timestamp: DateTime.now(),
        context: conversationContext.toList(),
      );
}
