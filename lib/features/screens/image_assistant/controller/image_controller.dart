import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mygemini/data/services/api_service.dart';
import 'package:mygemini/features/screens/image_assistant/model/image_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrendNewsletterController extends GetxController {
  final userInputController = TextEditingController();

  var messages = <NewsletterMessage>[].obs;
  var isLoading = false.obs;
  late SharedPreferences _prefs;

  var currentState = NewsletterState.askingTopic.obs;
  var topic = ''.obs;
  var lastGeneratedNewsletter = ''.obs;

  static const int maxConversationLength = 50;
  var isMaxLengthReached = false.obs;

  final String newsApiKey = '84219bc9ca0e4a23a31fd60244709fe5';

  @override
  void onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    await _loadConversation();
    if (messages.isEmpty) {
      _addBotMessage(
          "Hi! I'm TrendBot. I can help you generate newsletters based on current news trends. What topic would you like to create a newsletter about?");
    }
    _checkMaxLength();
  }

  @override
  void onClose() {
    userInputController.dispose();
    super.onClose();
  }

  Future<void> _loadConversation() async {
    final savedMessages = _prefs.getStringList('newsletterMessages');
    if (savedMessages != null) {
      messages.value = savedMessages
          .map((e) => NewsletterMessage.fromJson(json.decode(e)))
          .toList();
      if (messages.length > maxConversationLength) {
        messages.value =
            messages.sublist(messages.length - maxConversationLength);
      }
      currentState.value =
          NewsletterState.values[_prefs.getInt('currentState') ?? 0];
      topic.value = _prefs.getString('topic') ?? '';
      lastGeneratedNewsletter.value =
          _prefs.getString('lastGeneratedNewsletter') ?? '';
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
    await _prefs.setStringList('newsletterMessages',
        messages.map((e) => json.encode(e.toJson())).toList());
    await _prefs.setInt('currentState', currentState.value.index);
    await _prefs.setString('topic', topic.value);
    await _prefs.setString(
        'lastGeneratedNewsletter', lastGeneratedNewsletter.value);
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
        case NewsletterState.askingTopic:
          topic.value = userMessage;
          currentState.value = NewsletterState.generatingNewsletter;
          await _generateNewsletter();
          break;
        case NewsletterState.generatingNewsletter:
          await _handlePostGenerationInteraction(userMessage);
          break;
      }
    } catch (e) {
      _addBotMessage(
          "I'm sorry, I encountered an error. Can you please try again?");
    } finally {
      isLoading.value = false;
      await _saveConversation(); // Save after each interaction
    }
  }

  Future<void> _generateNewsletter() async {
    _addBotMessage(
        "Certainly! I'm fetching the latest news about ${topic.value}. Please wait a moment...");

    try {
      final newsData = await _fetchNewsData(topic.value);

      List<Map<String, String>> prompt = [
        {
          "role": "user",
          "content": """
Generate a newsletter about ${topic.value} based on the following current news:

$newsData

Create sections for the most relevant and interesting stories along with date. Include brief summaries and any notable trends or patterns you observe.
          """
        }
      ];

      String newsletterContent = await APIs.geminiAPI(prompt);
      lastGeneratedNewsletter.value = newsletterContent;
      _addBotMessage(newsletterContent, isNewsletter: true);
      _addBotMessage(
          "Here's your generated newsletter based on current news. Would you like me to explain any part of it, modify it, or start a new newsletter?");
    } catch (e) {
      _addBotMessage(
          "I'm sorry, I couldn't generate the newsletter. Can you please try again?");
    }
  }

  Future<String> _fetchNewsData(String topic) async {
    final url =
        'https://newsapi.org/v2/everything?q=$topic&sortBy=publishedAt&apiKey=$newsApiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final articles = jsonData['articles'] as List;

      String newsData = articles
          .take(5)
          .map((article) => "Title: ${article['title']}\n"
              "Description: ${article['description']}\n"
              "Source: ${article['source']['name']}\n"
              "Published: ${article['publishedAt']}\n\n")
          .join();

      return newsData;
    } else {
      throw Exception('Failed to load news data');
    }
  }

  Future<void> _handlePostGenerationInteraction(String userMessage) async {
    if (userMessage.toLowerCase().contains('explain')) {
      _addBotMessage(
          "Certainly! I'd be happy to explain the newsletter. Which part would you like me to elaborate on?");
    } else if (userMessage.toLowerCase().contains('modify')) {
      _addBotMessage(
          "Sure, I can help you modify the newsletter. What changes would you like to make?");
    } else if (userMessage.toLowerCase().contains('new') ||
        userMessage.toLowerCase().contains('start over')) {
      _startNewNewsletter();
    } else {
      List<Map<String, String>> prompt = [
        {
          "role": "user",
          "content":
              'The user asked: "${userMessage}" in response to this newsletter:\n\n${lastGeneratedNewsletter.value}\n\nProvide a helpful response:'
        }
      ];
      String response = await APIs.geminiAPI(prompt);
      _addBotMessage(response);
      _addBotMessage(
          "Is there anything else you'd like to know about the newsletter, or would you like to start a new one?");
    }
  }

  void _startNewNewsletter() {
    currentState.value = NewsletterState.askingTopic;
    topic.value = '';
    lastGeneratedNewsletter.value = '';
    _addBotMessage("What topic would you like for the new newsletter?");
  }

  Future<void> resetConversation() async {
    messages.clear();
    currentState.value = NewsletterState.askingTopic;
    topic.value = '';
    lastGeneratedNewsletter.value = '';
    isMaxLengthReached.value = false;
    _addBotMessage(
        "Let's start over! What topic would you like to create a newsletter about?");
    await _saveConversation(); // Save the reset state
  }

  void _addUserMessage(String message) {
    messages.add(NewsletterMessage(content: message, isUser: true));
    _saveConversation();
  }

  void _addBotMessage(String message, {bool isNewsletter = false}) {
    messages.add(NewsletterMessage(
        content: message, isUser: false, isNewsletter: isNewsletter));
    _saveConversation();
  }
}

enum NewsletterState {
  askingTopic,
  generatingNewsletter,
}
