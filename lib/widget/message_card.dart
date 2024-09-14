import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mygemini/data/models/message.dart';

class MessageCard extends StatelessWidget {
  final Message message;
  final bool isDarkMode;

  const MessageCard({Key? key, required this.message, required this.isDarkMode})
      : super(key: key);

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
        child: message.msgType == MessageType.user
            ? Text(
                message.msg,
                style: TextStyle(color: Colors.blue[800]),
              )
            : MarkdownBody(
                data: message.msg,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(color: Colors.black87),
                  strong: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.bold),
                  em: TextStyle(
                      color: Colors.black87, fontStyle: FontStyle.italic),
                  code: TextStyle(
                      color: Colors.black87, backgroundColor: Colors.grey[300]),
                  codeblockDecoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
      ),
    );
  }
}
