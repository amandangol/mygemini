import 'package:ai_assistant/controllers/chat_controller.dart';
import 'package:ai_assistant/utils/helper/global.dart';
import 'package:ai_assistant/ui/screens/chatbot/chat_history_page.dart';
import 'package:ai_assistant/widget/message_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatbotFeature extends StatefulWidget {
  const ChatbotFeature({super.key});

  @override
  State<ChatbotFeature> createState() => _ChatbotFeatureState();
}

class _ChatbotFeatureState extends State<ChatbotFeature> {
  final ChatController _c = Get.put(ChatController());

  void _handleCloseChat() async {
    bool? saveChat = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Chat'),
        content: const Text('Do you want to save this chat before closing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (saveChat ?? false) {
      await _c.saveChatHistory();
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with AI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatHistoryPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _handleCloseChat,
          ),
        ],
      ),

      // Send message field & button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Text input field
            Expanded(
              child: TextFormField(
                controller: _c.textC,
                onTapOutside: (e) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  fillColor: theme.colorScheme.background,
                  filled: true,
                  isDense: true,
                  hintText: 'Ask me anything...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: theme.colorScheme.onBackground.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ),
            ),

            // Add some space
            const SizedBox(width: 8),

            // Send button
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.primaryColor,
              child: IconButton(
                onPressed: _c.askQuestion,
                icon: const Icon(
                  Icons.rocket_launch_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),

      // Body
      body: Obx(
        () => ListView.builder(
          padding: EdgeInsets.symmetric(
            vertical: mq.height * 0.02,
            horizontal: 16,
          ),
          itemCount: _c.list.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MessageCard(message: _c.list[index]),
            );
          },
        ),
      ),
    );
  }
}
