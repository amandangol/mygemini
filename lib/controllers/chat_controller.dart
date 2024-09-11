import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygemini/controllers/chathistory_controller.dart';
import 'package:mygemini/data/models/message.dart';
import 'package:mygemini/data/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatController extends GetxController {
  final TextEditingController textC = TextEditingController();
  final RxList<Message> list = <Message>[].obs;
  final RxString userName = ''.obs;
  final ChathistoryController chatHistoryController =
      Get.find<ChathistoryController>();
  String? currentChatId;

  @override
  void onInit() {
    super.onInit();
    loadUserName();
  }

  Future<void> loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('username') ?? '';
  }

  void startNewChat() {
    list.clear();
    currentChatId = null;
  }

  void askQuestion() async {
    if (textC.text.trim().isNotEmpty) {
      final userMsg = Message(msg: textC.text, msgType: MessageType.user);
      list.add(userMsg);
      textC.clear();

      // API call
      String response = await APIs.geminiAPI(userMsg.msg);

      final botMsg = Message(msg: response, msgType: MessageType.bot);
      list.add(botMsg);

      // Save chat history after each interaction
      await saveChatHistory();
    }
  }

  Future<void> saveChatHistory() async {
    if (list.isNotEmpty) {
      if (currentChatId == null) {
        final now = DateTime.now();
        final formattedDate = DateFormat('MMM d, yyyy HH:mm').format(now);
        String title = "Chat on $formattedDate";

        // Create ChatHistory object
        ChatHistory chatHistory = ChatHistory(
          title: title,
          messages: list.toList(),
          timestamp: now,
        );

        // Update chat history
        chatHistoryController.updateChatHistory(chatHistory);

        // Debugging
        print(
            'Chat history saved. Total chats: ${chatHistoryController.chatHistories.length}');
        print('Latest chat: ${chatHistory.title}');
      }
    } else {
      print('No messages to save in chat history.');
    }
  }

  void loadChat(ChatHistory chatHistory) {
    list.assignAll(chatHistory.messages);
    currentChatId = chatHistory.title.replaceAll("Chat on ", "");
  }
}
