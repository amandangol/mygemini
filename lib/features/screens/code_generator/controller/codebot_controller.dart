import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygemini/data/services/api_service.dart';
import 'package:mygemini/features/screens/code_generator/model/codemessage_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CodeBotController extends GetxController {
  final userInputController = TextEditingController();

  var chatMessages = <CodeBotMessage>[].obs;
  var isLoading = false.obs;
  late SharedPreferences _prefs;

  var currentState = ConversationState.askingLanguage.obs;
  var language = ''.obs;
  var functionality = ''.obs;
  var additionalDetails = ''.obs;
  var lastGeneratedCode = ''.obs;

  static const int maxConversationLength = 50;
  var isMaxLengthReached = false.obs;

  @override
  void onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    _loadConversation();
    if (chatMessages.isEmpty) {
      _addBotMessage(
          "Hi! I'm CodeBot. What programming language would you like to generate code for?");
    }
    _checkMaxLength();
  }

  @override
  void onClose() {
    userInputController.dispose();
    super.onClose();
  }

  void _loadConversation() {
    final savedMessages = _prefs.getStringList('chatMessages');
    if (savedMessages != null) {
      chatMessages.value = savedMessages
          .map((e) => CodeBotMessage.fromJson(json.decode(e)))
          .toList();
      if (chatMessages.length > maxConversationLength) {
        chatMessages.value =
            chatMessages.sublist(chatMessages.length - maxConversationLength);
      }
      currentState.value =
          ConversationState.values[_prefs.getInt('currentState') ?? 0];
      language.value = _prefs.getString('language') ?? '';
      functionality.value = _prefs.getString('functionality') ?? '';
      additionalDetails.value = _prefs.getString('additionalDetails') ?? '';
      lastGeneratedCode.value = _prefs.getString('lastGeneratedCode') ?? '';
    }
    _checkMaxLength();
  }

  void _checkMaxLength() {
    isMaxLengthReached.value = chatMessages.length >= maxConversationLength;
  }

  Future<void> _saveConversation() async {
    if (chatMessages.length > maxConversationLength) {
      chatMessages.value =
          chatMessages.sublist(chatMessages.length - maxConversationLength);
    }
    await _prefs.setStringList('chatMessages',
        chatMessages.map((e) => json.encode(e.toJson())).toList());
    await _prefs.setInt('currentState', currentState.value.index);
    await _prefs.setString('language', language.value);
    await _prefs.setString('functionality', functionality.value);
    await _prefs.setString('additionalDetails', additionalDetails.value);
    await _prefs.setString('lastGeneratedCode', lastGeneratedCode.value);
    _checkMaxLength();
  }

  Future<void> sendMessage() async {
    if (userInputController.text.isEmpty || isMaxLengthReached.value) return;

    final userMessage = userInputController.text;
    _addUserMessage(userMessage);
    userInputController.clear();

    isLoading.value = true;

    try {
      switch (currentState.value) {
        case ConversationState.askingLanguage:
          language.value = userMessage;
          currentState.value = ConversationState.askingFunctionality;
          _addBotMessage(
              "Great! Now, what functionality would you like the code to implement?");
          break;
        case ConversationState.askingFunctionality:
          functionality.value = userMessage;
          currentState.value = ConversationState.askingDetails;
          _addBotMessage(
              "Excellent! Any additional details or requirements you'd like to specify?");
          break;
        case ConversationState.askingDetails:
          additionalDetails.value = userMessage;
          currentState.value = ConversationState.generatingCode;
          await _generateCode();
          break;
        case ConversationState.generatingCode:
          await _handlePostGenerationInteraction(userMessage);
          break;
      }
    } catch (e) {
      _addBotMessage(
          "I'm sorry, I encountered an error. Can you please try again?");
    } finally {
      isLoading.value = false;
      await _saveConversation();
    }
  }

  Future<void> _generateCode() async {
    _addBotMessage(
        "Alright, I'm generating the code now. Please wait a moment...");

    try {
      List<Map<String, String>> conversationContext = [
        {
          "role": "user",
          "content":
              "Generate ${language.value} code for ${functionality.value}. Include the following details: ${additionalDetails.value}"
        }
      ];
      String codeContent = await APIs.geminiAPI(conversationContext);
      lastGeneratedCode.value = codeContent;
      _addBotMessage(codeContent, isCode: true);
      _addBotMessage(
          "Here's the generated code. Would you like me to explain any part of it, modify it, or start a new code generation?");
    } catch (e) {
      _addBotMessage(
          "I'm sorry, I couldn't generate the code. Can you please try again?");
    }
  }

  Future<void> _handlePostGenerationInteraction(String userMessage) async {
    if (userMessage.toLowerCase().contains('explain')) {
      _addBotMessage(
          "Certainly! I'd be happy to explain the code. Which part would you like me to elaborate on?");
    } else if (userMessage.toLowerCase().contains('modify')) {
      _addBotMessage(
          "Sure, I can help you modify the code. What changes would you like to make?");
    } else if (userMessage.toLowerCase().contains('new') ||
        userMessage.toLowerCase().contains('start over')) {
      resetConversation();
    } else {
      List<Map<String, String>> conversationContext = [
        {
          "role": "user",
          "content":
              'The user asked: "${userMessage}" in response to this code:\n\n${lastGeneratedCode.value}\n\nProvide a helpful response:'
        }
      ];
      String response = await APIs.geminiAPI(conversationContext);
      _addBotMessage(response);
      _addBotMessage(
          "Is there anything else you'd like to know about the code, or would you like to start a new code generation?");
    }
  }

  void _addUserMessage(String message) {
    chatMessages.add(CodeBotMessage(content: message, isUser: true));
    _saveConversation();
  }

  void _addBotMessage(String message, {bool isCode = false}) {
    chatMessages
        .add(CodeBotMessage(content: message, isUser: false, isCode: isCode));
    _saveConversation();
  }

  Future<void> resetConversation() async {
    chatMessages.clear();
    currentState.value = ConversationState.askingLanguage;
    language.value = '';
    functionality.value = '';
    additionalDetails.value = '';
    lastGeneratedCode.value = '';
    isMaxLengthReached.value = false;
    _addBotMessage(
        "Let's start over! What programming language would you like to generate code for?");
    await _saveConversation();
  }
}

enum ConversationState {
  askingLanguage,
  askingFunctionality,
  askingDetails,
  generatingCode,
}
