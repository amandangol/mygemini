import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mygemini/commonwidgets/action_button.dart';
import 'package:mygemini/commonwidgets/custom_button.dart';
import 'package:mygemini/commonwidgets/custom_inputfield.dart';
import 'package:mygemini/controllers/codegenerator_controller.dart';
import 'package:share_plus/share_plus.dart';

class AiCodeGenerator extends StatelessWidget {
  AiCodeGenerator({Key? key}) : super(key: key);

  final CodeGeneratorController controller = Get.put(CodeGeneratorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('AI Code Gen',
            style: TextStyle(
                color: Color(0xFF2C3E50), fontWeight: FontWeight.w300)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildInputFields(),
              const SizedBox(height: 30),
              Obx(() => _buildGenerateButton()),
              const SizedBox(height: 30),
              Obx(() => _buildOutputSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        CustomInputField(
          controller: controller.languageC,
          label: 'Language',
          hint: 'e.g., Python, Dart',
          readOnly: false,
        ),
        const SizedBox(height: 16),
        CustomInputField(
          controller: controller.functionalityC,
          label: 'Functionality',
          readOnly: false,
          hint: 'e.g., Sort an array, Create a login form',
        ),
        const SizedBox(height: 16),
        CustomInputField(
          controller: controller.additionalDetailsC,
          label: 'Details',
          hint: 'Any specific requirements',
          readOnly: false,
          maxLines: 3,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildGenerateButton() {
    return CustomButton(
            onPressed: controller.isLoading.value
                ? null
                : () async {
                    controller.generateCode();
                  },
            child: controller.isLoading.value
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text(
                    'Generate Code',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ))
        .animate(target: controller.isLoading.value ? 1 : 0)
        .shimmer(duration: 1000.ms, color: Colors.white.withOpacity(0.3))
        .shake(hz: 4, curve: Curves.easeInOutCubic);
  }

  Widget _buildOutputSection() {
    if (controller.errorMessage.isNotEmpty) {
      return _buildMessageBox(
        message: controller.errorMessage.value,
        backgroundColor: const Color(0xFFFDEDED),
        textColor: const Color(0xFFE74C3C),
      );
    } else if (controller.generatedCode.isNotEmpty) {
      return _buildMessageBox(
        message: controller.generatedCode.value,
        backgroundColor: const Color(0xFFE8F6F3),
        textColor: const Color(0xFF2C3E50),
        title: 'Generated Code:',
        showActions: true,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMessageBox({
    required String message,
    required Color backgroundColor,
    required Color textColor,
    String? title,
    bool showActions = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                SelectableText(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontFamily: 'Courier',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (showActions)
            Container(
              decoration: const BoxDecoration(
                // color: backgroundColor(0.05),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ActionButton(
                    icon: Icons.copy,
                    label: 'Copy',
                    onPressed: () => _copyToClipboard(message),
                  ),
                  ActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    onPressed: () => _shareContent(message),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied!',
      'Code copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2C3E50).withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _shareContent(String text) {
    Share.share(text, subject: 'Generated Code from AI Code Gen');
  }
}
