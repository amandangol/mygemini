import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mygemini/features/screens/chatbot/controller/chat_controller.dart';
import 'package:mygemini/features/screens/chatbot/controller/chathistory_controller.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';
import 'package:intl/intl.dart';

class ChatHistoryPage extends StatelessWidget {
  ChatHistoryPage({Key? key}) : super(key: key);

  final ChatHistoryController controller = Get.find<ChatHistoryController>();
  final ChatController chatController = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        await chatController.saveChatHistory();
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor(context),
        appBar: AppBar(
          title: Text('Chat History', style: AppTheme.headlineSmall),
          backgroundColor: AppTheme.surfaceColor(context),
          elevation: 0,
          iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        ),
        body: Obx(() => controller.chatHistories.isEmpty
            ? _buildEmptyState(context)
            : _buildChatHistoryList(context)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 100, color: Theme.of(context).disabledColor),
          const SizedBox(height: 24),
          Text(
            'No chat history yet',
            style: AppTheme.headlineSmall
                .copyWith(color: Theme.of(context).colorScheme.onBackground),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a new conversation to see it here',
            style: AppTheme.bodyMedium.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(0.7)),
          ),
        ],
      ),
    )
        .animate()
        .fade(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  Widget _buildChatHistoryList(BuildContext context) {
    return ListView.builder(
      padding: AppTheme.defaultPadding,
      itemCount: controller.chatHistories.length,
      itemBuilder: (context, index) {
        return _buildChatHistoryCard(
            context, controller.chatHistories[index], index);
      },
    );
  }

  Widget _buildChatHistoryCard(
      BuildContext context, ChatHistory chatHistory, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.cardDecoration(context),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          chatController.loadChat(chatHistory);
          Get.back();
        },
        child: Padding(
          padding: AppTheme.defaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      chatHistory.title,
                      style: AppTheme.headlineSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error),
                    onPressed: () => _showDeleteConfirmation(context, index),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${chatHistory.messages.length} messages',
                style: AppTheme.bodyMedium.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7)),
              ),
              const SizedBox(height: 4),
              Text(
                'Last updated: ${_formatDate(chatHistory.timestamp)}',
                style: AppTheme.bodySmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5)),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy - HH:mm').format(date);
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Chat History', style: AppTheme.headlineSmall),
          content: Text('Are you sure you want to delete this chat history?',
              style: AppTheme.bodyMedium),
          actions: [
            TextButton(
              child: Text('Cancel', style: AppTheme.bodyMedium),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete',
                  style: AppTheme.bodyMedium
                      .copyWith(color: Theme.of(context).colorScheme.error)),
              onPressed: () {
                controller.deleteChatHistory(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
