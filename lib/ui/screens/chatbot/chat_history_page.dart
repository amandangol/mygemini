import 'package:ai_assistant/data/models/message.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  List<Message> _chatHistory = [];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  void _loadChatHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedChat = prefs.getStringList('chatHistory');

    if (savedChat != null) {
      setState(() {
        _chatHistory = savedChat.map((json) => Message.fromJson(json)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
      ),
      body: ListView.builder(
        itemCount: _chatHistory.length,
        itemBuilder: (context, index) {
          final message = _chatHistory[index];
          return ListTile(
            title: Text(message.msg),
            subtitle: Text(message.msgType == MessageType.bot ? 'Bot' : 'User'),
          );
        },
      ),
    );
  }
}
