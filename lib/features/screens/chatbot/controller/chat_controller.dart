import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mygemini/data/models/chathistory.dart';
import 'package:mygemini/data/models/message.dart';
import 'package:mygemini/data/services/api_service.dart';
import 'package:mygemini/features/screens/chatbot/controller/chathistory_controller.dart';

class ChatController extends GetxController {
  final TextEditingController textC = TextEditingController();
  final RxList<Message> messages = <Message>[].obs;
  final RxString currentChatTitle = RxString('');
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> conversationContext =
      <Map<String, dynamic>>[].obs;
  late final ChatHistoryController chatHistoryController;
  final ImagePicker _picker = ImagePicker();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxList<String> smartSuggestions = <String>[].obs;

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
    await saveChatHistory();
    messages.clear();
    currentChatTitle.value = 'New Chat';
    conversationContext.clear();
    selectedImage.value = null;

    ChatHistory newChatHistory = ChatHistory(
      title: 'New Chat',
      messages: [],
      timestamp: DateTime.now(),
    );
    await chatHistoryController.saveChatHistory(newChatHistory);
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
    final File? imageFile = selectedImage.value;

    if (userInput.isNotEmpty || imageFile != null) {
      if (currentChatTitle.value == 'New Chat') {
        currentChatTitle.value = _generateMeaningfulTitle();
      }

      Message userMsg;
      if (imageFile != null) {
        userMsg = Message(
            msg: userInput,
            msgType: MessageType.userImage,
            imagePath: imageFile.path);
      } else {
        userMsg = Message(msg: userInput, msgType: MessageType.user);
      }
      messages.add(userMsg);

      Map<String, dynamic> contextEntry = {
        "role": "user",
        "content": userMsg.msg
      };
      if (imageFile != null) {
        contextEntry["image"] = imageFile.path;
      }
      conversationContext.add(contextEntry);

      textC.clear();
      clearSelectedImage();

      isLoading.value = true;
      try {
        List<Map<String, String>> apiContext = conversationContext.map((entry) {
          return entry.map((key, value) => MapEntry(key, value.toString()));
        }).toList();

        String response = await APIs.geminiAPI(apiContext);
        final botMsg = Message(msg: response, msgType: MessageType.bot);
        messages.add(botMsg);
        conversationContext.add({"role": "assistant", "content": botMsg.msg});

        await saveChatHistory();
      } catch (e) {
        Get.snackbar('Error', 'Failed to get response: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  void clearSelectedImage() {
    selectedImage.value = null;
  }

  Future<void> saveChatHistory() async {
    if (messages.isNotEmpty || currentChatTitle.value == 'New Chat') {
      ChatHistory chatHistory = ChatHistory(
        title: currentChatTitle.value,
        messages: messages.toList(),
        timestamp: DateTime.now(),
      );

      await chatHistoryController.saveChatHistory(chatHistory);
      chatHistoryController.loadChatHistories();
    }
  }

  void loadChat(ChatHistory chatHistory) {
    messages.clear();
    currentChatTitle.value = chatHistory.title;
    conversationContext.clear();
    selectedImage.value = null;

    for (var message in chatHistory.messages) {
      messages.add(message);
      Map<String, dynamic> contextEntry = {
        "role": message.msgType == MessageType.user ||
                message.msgType == MessageType.userImage
            ? "user"
            : "assistant",
        "content": message.msg
      };
      if (message.msgType == MessageType.userImage &&
          message.imageFile != null) {
        contextEntry["image"] = message.imageFile!.path;
      }
      conversationContext.add(contextEntry);
    }
  }

  @override
  void onClose() {
    saveChatHistory();
    textC.dispose();
    super.onClose();
  }
}
