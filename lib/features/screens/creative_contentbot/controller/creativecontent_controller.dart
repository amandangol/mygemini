import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygemini/data/services/api_service.dart';
import 'package:mygemini/features/screens/creative_contentbot/model/creativemessage_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreativeBotController extends GetxController {
  final userInputController = TextEditingController();

  var messages = <CreativeMessage>[].obs;
  var isLoading = false.obs;
  var currentContentType = ContentType.story.obs;
  var showContentTypeSelection = false.obs;
  late SharedPreferences _prefs;

  static const int maxConversationLength = 50;
  var isMaxLengthReached = false.obs;

  @override
  void onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    _loadConversation();
    if (messages.isEmpty) {
      _addBotMessage(
          "Hi! I'm CreativeBot. What type of content would you like to create today?");
      showContentTypeSelection.value = true;
    }
    _checkMaxLength();
  }

  @override
  void onClose() {
    userInputController.dispose();
    super.onClose();
  }

  void _loadConversation() {
    final savedMessages = _prefs.getStringList('creativeMessages');
    if (savedMessages != null) {
      messages.value = savedMessages
          .map((e) => CreativeMessage.fromJson(json.decode(e)))
          .toList();
      if (messages.length > maxConversationLength) {
        messages.value =
            messages.sublist(messages.length - maxConversationLength);
      }
      currentContentType.value =
          ContentType.values[_prefs.getInt('currentContentType') ?? 0];
      showContentTypeSelection.value =
          _prefs.getBool('showContentTypeSelection') ?? true;
    }
    _checkMaxLength();
  }

  void _checkMaxLength() {
    isMaxLengthReached.value = messages.length >= maxConversationLength;
  }

  Future<void> _saveConversation() async {
    if (messages.length > maxConversationLength) {
      messages.value =
          messages.sublist(messages.length - maxConversationLength);
    }
    await _prefs.setStringList('creativeMessages',
        messages.map((e) => json.encode(e.toJson())).toList());
    await _prefs.setInt('currentContentType', currentContentType.value.index);
    await _prefs.setBool(
        'showContentTypeSelection', showContentTypeSelection.value);
    _checkMaxLength();
  }

  void selectContentType(ContentType type) {
    currentContentType.value = type;
    showContentTypeSelection.value = false;
    _addUserMessage("Create a ${type.toString().split('.').last}");
    _addBotMessage(
        "Great! Let's create a ${type.toString().split('.').last}. What's your idea or prompt?");
  }

  Future<void> sendMessage() async {
    if (userInputController.text.isEmpty || isMaxLengthReached.value) return;

    final userMessage = userInputController.text;
    _addUserMessage(userMessage);
    userInputController.clear();

    isLoading.value = true;

    try {
      await _generateContent(userMessage);
    } catch (e) {
      _addBotMessage(
          "I'm sorry, I encountered an error. Can you please try again?");
    } finally {
      isLoading.value = false;
      await _saveConversation();
    }
  }

  Future<void> _generateContent(String prompt) async {
    _addBotMessage(
        "Alright, I'm working on your ${currentContentType.value.toString().split('.').last} now. Please wait a moment...");

    try {
      List<Map<String, String>> messages = [
        {"role": "user", "content": _buildPrompt(prompt)}
      ];
      String response = await APIs.geminiAPI(messages);
      _addBotMessage(response, isCreativeContent: true);
      _addBotMessage(
          "Here's your generated content. Would you like to create something else?");
      showContentTypeSelection.value = true;
    } catch (e) {
      _addBotMessage(
          "I'm sorry, I couldn't generate the content. Can you please try again?");
    }
  }

  String _buildPrompt(String userPrompt) {
    switch (currentContentType.value) {
      case ContentType.story:
        return 'Generate a short story with a title based on the following prompt: $userPrompt';
      case ContentType.poem:
        return 'Create a poem with a title inspired by the following theme: $userPrompt';
      case ContentType.script:
        return 'Write a short script scene with a title based on the following premise: $userPrompt';
      case ContentType.marketingCopy:
        return 'Generate marketing copy with a title for the following product or service: $userPrompt';
      case ContentType.socialMedia:
        return 'Create a social media post with a title about the following topic: $userPrompt';
    }
  }

  void _addUserMessage(String message) {
    messages.add(CreativeMessage(content: message, isUser: true));
    _saveConversation();
  }

  void _addBotMessage(String message, {bool isCreativeContent = false}) {
    messages.add(CreativeMessage(
        content: message, isUser: false, isCreativeContent: isCreativeContent));
    _saveConversation();
  }

  Future<void> resetConversation() async {
    messages.clear();
    currentContentType.value = ContentType.story;
    showContentTypeSelection.value = true;
    isMaxLengthReached.value = false;

    _addBotMessage(
        "Let's start over! What type of content would you like to create?");
    await _saveConversation();
  }
}

enum ContentType { story, poem, script, marketingCopy, socialMedia }
