import 'package:flutter/material.dart';
import 'package:mygemini/controllers/chathistory_controller.dart';
import 'package:mygemini/widget/message_card.dart';

class ChatDetailPage extends StatelessWidget {
  final ChatHistory chatHistory;

  const ChatDetailPage({Key? key, required this.chatHistory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chatHistory.title,
            style: const TextStyle(color: Color(0xFF2C3E50))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: chatHistory.messages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MessageCard(message: chatHistory.messages[index]),
          );
        },
      ),
    );
  }
}
