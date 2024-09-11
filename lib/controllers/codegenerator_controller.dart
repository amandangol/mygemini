import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_assistant/data/services/api_service.dart';

class CodeGeneratorController extends GetxController {
  final languageC = TextEditingController();
  final functionalityC = TextEditingController();
  final additionalDetailsC = TextEditingController();

  var generatedCode = ''.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onClose() {
    languageC.dispose();
    functionalityC.dispose();
    additionalDetailsC.dispose();
    super.onClose();
  }

  Future<void> generateCode() async {
    if (languageC.text.isEmpty ||
        functionalityC.text.isEmpty ||
        additionalDetailsC.text.isEmpty) {
      errorMessage.value = 'Please fill in all fields.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    generatedCode.value = '';

    try {
      String codeContent = await APIs.geminiAPI(
        'Generate ${languageC.text} code for ${functionalityC.text}. Include the following details: ${additionalDetailsC.text}',
      );
      generatedCode.value = codeContent;
    } catch (e) {
      errorMessage.value = 'Failed to generate code. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void clearFields() {
    languageC.clear();
    functionalityC.clear();
    additionalDetailsC.clear();
    generatedCode.value = '';
    errorMessage.value = '';
  }
}
