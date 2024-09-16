import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:mygemini/commonwidgets/custom_actionbuttons.dart';
import 'package:mygemini/commonwidgets/custom_appbar.dart';
import 'package:mygemini/commonwidgets/custom_input_widget.dart';
import 'package:mygemini/commonwidgets/custom_intro_dialog.dart';
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

  void _showIntroDialog() {
    showIntroDialog(
      context,
      title: 'Welcome to AI Learning Assistant!',
      features: [
        FeatureItem(
          icon: Icons.school_outlined,
          title: 'Personalized Learning',
          description:
              'Get tailored explanations and answers to your questions.',
        ),
        FeatureItem(
          icon: Icons.psychology_outlined,
          title: 'Concept Exploration',
          description: 'Dive deep into topics and explore new ideas.',
        ),
        FeatureItem(
          icon: Icons.tips_and_updates_outlined,
          title: 'Study Tips',
          description:
              'Receive effective study strategies and memory techniques.',
        ),
        FeatureItem(
          icon: Icons.quiz_outlined,
          title: 'Practice Questions',
          description: 'Test your knowledge with interactive quizzes.',
        ),
      ],
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
              child: Obx(() => _buildChatMessages(context)),
            ),
            _buildFeatureButtons(context),
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return CustomAppBar(
      title: 'AI Learning Assistant',
      onResetConversation: () {
        controller.resetConversation();
      },
      onInfoPressed: _showIntroDialog, // Updated to call _showIntroDialog
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

  Widget _buildFeatureButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFeatureButton(
            icon: Icons.tips_and_updates,
            label: 'Study Tips',
            onPressed: () => _showTopicInputDialog(
                'Study Tips', controller.provideStudyTips),
          ),
          _buildFeatureButton(
            icon: Icons.psychology,
            label: 'Explore Concept',
            onPressed: () => _showTopicInputDialog(
                'Explore Concept', controller.exploreConceptInDepth),
          ),
          _buildFeatureButton(
            icon: Icons.quiz,
            label: 'Practice Questions',
            onPressed: () => _showTopicInputDialog(
                'Practice Questions', controller.generatePracticeQuestions),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 12),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  void _showTopicInputDialog(String title, Function(String) onSubmit) {
    final TextEditingController topicController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: topicController,
            decoration: InputDecoration(hintText: "Enter a topic"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Submit"),
              onPressed: () {
                if (topicController.text.isNotEmpty) {
                  onSubmit(topicController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
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
