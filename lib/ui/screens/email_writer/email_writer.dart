import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_assistant/controllers/email_controller.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class EmailWriterFeature extends StatelessWidget {
  EmailWriterFeature({Key? key}) : super(key: key);

  final EmailController _controller = Get.put(EmailController());

  // Define new color scheme
  final Color primaryColor = const Color(0xFF6B9080);
  final Color backgroundColor = const Color(0xFFF6FFF8);
  final Color accentColor = const Color(0xFFCCE3DE);
  final Color textColor = const Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('AI Email Writer'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller.clearFields,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildEmailFields(),
              const SizedBox(height: 32),
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

  Widget _buildHeader() {
    return Center(
      child: AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            'AI Email Writer',
            textStyle: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
            speed: const Duration(milliseconds: 25),
          ),
        ],
        totalRepeatCount: 1,
      ),
    );
  }

  Widget _buildEmailFields() {
    return Column(
      children: [
        _buildTextField(_controller.recipientC, 'Recipient'),
        const SizedBox(height: 16),
        _buildTextField(_controller.subjectC, 'Subject'),
        const SizedBox(height: 16),
        _buildTextField(_controller.bodyC, 'Body', maxLines: 5),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Center(
      child: Obx(() => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: ElevatedButton(
              onPressed: _controller.isLoading.value
                  ? null
                  : _controller.generateEmail,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _controller.isLoading.value
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('Generate Email', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 8),
                        Icon(Icons.email),
                      ],
                    ),
            ),
          )),
    );
  }

  Widget _buildErrorMessage() {
    return Obx(() => _controller.errorMessage.isNotEmpty
        ? Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _controller.errorMessage.value,
              style: TextStyle(color: Colors.red.shade800),
            ),
          )
        : const SizedBox.shrink());
  }

  Widget _buildGeneratedEmail() {
    return Obx(() => _controller.generatedEmail.isNotEmpty
        ? Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generated Email:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _controller.generatedEmail.value,
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
          )
        : const SizedBox.shrink());
  }
}
