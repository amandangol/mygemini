import 'package:ai_assistant/data/models/message.dart';
import 'package:ai_assistant/data/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'dart:convert';
import 'package:ai_assistant/data/models/message.dart';

class ChatHistory {
  final String title;
  final List<Message> messages;

  ChatHistory({required this.title, required this.messages});

  Map<String, dynamic> toJson() => {
        'title': title,
        'messages': messages.map((m) => m.toMap()).toList(),
      };

  factory ChatHistory.fromJson(Map<String, dynamic> json) {
    return ChatHistory(
      title: json['title'],
      messages: (json['messages'] as List)
          .map((m) => Message.fromMap(m as Map<String, dynamic>))
          .toList(),
    );
  }

  String encode() => json.encode(toJson());

  static ChatHistory decode(String source) =>
      ChatHistory.fromJson(json.decode(source) as Map<String, dynamic>);
}

class ChatController extends GetxController {
  final TextEditingController textC = TextEditingController();
  final RxList<Message> list = <Message>[].obs;
  final RxString userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserName();
  }

  Future<void> loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('username') ?? '';
  }

  void askQuestion() {
    if (textC.text.trim().isNotEmpty) {
      final userMsg = Message(msg: textC.text, msgType: MessageType.user);
      list.add(userMsg);
      textC.clear();

      // Simulate bot response (replace with actual API call)
      Future.delayed(const Duration(seconds: 1), () async {
        String response = await APIs.geminiAPI(userMsg.msg);

        final botMsg = Message(msg: response, msgType: MessageType.bot);
        list.add(botMsg);
      });
    }
  }

  Future<void> saveChatHistory() async {
    if (list.isNotEmpty) {
      String title = "Chat ${DateTime.now().toIso8601String()}";
      // You can prompt the user for a title here if you want

      ChatHistory chatHistory = ChatHistory(title: title, messages: list);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> savedChats = prefs.getStringList('chatHistories') ?? [];
      savedChats.add(jsonEncode(chatHistory.toJson()));
      await prefs.setStringList('chatHistories', savedChats);

      // Clear the current chat
      list.clear();
    }
  }
}
