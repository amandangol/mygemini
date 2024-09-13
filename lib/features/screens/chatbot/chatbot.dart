import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mygemini/features/screens/chatbot/controller/chat_controller.dart';
import 'package:mygemini/features/screens/chatbot/controller/chathistory_controller.dart';
import 'package:mygemini/features/screens/chatbot/chat_history_page.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';
import 'package:mygemini/widget/message_card.dart';

class Chatbot extends StatefulWidget {
  Chatbot({Key? key}) : super(key: key);

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  late ChatController _c = Get.find<ChatController>();
  late ChatHistoryController _historyC = Get.find<ChatHistoryController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _c = Get.put(ChatController());
    _historyC = Get.find<ChatHistoryController>();
    ever(_c.list, (_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() => _c.list.isEmpty
                  ? _buildEmptyState(context)
                  : _buildChatList(context)),
            ),
            _buildInputSection(context),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Obx(() => Text(
            _c.chatTitle,
            style: AppTheme.headlineMedium.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
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
          icon: Icon(Icons.add_circle_outline,
              color: Colors.white), // Use outlined icon
          onPressed: () => _showNewChatDialog(context),
          tooltip: 'Start New Chat', // Add tooltip for better UX
        ),
        IconButton(
          icon: Icon(Icons.history_edu,
              color: Colors.white), // Use a different history icon
          onPressed: () => Get.to(() => ChatHistoryPage()),
          tooltip: 'Chat History', // Add tooltip for better UX
        ),
        const SizedBox(width: 8), // Add spacing between the icons
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text('Start a new conversation!',
          style: AppTheme.bodyLarge.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          )),
    )
        .animate()
        .fade(duration: 300.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  Widget _buildChatList(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: AppTheme.defaultPadding,
      itemCount: _c.list.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: MessageCard(message: _c.list[index]),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _c.textC,
              onTapOutside: (e) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                fillColor: AppTheme.primaryColorLight(context),
                filled: true,
                hintText: 'Ask me anything...',
                hintStyle: AppTheme.bodyMedium.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              minLines: 1,
              maxLines: 5, // Maximum number of lines as text grows
              keyboardType: TextInputType.multiline, // Allows multi-line input
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => _c.isLoading.value
              ? _buildLoadingIndicator(context)
              : _buildSendButton(context)),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.onPrimary),
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8)
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
        onPressed: () {
          _c.askQuestion();
          _scrollToBottom();
        },
        icon: Icon(
          Icons.rocket_launch_rounded,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1000.ms, color: Colors.white.withOpacity(0.3))
        .shake(hz: 4, curve: Curves.easeInOutCubic);
  }

  void _showNewChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Start New Chat', style: AppTheme.headlineMedium),
          content: Text(
            'Are you sure you want to start a new chat? This will clear the current conversation.',
            style: AppTheme.bodyMedium,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: AppTheme.bodyMedium
                      .copyWith(color: AppTheme.secondaryColor)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Start New Chat',
                  style: AppTheme.bodyMedium.copyWith(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
                _c.startNewChat();
              },
            ),
          ],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      },
    );
  }
}
