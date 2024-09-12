import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mygemini/commonwidgets/selectable_markdown.dart';
import 'package:mygemini/features/screens/code_generator/controller/codebot_controller.dart';
import 'package:mygemini/features/screens/code_generator/model/codemessage_model.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';
import 'package:share_plus/share_plus.dart';

class AiCodeBot extends StatelessWidget {
  AiCodeBot({Key? key}) : super(key: key);

  final CodeBotController controller = Get.put(CodeBotController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: _buildCustomAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() => _buildChatMessages(context)),
            ),
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.surfaceColor(context),
      elevation: 0,
      title: Text('CodeBot Assistant', style: AppTheme.headlineMedium),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios,
            color: Theme.of(context).iconTheme.color),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            controller.resetConversation();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Conversation has been reset',
                    style: AppTheme.bodyMedium),
                backgroundColor:
                    Theme.of(context).snackBarTheme.backgroundColor,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChatMessages(BuildContext context) {
    return ListView.builder(
      padding: AppTheme.defaultPadding,
      itemCount: controller.chatMessages.length,
      itemBuilder: (context, index) {
        final message = controller.chatMessages[index];
        return _buildMessageBubble(context, message);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    final isUserMessage = message.isUser;
    final bubbleColor =
        isUserMessage ? AppTheme.primaryColor : AppTheme.surfaceColor(context);
    final textColor = isUserMessage
        ? Colors.white
        : Theme.of(context).textTheme.bodyLarge!.color!;

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUserMessage ? 'You' : 'CodeBot',
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            SelectableMarkdown(
              data: message.content, textColor: textColor,

              // You might want to adjust the style of SelectableMarkdown if needed
            ),
            if (message.isCode)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      context: context,
                      icon: Icons.content_copy,
                      label: 'Copy',
                      onPressed: () =>
                          _copyToClipboard(context, message.content),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      context: context,
                      icon: Icons.share,
                      label: 'Share',
                      onPressed: () => _shareContent(message.content),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: AppTheme.defaultPadding,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.userInputController,
              style: AppTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Ask CodeBot to generate code...',
                hintStyle: AppTheme.bodyMedium
                    .copyWith(color: Theme.of(context).hintColor),
                border: Theme.of(context).inputDecorationTheme.border,
                filled: true,
                fillColor: AppTheme.primaryColorLight(context),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(() => _buildSendButton(context)),
        ],
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return ElevatedButton(
      onPressed:
          controller.isLoading.value ? null : () => controller.sendMessage(),
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
      ),
      child: controller.isLoading.value
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.send, size: 24),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code copied to clipboard', style: AppTheme.bodyMedium),
        backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareContent(String text) {
    Share.share(text, subject: 'Generated Code from CodeBot Assistant');
  }
}
