import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mygemini/commonwidgets/custom_actionbuttons.dart';
import 'package:mygemini/commonwidgets/custom_appbar.dart';
import 'package:mygemini/commonwidgets/custom_input_widget.dart';
import 'package:mygemini/commonwidgets/selectable_markdown.dart';
import 'package:mygemini/features/screens/code_generator/controller/codebot_controller.dart';
import 'package:mygemini/features/screens/code_generator/model/codemessage_model.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';

class AiCodeBot extends StatefulWidget {
  const AiCodeBot({Key? key}) : super(key: key);

  @override
  _AiCodeBotState createState() => _AiCodeBotState();
}

class _AiCodeBotState extends State<AiCodeBot> {
  final CodeBotController controller = Get.put(CodeBotController());
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showScrollToBottomButton =
      ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    controller.chatMessages.listen((_) => _scrollToBottomIfNeeded());
    _scrollController.addListener(_toggleScrollToBottomButton);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_toggleScrollToBottomButton);
    _scrollController.dispose();
    _showScrollToBottomButton.dispose();
    super.dispose();
  }

  void _toggleScrollToBottomButton() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      _showScrollToBottomButton.value = currentScroll < (maxScroll - 200);
    }
  }

  void _scrollToBottomIfNeeded() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      if (maxScroll - currentScroll <= 200) {
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
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
              child: Stack(
                children: [
                  Obx(() => _buildChatMessages(context)),
                  _buildScrollToBottomButton(),
                ],
              ),
            ),
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return CustomAppBar(
      title: 'AI Code Generator',
      onResetConversation: () {
        controller.resetConversation();
      },
    );
  }

  Widget _buildChatMessages(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: AppTheme.defaultPadding,
      itemCount: controller.chatMessages.length,
      itemBuilder: (context, index) {
        final message =
            controller.chatMessages[controller.chatMessages.length - 1 - index];
        return _buildMessageBubble(context, message);
      },
    );
  }

  Widget _buildScrollToBottomButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _showScrollToBottomButton,
      builder: (context, show, child) {
        return AnimatedOpacity(
          opacity: show ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: show
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: FloatingActionButton(
                      mini: true,
                      onPressed: _scrollToBottom,
                      child: const Icon(Icons.arrow_downward),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, CodeBotMessage message) {
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
              data: message.content,
              textColor: textColor,
            ),
            if (message.isCode)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildCodeActionButtons(message.content),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildCodeActionButtons(String codeContent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () =>
              controller.handlePostGenerationInteraction("Refine this code"),
          child: Text("Refine"),
        ),
        ElevatedButton(
          onPressed: () =>
              controller.handlePostGenerationInteraction("Explain this code"),
          child: Text("Explain"),
        ),
        CustomActionButtons(
          text: codeContent,
          shareSubject: 'Generated Code from Enhanced CodeBot Assistant',
        ),
      ],
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return CustomInputWidget(
      userInputController: controller.userInputController,
      isLoading: controller.isLoading,
      sendMessage: () {
        final userInput = controller.userInputController.text;
        if (userInput.isNotEmpty) {
          if (controller.currentState.value ==
              ConversationState.generatingCode) {
            controller.handlePostGenerationInteraction(userInput);
          } else {
            controller.sendMessage();
          }
        }
      },
      isMaxLengthReached: controller.isMaxLengthReached,
      hintText: 'Ask CodeBot to generate the code...',
    );
  }
}
