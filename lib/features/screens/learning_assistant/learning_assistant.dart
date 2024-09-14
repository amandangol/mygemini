import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:mygemini/commonwidgets/custom_actionbuttons.dart';
import 'package:mygemini/commonwidgets/custom_appbar.dart';
import 'package:mygemini/commonwidgets/custom_input_widget.dart';
import 'package:mygemini/commonwidgets/selectable_markdown.dart';
import 'package:mygemini/features/screens/learning_assistant/controller/learning_assistant_controller.dart';
import 'package:mygemini/features/screens/learning_assistant/model/learning_asst_model.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';

class LearningChatbot extends StatefulWidget {
  LearningChatbot({Key? key}) : super(key: key);

  @override
  _LearningChatbotState createState() => _LearningChatbotState();
}

class _LearningChatbotState extends State<LearningChatbot> {
  final LearningChatbotController controller =
      Get.put(LearningChatbotController());
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    controller.chatMessages.listen((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

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
    return CustomAppBar(
      title: 'Learning Assistant',
      onResetConversation: () {
        controller.resetConversation();
      },
    );
  }

  Widget _buildChatMessages(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: AppTheme.defaultPadding,
      itemCount: controller.chatMessages.length,
      itemBuilder: (context, index) {
        final message = controller.chatMessages[index];
        return _buildMessageBubble(context, message);
      },
    );
  }

  Widget _buildMessageBubble(
      BuildContext context, LearningAssistModel message) {
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
              isUserMessage ? 'You' : 'Learning Assistant',
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            SelectableMarkdown(
              data: message.content,
              textColor: textColor,
            ),
            if (!isUserMessage)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: CustomActionButtons(
                  text: message.content,
                  shareSubject: 'Important Learning Note',
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildInputArea(BuildContext context) {
    return CustomInputWidget(
      userInputController: controller.userInputController,
      isLoading: controller.isLoading,
      sendMessage: controller.sendMessage,
      isMaxLengthReached: controller.isMaxLengthReached,
      hintText: 'Ask a question or share what you want to learn...',
    );
  }
}
