import 'package:ai_assistant/commonwidgets/custom_inputfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_assistant/controllers/email_controller.dart';
import 'package:flutter/services.dart';
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
      appBar: AppBar(
        title: const Text('AI Email Writer',
            style: TextStyle(
                color: Color(0xFF2C3E50), fontWeight: FontWeight.w300)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF2C3E50)),
            onPressed: _controller.clearFields,
          ),
        ],
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
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3498DB).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Obx(() => ElevatedButton(
            onPressed:
                _controller.isLoading.value ? null : _controller.generateEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: _controller.isLoading.value
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                : const Text(
                    'Generate Email',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
          )),
    )
        .animate(target: _controller.isLoading.value ? 1 : 0)
        .shimmer(duration: 1000.ms, color: Colors.white.withOpacity(0.3))
        .shake(hz: 4, curve: Curves.easeInOutCubic);
  }

  Widget _buildErrorMessage() {
    return Obx(() => _controller.errorMessage.isNotEmpty
        ? Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDEDED),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _controller.errorMessage.value,
              style: const TextStyle(color: Color(0xFFE74C3C)),
            ),
          )
        : const SizedBox.shrink());
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
                SelectableText(
                  _controller.generatedEmail.value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.copy,
                      label: 'Copy',
                      onPressed: () =>
                          _copyToClipboard(_controller.generatedEmail.value),
                    ),
                    _buildActionButton(
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: const Color(0xFF2C3E50), size: 18),
      label: Text(
        label,
        style: const TextStyle(color: Color(0xFF2C3E50)),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
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
