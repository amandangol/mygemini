import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygemini/data/services/api_service.dart';
import 'package:mygemini/features/screens/code_generator/model/codemessage_model.dart';

class CodeBotController extends GetxController {
  final userInputController = TextEditingController();

  var chatMessages = <ChatMessage>[].obs;
  var isLoading = false.obs;

  var currentState = ConversationState.askingLanguage.obs;
  var language = ''.obs;
  var functionality = ''.obs;
  var additionalDetails = ''.obs;
  var lastGeneratedCode = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _addBotMessage(
        "Hi! I'm CodeBot. What programming language would you like to generate code for?");
  }

  @override
  void onClose() {
    userInputController.dispose();
    super.onClose();
  }

  Future<void> sendMessage() async {
    if (userInputController.text.isEmpty) return;

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
        {"role": "assistant", "content": lastGeneratedCode.value},
        {"role": "user", "content": userMessage}
      ];
      String response = await APIs.geminiAPI(conversationContext);
      _addBotMessage(response);
      _addBotMessage(
          "Is there anything else you'd like to know about the code, or would you like to start a new code generation?");
    }
  }

  void _addUserMessage(String message) {
    chatMessages.add(ChatMessage(content: message, isUser: true));
  }

  void _addBotMessage(String message, {bool isCode = false}) {
    chatMessages
        .add(ChatMessage(content: message, isUser: false, isCode: isCode));
  }

  void resetConversation() {
    chatMessages.clear();
    currentState.value = ConversationState.askingLanguage;
    language.value = '';
    functionality.value = '';
    additionalDetails.value = '';
    lastGeneratedCode.value = '';
    _addBotMessage(
        "Let's start over! What programming language would you like to generate code for?");
  }
}

enum ConversationState {
  askingLanguage,
  askingFunctionality,
  askingDetails,
  generatingCode,
}
