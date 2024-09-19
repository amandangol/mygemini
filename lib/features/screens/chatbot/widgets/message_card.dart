import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mygemini/commonwidgets/selectable_markdown.dart';
import 'package:mygemini/data/models/message.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';
import 'package:mygemini/utils/timestamp.dart';

class MessageCard extends StatelessWidget {
  final Message message;
  final bool isDarkMode;

  const MessageCard(
      {super.key, required this.message, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final isUserMessage = message.msgType == MessageType.user;
    final isBotMessage = message.msgType == MessageType.bot;
    final isUserImage = message.msgType == MessageType.userImage;

    final bubbleColor = isUserMessage || isUserImage
        ? AppTheme.primaryColor
        : AppTheme.surfaceColor(context);
    final textColor = isUserMessage
        ? Colors.white
        : Theme.of(context).textTheme.bodyLarge!.color!;
    return Align(
      alignment: isBotMessage ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment:
              isBotMessage ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: bubbleColor,
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
                  if (isUserImage && message.imageFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        message.imageFile!,
                        width: 200,
                        // height: 200,
                        fit: BoxFit.contain,
                      ),
                    ).animate().fadeIn(duration: 300.ms).scale(),
                  SizedBox(height: isUserImage ? 8 : 0),
                  SelectableMarkdown(
                    data: message.msg,
                    textColor: textColor,
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
}
