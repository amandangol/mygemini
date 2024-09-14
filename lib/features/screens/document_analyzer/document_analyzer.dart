import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mygemini/commonwidgets/custom_actionbuttons.dart';
import 'package:mygemini/commonwidgets/custom_appbar.dart';
import 'package:mygemini/commonwidgets/custom_input_widget.dart';
import 'package:mygemini/commonwidgets/selectable_markdown.dart';
import 'package:mygemini/features/screens/document_analyzer/controller/documentanalyzer_controller.dart';
import 'package:mygemini/features/screens/document_analyzer/model/docbot_model.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';

class DocumentAnalyzerFeature extends StatefulWidget {
  DocumentAnalyzerFeature({Key? key}) : super(key: key);

  @override
  _DocumentAnalyzerFeatureState createState() =>
      _DocumentAnalyzerFeatureState();
}

class _DocumentAnalyzerFeatureState extends State<DocumentAnalyzerFeature> {
  final DocumentAnalyzerController _controller =
      Get.put(DocumentAnalyzerController());
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller.analyzerMessages.listen((_) {
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
              child: Obx(() => _buildAnalyzerMessages(context)),
            ),
            _buildFileUploadButton(context),
            const SizedBox(
              height: 8,
            ),
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return CustomAppBar(
      title: 'AI DocAnalyzer',
      onResetConversation: () {
        _controller.resetConversation();
      },
    );
  }

  Widget _buildAnalyzerMessages(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: AppTheme.defaultPadding,
      itemCount: _controller.analyzerMessages.length,
      itemBuilder: (context, index) {
        final message = _controller.analyzerMessages[index];
        return _buildMessageBubble(context, message);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, AnalyzerMessage message) {
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
              isUserMessage ? 'You' : 'DocAnalyzer',
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
            if (message.isAnalysis)
              Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: CustomActionButtons(
                    text: message.content,
                    shareSubject: 'Generated text from DocAnalyzer Assistant',
                  )),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildInputArea(BuildContext context) {
    return CustomInputWidget(
      userInputController: _controller.userInputController,
      isLoading: _controller.isLoading,
      sendMessage: _controller.sendMessage,
      isMaxLengthReached: _controller.isMaxLengthReached,
      hintText: 'Ask DocAnalyzer to extract, summarize...',
    );
  }

  Widget _buildFileUploadButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _controller.pickFile(),
      icon: const Icon(Icons.upload_file),
      label: const Text('Upload Document'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
