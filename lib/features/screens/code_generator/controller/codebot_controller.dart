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
  var codeContext = ''.obs;
  var iterationCount = 0.obs;

  static const int maxConversationLength = 50;
  var isMaxLengthReached = false.obs;

  CodeBotController() {
    _initializeController();
  }

  Future<void> _initializeController() async {
    _prefs = await SharedPreferences.getInstance();
    await loadState();
    if (chatMessages.isEmpty) {
      _addBotMessage(
          "Hi! I'm CodeBot. What programming language would you like to generate code for?");
    } else if (currentState.value == ConversationState.generatingCode) {
      _addBotMessage(
          "Welcome back! Would you like to continue working on the previous code or start a new project?");
    }
  }

  Future<void> saveState() async {
    final messagesToSave =
        chatMessages.map((msg) => json.encode(msg.toJson())).toList();
    await _prefs.setStringList('chatMessages', messagesToSave);
    await _prefs.setInt('currentState', currentState.value.index);
    await _prefs.setString('language', language.value);
    await _prefs.setString('functionality', functionality.value);
    await _prefs.setString('additionalDetails', additionalDetails.value);
    await _prefs.setString('lastGeneratedCode', lastGeneratedCode.value);
    await _prefs.setString('codeContext', codeContext.value);
    await _prefs.setInt('iterationCount', iterationCount.value);
  }

  Future<void> loadState() async {
    final savedMessages = _prefs.getStringList('chatMessages');
    if (savedMessages != null) {
      chatMessages.value = savedMessages
          .map((e) => CodeBotMessage.fromJson(json.decode(e)))
          .toList();
    }
    currentState.value =
        ConversationState.values[_prefs.getInt('currentState') ?? 0];
    language.value = _prefs.getString('language') ?? '';
    functionality.value = _prefs.getString('functionality') ?? '';
    additionalDetails.value = _prefs.getString('additionalDetails') ?? '';
    lastGeneratedCode.value = _prefs.getString('lastGeneratedCode') ?? '';
    codeContext.value = _prefs.getString('codeContext') ?? '';
    iterationCount.value = _prefs.getInt('iterationCount') ?? 0;
    _checkMaxLength();
  }

  void _checkMaxLength() {
    isMaxLengthReached.value = chatMessages.length >= maxConversationLength;
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
          await handlePostGenerationInteraction(userMessage);
          break;
      }
    } catch (e) {
      _addBotMessage(
          "I'm sorry, I encountered an error. Can you please try again?");
    } finally {
      isLoading.value = false;
      await saveState();
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
              "Generate ${language.value} code for ${functionality.value}. Include the following details: ${additionalDetails.value}. Generate code only but with comments."
        }
      ];
      String codeContent = await APIs.geminiAPI(conversationContext);

      if (codeContent
          .toLowerCase()
          .contains("content was blocked for safety reasons")) {
        _handleSafetyBlock();
      } else {
        lastGeneratedCode.value = codeContent;
        _addBotMessage(codeContent, isCode: true);
        _addBotMessage(
            "Here's the generated code. Would you like me to explain any part of it, modify it, or start a new code generation?");
      }
    } catch (e) {
      _addBotMessage(
          "I'm sorry, I couldn't generate the code. Can you please try again?");
    }
  }

  void _handleSafetyBlock() {
    _addBotMessage(
        "I apologize, but I cannot generate the requested code due to safety concerns. The content may be potentially harmful or violate ethical guidelines. Could you please modify your request to ensure it's safe and ethical? If you're unsure, feel free to ask for guidance on what's acceptable.");
    currentState.value = ConversationState.askingFunctionality;
    functionality.value = '';
    additionalDetails.value = '';
  }

  Future<void> handlePostGenerationInteraction(String userMessage) async {
    iterationCount.value++;

    try {
      if (userMessage.toLowerCase().contains('refine') ||
          userMessage.toLowerCase().contains('improve')) {
        codeContext.value += "\nUser requested refinement: $userMessage";
        await _refineCode();
      } else if (userMessage.toLowerCase().contains('explain')) {
        await _explainCode(userMessage);
      } else if (userMessage.toLowerCase().contains('modify')) {
        codeContext.value += "\nUser requested modification: $userMessage";
        await _modifyCode(userMessage);
      } else if (userMessage.toLowerCase().contains('new') ||
          userMessage.toLowerCase().contains('start over')) {
        resetConversation();
      } else {
        List<Map<String, String>> conversationContext = [
          {
            "role": "user",
            "content":
                'The user asked: "$userMessage" in response to this code:\n\n${lastGeneratedCode.value}\n\nProvide a helpful response:'
          }
        ];
        String response = await APIs.geminiAPI(conversationContext);

        if (response
            .toLowerCase()
            .contains("content was blocked for safety reasons")) {
          _handleSafetyBlock();
        } else {
          _addBotMessage(response);
          _addBotMessage(
              "Is there anything else you'd like to know about the code, or would you like to start a new code generation?");
        }
      }
    } catch (e) {
      _addBotMessage(
          "I encountered an error while processing your request. Please try again.");
    }
  }

  Future<void> _refineCode() async {
    List<Map<String, String>> conversationContext = [
      {
        "role": "user",
        "content":
            "Refine the following code, considering the context and previous interactions:\n\n${codeContext.value}\n\nCurrent code:\n${lastGeneratedCode.value}"
      }
    ];
    try {
      String refinedCode = await APIs.geminiAPI(conversationContext);
      lastGeneratedCode.value = refinedCode;
      _addBotMessage(refinedCode, isCode: true);
      _addBotMessage(
          "I've refined the code based on our conversation. Would you like to make any further changes?");
    } catch (e) {
      _addBotMessage(
          "I encountered an error while refining the code. Please try again.");
    }
  }

  Future<void> _explainCode(String query) async {
    List<Map<String, String>> conversationContext = [
      {
        "role": "user",
        "content":
            "Explain the following code, focusing on: $query\n\n${lastGeneratedCode.value}"
      }
    ];
    try {
      String explanation = await APIs.geminiAPI(conversationContext);
      _addBotMessage(explanation);
    } catch (e) {
      _addBotMessage(
          "I encountered an error while explaining the code. Please try again.");
    }
  }

  Future<void> _modifyCode(String modification) async {
    List<Map<String, String>> conversationContext = [
      {
        "role": "user",
        "content":
            "Modify the following code according to this request: $modification\n\nCurrent code:\n${lastGeneratedCode.value}"
      }
    ];
    try {
      String modifiedCode = await APIs.geminiAPI(conversationContext);
      lastGeneratedCode.value = modifiedCode;
      _addBotMessage(modifiedCode, isCode: true);
      _addBotMessage(
          "I've modified the code as requested. Is there anything else you'd like to change?");
    } catch (e) {
      _addBotMessage(
          "I encountered an error while modifying the code. Please try again.");
    }
  }

  void _addBotMessage(String message, {bool isCode = false}) {
    chatMessages
        .add(CodeBotMessage(content: message, isUser: false, isCode: isCode));
    saveState();
  }

  void _addUserMessage(String message) {
    chatMessages.add(CodeBotMessage(content: message, isUser: true));
    saveState();
  }

  Future<void> resetConversation() async {
    chatMessages.clear();
    currentState.value = ConversationState.askingLanguage;
    language.value = '';
    functionality.value = '';
    additionalDetails.value = '';
    lastGeneratedCode.value = '';
    codeContext.value = '';
    iterationCount.value = 0;
    isMaxLengthReached.value = false;
    _addBotMessage(
        "Let's start over! What programming language would you like to generate code for?");
    await saveState();
  }
}

enum ConversationState {
  askingLanguage,
  askingFunctionality,
  askingDetails,
  generatingCode,
}
