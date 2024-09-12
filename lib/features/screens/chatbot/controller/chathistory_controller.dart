import 'dart:convert';
import 'package:get/get.dart';
import 'package:mygemini/data/models/message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHistory {
  final String title;
  final List<Message> messages;
  final DateTime timestamp;
  final List<Map<String, String>>? context;

  ChatHistory({
    required this.title,
    required this.messages,
    required this.timestamp,
    this.context,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'messages': messages.map((m) => m.toJson()).toList(),
        'timestamp': timestamp.toIso8601String(),
        'context': context,
      };

  factory ChatHistory.fromJson(Map<String, dynamic> json) {
    return ChatHistory(
      title: json['title'],
      messages:
          (json['messages'] as List).map((m) => Message.fromJson(m)).toList(),
      timestamp: DateTime.parse(json['timestamp']),
      context: (json['context'] as List?)?.cast<Map<String, String>>(),
    );
  }
}

class ChatHistoryController extends GetxController {
  final RxList<ChatHistory> chatHistories = <ChatHistory>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadChatHistories();
  }

  Future<void> loadChatHistories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedChats = prefs.getStringList('chatHistories');

    if (savedChats != null && savedChats.isNotEmpty) {
      chatHistories.value = savedChats
          .map((json) => ChatHistory.fromJson(jsonDecode(json)))
          .toList();
      _sortChatHistories();
    }
  }

  Future<void> saveChatHistories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _sortChatHistories();
    List<String> encodedChats =
        chatHistories.map((ch) => jsonEncode(ch.toJson())).toList();
    await prefs.setStringList('chatHistories', encodedChats);
  }

  void deleteChatHistory(int index) {
    chatHistories.removeAt(index);
    saveChatHistories();
  }

  void updateChatHistory(ChatHistory chatHistory) {
    int index = chatHistories.indexWhere((ch) => ch.title == chatHistory.title);
    if (index != -1) {
      chatHistories[index] = chatHistory;
    } else {
      chatHistories.add(chatHistory);
    }
    saveChatHistories();
  }

  void _sortChatHistories() {
    chatHistories.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
