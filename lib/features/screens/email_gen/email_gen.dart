import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:mygemini/commonwidgets/action_button.dart';
import 'package:mygemini/commonwidgets/custom_appbar.dart';
import 'package:mygemini/commonwidgets/custom_button.dart';
import 'package:mygemini/commonwidgets/custom_inputfield.dart';
import 'package:mygemini/commonwidgets/error_message_widget.dart';
import 'package:mygemini/commonwidgets/selectable_markdown.dart';
import 'package:mygemini/controllers/email_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EmailWriterFeature extends StatelessWidget {
  EmailWriterFeature({Key? key}) : super(key: key);

  final EmailController _controller = Get.put(EmailController());

  final Color primaryColor = const Color(0xFF3498DB);
  final Color backgroundColor = const Color(0xFFF0F4F8);
  final Color textColor = const Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: 'AI Email Writer',
        onBackPressed: () => Navigator.of(context).pop(),
        onResetPressed: () {
          _controller.clearFields();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All fields have been reset')),
          );
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildEmailFields(),
              const SizedBox(height: 30),
              _buildGenerateButton(),
              const SizedBox(height: 16),
              _buildErrorMessage(),
              const SizedBox(height: 24),
              _buildGeneratedEmail(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailFields() {
    return Column(
      children: [
        CustomInputField(
          controller: _controller.recipientC,
          label: 'Recipient',
          hint: 'Enter recipient email',
          readOnly: false,
        ),
        const SizedBox(height: 16),
        CustomInputField(
          controller: _controller.subjectC,
          label: 'Subject',
          hint: 'Enter email subject',
          readOnly: false,
        ),
        const SizedBox(height: 16),
        CustomInputField(
          controller: _controller.bodyC,
          label: 'Body',
          hint: 'Enter email body',
          maxLines: 5,
          readOnly: false,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildGenerateButton() {
    return CustomButton(
            onPressed: _controller.isLoading.value
                ? null
                : () async {
                    _controller.generateEmail();
                  },
            iconData: _controller.isLoading.value ? null : Icons.email_outlined,
            child: Obx(
              () => _controller.isLoading.value
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      'Generate Email',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
            ))
        .animate(target: _controller.isLoading.value ? 1 : 0)
        .shimmer(duration: 1000.ms, color: Colors.white.withOpacity(0.3))
        .shake(hz: 4, curve: Curves.easeInOutCubic);
  }

  Widget _buildErrorMessage() {
    return ErrorMessageWidget(errorMessage: _controller.errorMessage);
  }

  Widget _buildGeneratedEmail() {
    return Obx(() => _controller.generatedEmail.isNotEmpty
        ? Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F6F3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generated Email:',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                SelectableMarkdown(
                  data: _controller.generatedEmail.value,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionButton(
                      icon: Icons.copy,
                      label: 'Copy',
                      onPressed: () =>
                          _copyToClipboard(_controller.generatedEmail.value),
                    ),
                    ActionButton(
                      icon: Icons.share,
                      label: 'Share',
                      onPressed: () =>
                          _shareContent(_controller.generatedEmail.value),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0)
        : const SizedBox.shrink());
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied!',
      'Email copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2C3E50).withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _shareContent(String text) {
    Share.share(text, subject: 'Generated Email from AI Email Writer');
  }
}
