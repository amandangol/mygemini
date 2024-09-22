import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mygemini/commonwidgets/custom_actionbuttons.dart';
import 'package:mygemini/commonwidgets/custom_appbar.dart';
import 'package:mygemini/commonwidgets/custom_input_widget.dart';
import 'package:mygemini/commonwidgets/custom_intro_dialog.dart';
import 'package:mygemini/commonwidgets/selectable_markdown.dart';
import 'package:mygemini/features/screens/code_generator/controller/codebot_controller.dart';
import 'package:mygemini/features/screens/code_generator/model/codemessage_model.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiCodeBot extends StatefulWidget {
  const AiCodeBot({super.key});

  @override
  _AiCodeBotState createState() => _AiCodeBotState();
}

class _AiCodeBotState extends State<AiCodeBot> {
  late CodeBotController controller;
  late ScrollController _scrollController;
  final String _controllerTag =
      'CodeBotController${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    controller = Get.put(CodeBotController(), tag: _controllerTag);
    _scrollController = ScrollController();
    controller.chatMessages.listen((_) => _scrollToBottom());
    _checkFirstLaunch();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Get.delete<CodeBotController>(tag: _controllerTag);
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunchCodeBot') ?? true;
    if (isFirstLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showIntroDialog();
      });
      await prefs.setBool('isFirstLaunchCodeBot', false);
    }
  }

  void _showIntroDialog() {
    showIntroDialog(
      context,
      title: 'Welcome to AI Code Generator!',
      features: [
        FeatureItem(
          icon: Icons.code_outlined,
          title: 'Polyglot Coding',
          description:
              'Generate code in languages like Python, JavaScript, Java, and more.',
        ),
        FeatureItem(
          icon: Icons.psychology_outlined,
          title: 'Smart Code Creation',
          description:
              'Describe functionality, and let AI craft tailored code solutions.',
        ),
        FeatureItem(
          icon: Icons.chat_outlined,
          title: 'Interactive Refinement',
          description:
              'Refine code through dialog, request modifications, and improvements.',
        ),
        FeatureItem(
          icon: Icons.history_edu_outlined,
          title: 'Learning Assistant',
          description:
              'Get explanations and deepen your programming knowledge.',
        ),
        FeatureItem(
          icon: Icons.refresh_outlined,
          title: 'Fresh Start',
          description:
              'Reset conversations to start new coding projects easily.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: _buildCustomAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() => _buildChatMessages()),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    return CustomAppBar(
      title: 'AI Code Generator',
      onResetConversation: controller.resetConversation,
      onInfoPressed: _showIntroDialog,
    );
  }

  Widget _buildChatMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: AppTheme.defaultPadding,
      itemCount: controller.chatMessages.length,
      itemBuilder: (context, index) {
        final message = controller.chatMessages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(CodeBotMessage message) {
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
          child: const Text("Refine"),
        ),
        ElevatedButton(
          onPressed: () =>
              controller.handlePostGenerationInteraction("Explain this code"),
          child: const Text("Explain"),
        ),
        CustomActionButtons(
          text: codeContent,
          shareSubject: 'Generated Code from Enhanced CodeBot Assistant',
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    return CustomInputWidget(
      userInputController: controller.userInputController,
      isLoading: controller.isLoading,
      sendMessage: () {
        final userInput = controller.userInputController.text;
        if (userInput.isNotEmpty) {
          controller.sendMessage();
        }
      },
      isMaxLengthReached: controller.isMaxLengthReached,
      hintText: 'Ask CodeBot to generate the code...',
    );
  }
}
