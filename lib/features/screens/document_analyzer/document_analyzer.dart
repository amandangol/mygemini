import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:mygemini/commonwidgets/custom_appbar.dart';
import 'package:mygemini/commonwidgets/custom_button.dart';
import 'package:mygemini/commonwidgets/custom_inputfield.dart';
import 'package:mygemini/commonwidgets/action_button.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mygemini/commonwidgets/error_message_widget.dart';
import 'package:mygemini/commonwidgets/selectable_markdown.dart';
import 'package:mygemini/controllers/documentanalyzer_controller.dart';

class DocumentAnalyzerFeature extends StatelessWidget {
  DocumentAnalyzerFeature({Key? key}) : super(key: key);

  final DocumentAnalyzerController _controller =
      Get.put(DocumentAnalyzerController());

  final Color primaryColor = const Color(0xFF3498DB);
  final Color backgroundColor = const Color(0xFFF0F4F8);
  final Color textColor = const Color(0xFF2C3E50);
  final Color accentColor = const Color(0xFF2ECC71);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: 'AI Document Analyzer',
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
              _buildFileUploader(),
              const SizedBox(height: 30),
              _buildAnalyzeButton(),
              const SizedBox(height: 16),
              _buildErrorMessage(),
              const SizedBox(height: 24),
              _buildAnalysisResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Icon(Icons.upload_file, size: 48, color: primaryColor),
          const SizedBox(height: 16),
          Obx(() => Text(
                _controller.selectedFileName.value.isEmpty
                    ? 'No file selected'
                    : 'Selected file: ${_controller.selectedFileName.value}',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              )),
          const SizedBox(height: 16),
          CustomButton(
            onPressed: _controller.pickFile,
            child: const Text(
              'Select Document',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          CustomInputField(
            controller: _controller.analysisTypeC,
            label: 'Analysis Type',
            hint: 'E.g., Extract key points, Summarize, etc.',
            readOnly: false,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildAnalyzeButton() {
    return Obx(() => CustomButton(
              onPressed: _controller.isLoading.value
                  ? null
                  : _controller.analyzeDocument,
              iconData:
                  _controller.isLoading.value ? null : Icons.analytics_outlined,
              child: _controller.isLoading.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Analyze',
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

  Widget _buildAnalysisResults() {
    return Obx(() => _controller.analysisResults.isNotEmpty
        ? Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analysis Results:',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SelectableMarkdown(
                    data: _controller.analysisResults.value,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ActionButton(
                        icon: Icons.copy,
                        label: 'Copy',
                        onPressed: () => _controller
                            .copyToClipboard(_controller.analysisResults.value),
                      ),
                      ActionButton(
                        icon: Icons.share,
                        label: 'Share',
                        onPressed: () => _controller
                            .shareContent(_controller.analysisResults.value),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0)
        : const SizedBox.shrink());
  }
}
