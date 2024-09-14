import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mygemini/data/services/api_service.dart';
import 'package:mygemini/features/screens/learning_assistant/model/learning_asst_model.dart';

class LearningChatbotController extends GetxController {
  final userInputController = TextEditingController();
  var chatMessages = <LearningAssistModel>[].obs;
  var isLoading = false.obs;
  var isMaxLengthReached = false.obs;
  late SharedPreferences _prefs;

  static const int maxConversationLength = 50;

  @override
  void onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    await _loadConversation();
    if (chatMessages.isEmpty) {
      _addBotMessage(
          "Hello! I'm your personal learning assistant. What would you like to learn about today?");
    }
    _checkMaxLength();
  }

  Future<void> _loadConversation() async {
    final savedMessages = _prefs.getStringList('learningChatMessages');
    if (savedMessages != null) {
      chatMessages.value = savedMessages
          .map((e) => LearningAssistModel.fromJson(json.decode(e)))
          .toList();
      if (chatMessages.length > maxConversationLength) {
        chatMessages.value =
            chatMessages.sublist(chatMessages.length - maxConversationLength);
      }
    }
  }

  Future<void> _saveConversation() async {
    if (chatMessages.length > maxConversationLength) {
      chatMessages.value =
          chatMessages.sublist(chatMessages.length - maxConversationLength);
    }
    await _prefs.setStringList('learningChatMessages',
        chatMessages.map((e) => json.encode(e.toJson())).toList());
  }

  Future<void> sendMessage() async {
    if (userInputController.text.isEmpty || isMaxLengthReached.value) return;

    final userMessage = userInputController.text;
    _addUserMessage(userMessage);
    userInputController.clear();

    isLoading.value = true;

    try {
      List<Map<String, String>> conversationContext = [
        {
          "role": "system",
          "content":
              "You are a personalized learning assistant. Your goal is to help users learn new topics, answer their questions, and provide explanations tailored to their level of understanding. Always be encouraging and supportive."
        },
        ...chatMessages
            .map((msg) => {
                  "role": msg.isUser ? "user" : "assistant",
                  "content": msg.content
                })
            .toList(),
        {"role": "user", "content": userMessage}
      ];

      final botResponse = await APIs.geminiAPI(conversationContext);
      _addBotMessage(botResponse);
    } catch (e) {
      _addBotMessage("I encountered an error. Please try again.");
    } finally {
      isLoading.value = false;
      _checkMaxLength();
    }
  }

  void _addUserMessage(String message) {
    chatMessages.add(LearningAssistModel(content: message, isUser: true));
    _saveConversation();
  }

  void _addBotMessage(String message, {bool isImportant = false}) {
    chatMessages.add(LearningAssistModel(
        content: message, isUser: false, isImportant: isImportant));
    _saveConversation();
  }

  Future<void> resetConversation() async {
    chatMessages.clear();
    _addBotMessage("Let's start fresh! What would you like to learn about?");
    isMaxLengthReached.value = false;
    await _saveConversation();
  }

  void _checkMaxLength() {
    isMaxLengthReached.value = chatMessages.length >= maxConversationLength;
  }
}
