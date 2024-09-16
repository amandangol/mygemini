import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mygemini/commonwidgets/custom_actionbuttons.dart';
import 'package:mygemini/commonwidgets/custom_appbar.dart';
import 'package:mygemini/commonwidgets/custom_input_widget.dart';
import 'package:mygemini/commonwidgets/custom_intro_dialog.dart';
import 'package:mygemini/commonwidgets/selectable_markdown.dart';
import 'package:mygemini/features/screens/trendbased_news_gen/controller/newsletter_controller.dart';
import 'package:mygemini/features/screens/trendbased_news_gen/model/newsletter_model.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrendNewsletterGenerator extends StatefulWidget {
  const TrendNewsletterGenerator({Key? key}) : super(key: key);

  @override
  _TrendNewsletterGeneratorState createState() =>
      _TrendNewsletterGeneratorState();
}

class _TrendNewsletterGeneratorState extends State<TrendNewsletterGenerator> {
  final TrendNewsletterController controller =
      Get.put(TrendNewsletterController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.messages.listen((_) => _scrollToBottom());
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
    _checkFirstLaunch();
  }

  void _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunchTrendNewsBot') ?? true;
    if (isFirstLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showIntroDialog();
      });
      await prefs.setBool('isFirstLaunchTrendNewsBot', false);
    }
  }

  void _showIntroDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomIntroDialog(
          title: 'Welcome to AI Trend Newsletter Generator!',
          features: [
            FeatureItem(
              icon: Icons.trending_up_outlined,
              title: 'Trend Analysis',
              description: 'Get the latest trends in your chosen topic.',
            ),
            FeatureItem(
              icon: Icons.article_outlined,
              title: 'Content Generation',
              description:
                  'AI-powered newsletter content based on current news.',
            ),
            FeatureItem(
              icon: Icons.chat_bubble_outline,
              title: 'Interactive Chat',
              description:
                  'Refine and customize your newsletter through conversation.',
            ),
            FeatureItem(
              icon: Icons.share_outlined,
              title: 'Easy Sharing',
              description: 'Share your generated newsletter with just a tap.',
            ),
          ],
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
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
              child: Obx(() => _buildMessages(context)),
            ),
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return CustomAppBar(
      title: 'AI Trend Newsletter',
      onResetConversation: () {
        controller.resetConversation();
      },
      onInfoPressed: () {
        _showIntroDialog();
      },
    );
  }

  Widget _buildMessages(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: AppTheme.defaultPadding,
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final message = controller.messages[index];
        return _buildMessageBubble(context, message);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, NewsletterMessage message) {
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
              isUserMessage ? 'You' : 'TrendBot',
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
            if (message.isNewsletter)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: CustomActionButtons(
                  text: message.content,
                  shareSubject: 'Generated Newsletter from TrendBot',
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
      hintText: 'Ask TrendBot to generate a newsletter...',
    );
  }
}
