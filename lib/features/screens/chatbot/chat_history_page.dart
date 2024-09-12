import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mygemini/features/screens/chatbot/controller/chat_controller.dart';
import 'package:mygemini/features/screens/chatbot/controller/chathistory_controller.dart';
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
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text('Chat History',
              style: TextStyle(
                  color: Color(0xFF2C3E50), fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
        ),
        body: Obx(() => controller.chatHistories.isEmpty
            ? _buildEmptyState()
            : _buildChatHistoryList(context)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'No chat history yet',
            style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a new conversation to see it here',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: controller.chatHistories.length,
      itemBuilder: (context, index) {
        // The list is already sorted in the controller, so we can use it directly
        return _buildChatHistoryCard(
            context, controller.chatHistories[index], index);
      },
    );
  }

  Widget _buildChatHistoryCard(
      BuildContext context, ChatHistory chatHistory, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          chatController.loadChat(chatHistory);
          Get.back();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      chatHistory.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF2C3E50),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(context, index),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${chatHistory.messages.length} messages',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Last updated: ${_formatDate(chatHistory.timestamp)}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
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
          title: const Text('Delete Chat History'),
          content:
              const Text('Are you sure you want to delete this chat history?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
