import 'dart:convert';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:mygemini/data/models/message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHistory {
  final String title;
  final List<Message> messages;
  final DateTime timestamp;

  ChatHistory({
    required this.title,
    required this.messages,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'messages': messages.map((m) => m.toJson()).toList(),
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatHistory.fromJson(Map<String, dynamic> json) {
    return ChatHistory(
      title: json['title'],
      messages:
          (json['messages'] as List).map((m) => Message.fromJson(m)).toList(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class ChathistoryController extends GetxService {
  final RxList<ChatHistory> chatHistories = <ChatHistory>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadChatHistories();
  }

  Future<ChathistoryController> init() async {
    await loadChatHistories();
    return this;
  }

  Future<void> loadChatHistories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedChats = prefs.getStringList('chatHistories');

    if (savedChats != null && savedChats.isNotEmpty) {
      chatHistories.value = savedChats
          .map((json) => ChatHistory.fromJson(jsonDecode(json)))
          .toList();
      _sortChatHistories();
      print('Loaded ${chatHistories.length} chat histories');
      for (var i = 0; i < chatHistories.length; i++) {
        print(
            'Loaded chat $i: ${chatHistories[i].title} - ${chatHistories[i].timestamp}');
      }
    } else {
      print('No saved chat histories found');
    }
  }

  Future<void> saveChatHistories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _sortChatHistories();
    List<String> encodedChats =
        chatHistories.map((ch) => jsonEncode(ch.toJson())).toList();
    await prefs.setStringList('chatHistories', encodedChats);
    print('Attempted to save ${chatHistories.length} chat histories');

    // Verify the save operation
    List<String>? savedChats = prefs.getStringList('chatHistories');
    if (savedChats != null) {
      print('Actually saved ${savedChats.length} chat histories');
      for (var i = 0; i < savedChats.length; i++) {
        var decodedChat = jsonDecode(savedChats[i]);
        print(
            'Saved chat $i: ${decodedChat['title']} - ${decodedChat['timestamp']}');
      }
    } else {
      print('Failed to save chat histories');
    }
  }

  void deleteChatHistory(int index) {
    print('Deleting chat history at index $index');
    chatHistories.removeAt(index);
    saveChatHistories();
  }

  void updateChatHistory(ChatHistory chatHistory) {
    print('Updating chat history: ${chatHistory.title}');
    int index = chatHistories.indexWhere((ch) => ch.title == chatHistory.title);
    if (index != -1) {
      chatHistories[index] = chatHistory;
      print('Updated existing chat history at index $index');
    } else {
      chatHistories.add(chatHistory);
      print('Added new chat history. Total count: ${chatHistories.length}');
    }
    saveChatHistories();
  }

  void _sortChatHistories() {
    chatHistories.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
