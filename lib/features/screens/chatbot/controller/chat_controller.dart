import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mygemini/data/models/chathistory.dart';
import 'package:mygemini/data/models/message.dart';
import 'package:mygemini/data/services/api_service.dart';
import 'package:mygemini/features/screens/chatbot/controller/chathistory_controller.dart';

class ChatController extends GetxController {
  final TextEditingController textC = TextEditingController();
  final RxList<Message> messages = <Message>[].obs;
  final RxString currentChatTitle = RxString('');
  final RxBool isLoading = false.obs;

  final RxList<Map<String, String>> conversationContext =
      <Map<String, String>>[].obs;

  late final ChatHistoryController chatHistoryController;

  @override
  void onInit() {
    super.onInit();
    chatHistoryController = Get.find<ChatHistoryController>();
    loadLastConversation();
  }

  void loadLastConversation() {
    if (chatHistoryController.chatHistories.isNotEmpty) {
      loadChat(chatHistoryController.chatHistories.first);
    } else {
      currentChatTitle.value = "New Chat";
    }
  }

  Future<void> startNewChat() async {
    await saveChatHistory(); // Save the current chat before starting a new one
    messages.clear();
    currentChatTitle.value = 'New Chat';
    conversationContext.clear();

    // Create and save a new empty chat history
    ChatHistory newChatHistory = ChatHistory(
      title: 'New Chat',
      messages: [],
      timestamp: DateTime.now(),
    );
    await chatHistoryController.saveChatHistory(newChatHistory);

    // Reload chat histories to reflect the new chat
    chatHistoryController.loadChatHistories();
  }

  String _generateMeaningfulTitle() {
    if (messages.isNotEmpty) {
      String firstMessage = messages.first.msg;
      return firstMessage.length > 30
          ? "Chat: ${firstMessage.substring(0, 27)}..."
          : "Chat: $firstMessage";
    }
    return "New Chat";
  }

  Future<void> askQuestion() async {
    final userInput = textC.text.trim();
    if (userInput.isNotEmpty) {
      if (currentChatTitle.value == 'New Chat') {
        currentChatTitle.value = _generateMeaningfulTitle();
      }

      final userMsg = Message(msg: userInput, msgType: MessageType.user);
      messages.add(userMsg);
      conversationContext.add({"role": "user", "content": userMsg.msg});
      textC.clear();

      isLoading.value = true;
      try {
        String response = await APIs.geminiAPI(conversationContext);
        final botMsg = Message(msg: response, msgType: MessageType.bot);
        messages.add(botMsg);
        conversationContext.add({"role": "assistant", "content": botMsg.msg});

        // Save chat history after each message
        await saveChatHistory();
      } catch (e) {
        Get.snackbar('Error', 'Failed to get response: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> saveChatHistory() async {
    if (messages.isNotEmpty || currentChatTitle.value == 'New Chat') {
      ChatHistory chatHistory = ChatHistory(
        title: currentChatTitle.value,
        messages: messages.toList(),
        timestamp: DateTime.now(),
      );

      await chatHistoryController.saveChatHistory(chatHistory);
      chatHistoryController.loadChatHistories(); // Reload to update the list
    }
  }

  void loadChat(ChatHistory chatHistory) {
    messages.clear();
    currentChatTitle.value = chatHistory.title;
    conversationContext.clear();

    for (var message in chatHistory.messages) {
      messages.add(message);
      conversationContext.add({
        "role": message.msgType == MessageType.user ? "user" : "assistant",
        "content": message.msg
      });
    }
  }

  @override
  void onClose() {
    saveChatHistory(); // Save the chat when the controller is closed
    textC.dispose();
    super.onClose();
  }
}
