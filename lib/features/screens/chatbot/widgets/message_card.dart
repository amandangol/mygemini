import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mygemini/data/models/message.dart';
import 'package:mygemini/utils/timestamp.dart';

class MessageCard extends StatelessWidget {
  final Message message;
  final bool isDarkMode;

  const MessageCard(
      {super.key, required this.message, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.msgType == MessageType.bot
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: message.msgType == MessageType.bot
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.msgType == MessageType.userImage &&
                      message.imageFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        message.imageFile!,
                        width: 500,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ).animate().fadeIn(duration: 300.ms).scale(),
                  SizedBox(
                      height: message.msgType == MessageType.userImage ? 8 : 0),
                  Text(
                    message.msg,
                    style: TextStyle(
                      fontSize: 16,
                      color: _getTextColor(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              getTimeAgo(message.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Color _getBackgroundColor() {
    if (message.msgType == MessageType.bot) {
      return isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
    } else {
      return Colors.blue.withOpacity(0.8);
    }
  }

  Color _getTextColor() {
    if (message.msgType == MessageType.bot) {
      return isDarkMode ? Colors.white : Colors.black87;
    } else {
      return Colors.white;
    }
  }
}
