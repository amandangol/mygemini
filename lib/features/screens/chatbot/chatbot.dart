import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mygemini/commonwidgets/custom_intro_dialog.dart';
import 'package:mygemini/features/screens/chatbot/controller/chat_controller.dart';
import 'package:mygemini/features/screens/chatbot/controller/chathistory_controller.dart';
import 'package:mygemini/features/screens/chatbot/widgets/message_card.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';
import 'package:mygemini/data/models/chathistory.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final ChatController chatController = Get.find<ChatController>();
  final ChatHistoryController historyController =
      Get.find<ChatHistoryController>();

  @override
  void initState() {
    super.initState();
    historyController.loadChatHistories();
    ever(chatController.messages, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: _buildAppBar(context, isDarkMode),
      drawer: _buildDrawer(context, isDarkMode),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() => chatController.messages.isEmpty
                  ? _buildEmptyState(context, isDarkMode)
                  : _buildChatList(context, isDarkMode)),
            ),
            _buildInputSection(context, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDarkMode) {
    return Drawer(
      child: Container(
        color: isDarkMode ? AppTheme.surfaceColor(context) : Colors.white,
        child: Column(
          children: [
            _buildDrawerHeader(context, isDarkMode),
            Divider(color: isDarkMode ? Colors.white24 : Colors.black12),
            Expanded(
              child: Obx(() => historyController.chatHistories.isEmpty
                  ? _buildEmptyHistoryState(context, isDarkMode)
                  : _buildChatHistoryList(context, isDarkMode)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: isDarkMode ? Colors.white70 : Colors.black12,
                child: const Icon(Icons.chat_bubble,
                    color: AppTheme.primaryColor, size: 30),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                'Chat History',
                style: AppTheme.headlineMedium.copyWith(
                  color: isDarkMode ? Colors.white30 : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: isDarkMode ? Colors.white30 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'No chat history yet',
            style: AppTheme.headlineSmall.copyWith(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your conversations will appear here',
            style: AppTheme.bodyMedium.copyWith(
              color: isDarkMode ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHistoryList(BuildContext context, bool isDarkMode) {
    return ListView.separated(
      itemCount: historyController.chatHistories.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: isDarkMode ? Colors.white12 : Colors.black12,
      ),
      itemBuilder: (context, index) {
        return _buildChatHistoryTile(
            context, historyController.chatHistories[index], isDarkMode);
      },
    );
  }

  Widget _buildChatHistoryTile(
      BuildContext context, ChatHistory chatHistory, bool isDarkMode) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColorLight(context),
        child:
            const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryColor),
      ),
      title: Text(
        chatHistory.title,
        style: AppTheme.bodyLarge.copyWith(
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _formatDate(chatHistory.timestamp),
        style: AppTheme.bodySmall.copyWith(
          color: isDarkMode ? Colors.white54 : Colors.black45,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(
          Icons.delete,
          color: Color.fromARGB(255, 169, 37, 37),
        ),
        onPressed: () {
          historyController.deleteChatHistory(chatHistory.title);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Chat history deleted successfully",
                  style: AppTheme.bodyMedium),
              backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        },
      ),
      onTap: () {
        chatController.loadChat(chatHistory);
        Navigator.pop(context);
      },
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy - HH:mm').format(date);
  }

  AppBar _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      title: Obx(() => Text(
            chatController.currentChatTitle.value,
            style: AppTheme.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          onPressed: () => _showNewChatDialog(context),
          tooltip: 'Start New Chat',
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.white),
          onPressed: () => _showIntroDialog(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showIntroDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomIntroDialog(
          title: 'Welcome to AI Chatbot',
          features: [
            FeatureItem(
              icon: Icons.chat_bubble_outline,
              title: 'AI-Powered Conversations',
              description:
                  'Engage in intelligent conversations with our advanced AI chatbot.',
            ),
            FeatureItem(
              icon: Icons.image_outlined,
              title: 'Image Recognition',
              description: 'Upload images for the AI to analyze and discuss.',
            ),
            FeatureItem(
              icon: Icons.history_outlined,
              title: 'Chat History',
              description:
                  'Access and continue your previous conversations easily.',
            ),
          ],
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 100,
            color: isDarkMode ? Colors.white30 : Colors.black26,
          ),
          const SizedBox(height: 24),
          Text(
            'Start a new conversation!',
            style: AppTheme.headlineSmall.copyWith(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(BuildContext context, bool isDarkMode) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      itemCount: chatController.messages.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: MessageCard(
            message: chatController.messages[index],
            isDarkMode: isDarkMode,
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      // If the ScrollController doesn't have clients yet, wait for the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  Widget _buildInputSection(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        Obx(() => _buildImagePreview(isDarkMode)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.surfaceColor(context) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image, color: AppTheme.primaryColor),
                onPressed: chatController.pickImage,
              ),
              Expanded(
                child: TextFormField(
                  controller: chatController.textC,
                  decoration: InputDecoration(
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    filled: true,
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                        color: isDarkMode ? Colors.white60 : Colors.black45),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                ),
              ),
              const SizedBox(width: 12),
              Obx(() => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryColorLight(context)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: chatController.isLoading.value
                              ? null
                              : () => chatController.askQuestion(),
                          icon: chatController.isLoading.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(Icons.send_rounded,
                                  color: Colors.white),
                        ),
                      ))
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                      duration: 1500.ms, color: Colors.white.withOpacity(0.5))
                  .shake(hz: 4, curve: Curves.easeInOutCubic),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(bool isDarkMode) {
    if (chatController.selectedImage.value == null) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              chatController.selectedImage.value!,
              height: 150,
              // width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: chatController.clearSelectedImage,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale();
  }

  void _showNewChatDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              isDarkMode ? AppTheme.surfaceColor(context) : Colors.white,
          title: Text('Start New Chat',
              style: AppTheme.headlineMedium.copyWith(
                color: isDarkMode ? Colors.white : Colors.black87,
              )),
          content: Text(
            'Are you sure you want to start a new chat? This will clear the current conversation.',
            style: AppTheme.bodyMedium.copyWith(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: AppTheme.bodyMedium
                      .copyWith(color: AppTheme.secondaryColor)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                chatController.startNewChat();
              },
              child: Text('Start New Chat',
                  style: AppTheme.bodyMedium.copyWith(color: Colors.white)),
            ),
          ],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        );
      },
    );
  }

  @override
  void dispose() {
    chatController.saveChatHistory();
    _scrollController.dispose();
    super.dispose();
  }
}
