import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mygemini/commonwidgets/custom_actionbuttons.dart';
import 'package:mygemini/commonwidgets/custom_appbar.dart';
import 'package:mygemini/commonwidgets/custom_input_widget.dart';
import 'package:mygemini/commonwidgets/custom_intro_dialog.dart';
import 'package:mygemini/commonwidgets/selectable_markdown.dart';
import 'package:mygemini/features/screens/email_gen/controller/email_controller.dart';
import 'package:mygemini/features/screens/email_gen/model/emailmessage_model.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiEmailBot extends StatefulWidget {
  const AiEmailBot({super.key});

  @override
  _AiEmailBotState createState() => _AiEmailBotState();
}

class _AiEmailBotState extends State<AiEmailBot> {
  final EmailBotController controller = Get.put(EmailBotController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.emailMessages.listen((_) => _scrollToBottom());
    _checkFirstLaunch();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

  void _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunchEmailBot') ?? true;
    if (isFirstLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showEmailComposerIntroDialog();
      });
      await prefs.setBool('isFirstLaunchEmailBot', false);
    }
  }

  void _showEmailComposerIntroDialog() {
    showIntroDialog(context, title: 'Welcome to AI Email Composer!', features: [
      FeatureItem(
        icon: Icons.email_outlined,
        title: 'Guided Email Creation',
        description: 'Step-by-step process for composing professional emails.',
      ),
      FeatureItem(
        icon: Icons.auto_awesome_outlined,
        title: 'AI-Powered Suggestions',
        description: 'Get intelligent suggestions for your email content.',
      ),
      FeatureItem(
        icon: Icons.style_outlined,
        title: 'Multiple Email Styles',
        description: 'Choose from various email styles to fit your needs.',
      ),
      FeatureItem(
        icon: Icons.edit_outlined,
        title: 'Easy Editing',
        description: 'Refine your email with interactive AI assistance.',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: _buildCustomAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildEmailProgress(),
            Expanded(
              child: Obx(() => _buildEmailMessages(context)),
            ),
            _buildEmailStyleSelection(),
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return CustomAppBar(
      title: 'AI Email Composer',
      onResetConversation: () {
        controller.resetConversation();
      },
      onInfoPressed: _showEmailComposerIntroDialog,
    );
  }

  Widget _buildEmailProgress() {
    return Obx(() => LinearProgressIndicator(
          value: controller.emailProgress.value,
          backgroundColor: Colors.grey[300],
          valueColor:
              const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ));
  }

  Widget _buildEmailMessages(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: AppTheme.defaultPadding,
      itemCount: controller.emailMessages.length,
      itemBuilder: (context, index) {
        final message = controller.emailMessages[index];
        return _buildMessageBubble(context, message);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, EmailMessage message) {
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
              isUserMessage ? 'You' : 'EmailBot',
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
            if (message.isEmail)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: CustomActionButtons(
                  text: message.content,
                  shareSubject: 'Generated email from EmailBot Assistant',
                ),
              ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildEmailStyleSelection() {
    return Obx(() {
      if (!controller.showStyleSelection.value) {
        return const SizedBox.shrink();
      }
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: EmailStyle.values.map((style) {
            return ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null // Disable buttons when loading
                  : () => controller.selectEmailStyle(style),
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
              child: Text(style.toString().split('.').last),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildInputArea(BuildContext context) {
    return CustomInputWidget(
      userInputController: controller.userInputController,
      isLoading: controller.isLoading,
      sendMessage: controller.sendMessage,
      isMaxLengthReached: controller.isMaxLengthReached,
      hintText: 'Enter email details...',
    );
  }
}
