import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mygemini/commonwidgets/custom_actionbuttons.dart';
import 'package:mygemini/commonwidgets/custom_appbar.dart';
import 'package:mygemini/commonwidgets/custom_input_widget.dart';
import 'package:mygemini/commonwidgets/custom_intro_dialog.dart';
import 'package:mygemini/commonwidgets/selectable_markdown.dart';
import 'package:mygemini/features/screens/creative_contentbot/controller/creativecontent_controller.dart';
import 'package:mygemini/features/screens/creative_contentbot/model/creativemessage_model.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreativeBotView extends StatefulWidget {
  const CreativeBotView({super.key});

  @override
  _CreativeBotViewState createState() => _CreativeBotViewState();
}

class _CreativeBotViewState extends State<CreativeBotView> {
  final CreativeBotController controller = Get.put(CreativeBotController());
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    controller.messages.listen((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });
    _checkFirstLaunch();
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunchCreativeBot') ?? true;
    if (isFirstLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showIntroDialog();
      });
      await prefs.setBool('isFirstLaunchCreativeBot', false);
    }
  }

  void _showIntroDialog() {
    showIntroDialog(context,
        title: 'Welcome to AI Content Creator!',
        features: [
          FeatureItem(
            icon: Icons.create_outlined,
            title: 'Multiple Content Types',
            description:
                'Create stories, poems, scripts, marketing copy, and social media posts.',
          ),
          FeatureItem(
            icon: Icons.chat_outlined,
            title: 'Interactive Conversations',
            description: 'Chat with the AI to refine and perfect your content',
          ),
          FeatureItem(
            icon: Icons.refresh,
            title: 'Easy Reset',
            description: 'Start over anytime with a fresh conversation.',
          ),
          FeatureItem(
            icon: Icons.share_outlined,
            title: 'Share Your Creations',
            description: 'Easily share or copy your generated content.',
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
            Expanded(
              child: _buildMessages(context),
            ),
            _buildContentTypeSelection(context),
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContentTypeSelection(BuildContext context) {
    return Obx(() {
      if (!controller.showContentTypeSelection.value) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: ContentType.values.map((type) {
            return ElevatedButton(
              onPressed: () => controller.selectContentType(type),
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
              child: Text(type.toString().split('.').last),
            );
          }).toList(),
        ),
      );
    });
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return CustomAppBar(
      title: 'AI Content Creator',
      onResetConversation: () {
        controller.resetConversation();
      },
      onInfoPressed: _showIntroDialog,
    );
  }

  Widget _buildMessages(BuildContext context) {
    return Obx(() => ListView.builder(
          controller: _scrollController,
          padding: AppTheme.defaultPadding,
          itemCount: controller.messages.length,
          itemBuilder: (context, index) {
            final message = controller.messages[index];
            return _buildMessageBubble(context, message);
          },
        ));
  }

  Widget _buildMessageBubble(BuildContext context, CreativeMessage message) {
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
              isUserMessage ? 'You' : 'CreativeBot',
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
            if (message.isCreativeContent)
              Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: CustomActionButtons(
                    text: message.content,
                    shareSubject:
                        'Generated content from CreativeBot Assistant',
                  )),
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
      hintText: 'Ask CreativeBot to generate content...',
    );
  }
}
