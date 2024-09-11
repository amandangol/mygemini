import 'package:ai_assistant/data/models/message.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';

class ChatHistory {
  final String title;
  final List<Message> messages;

  ChatHistory({required this.title, required this.messages});

  Map<String, dynamic> toJson() => {
        'title': title,
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory ChatHistory.fromJson(Map<String, dynamic> json) {
    return ChatHistory(
      title: json['title'],
      messages:
          (json['messages'] as List).map((m) => Message.fromJson(m)).toList(),
    );
  }
}

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  List<ChatHistory> _chatHistories = [];

  @override
  void initState() {
    super.initState();
    _loadChatHistories();
  }

  void _loadChatHistories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedChats = prefs.getStringList('chatHistories');

    if (savedChats != null) {
      setState(() {
        _chatHistories = savedChats
            .map((json) => ChatHistory.fromJson(jsonDecode(json)))
            .toList();
      });
    }
  }

  Future<void> _saveChatHistories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedChats =
        _chatHistories.map((ch) => jsonEncode(ch.toJson())).toList();
    await prefs.setStringList('chatHistories', encodedChats);
  }

  void _deleteChatHistory(int index) async {
    setState(() {
      _chatHistories.removeAt(index);
    });
    await _saveChatHistories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Chat History',
            style: TextStyle(color: Color(0xFF2C3E50))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
      ),
      body: _chatHistories.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: _chatHistories.length,
              itemBuilder: (context, index) {
                return _buildChatHistoryCard(_chatHistories[index], index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No chat history yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    )
        .animate()
        .fade(duration: 300.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  Widget _buildChatHistoryCard(ChatHistory chatHistory, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      // shape: RoundedRectangleShape(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          chatHistory.title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
        ),
        subtitle: Text(
          '${chatHistory.messages.length} messages',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _deleteChatHistory(index),
        ),
        onTap: () {
          // Navigate to chat detail page
          // You can implement this page to show all messages in the chat
        },
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }
}
