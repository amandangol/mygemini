import 'package:flutter/material.dart';
import 'package:mygemini/data/models/message.dart';

class MessageCard extends StatelessWidget {
  final Message message;

  const MessageCard({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.msgType == MessageType.user
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: message.msgType == MessageType.user
              ? Colors.blue[100]
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.msg,
          style: TextStyle(
            color: message.msgType == MessageType.user
                ? Colors.blue[800]
                : Colors.black87,
          ),
        ),
      ),
    );
  }
}
