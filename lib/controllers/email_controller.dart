import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygemini/data/services/api_service.dart';

class EmailController extends GetxController {
  final recipientC = TextEditingController();
  final subjectC = TextEditingController();
  final bodyC = TextEditingController();

  var generatedEmail = ''.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onClose() {
    recipientC.dispose();
    subjectC.dispose();
    bodyC.dispose();
    super.onClose();
  }

  Future<void> generateEmail() async {
    if (recipientC.text.isEmpty ||
        subjectC.text.isEmpty ||
        bodyC.text.isEmpty) {
      errorMessage.value = 'Please fill in all fields.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    generatedEmail.value = '';

    try {
      String emailContent = await APIs.geminiAPI(
        'Write a professional email to ${recipientC.text} about ${subjectC.text}. Include the following details: ${bodyC.text}',
      );
      generatedEmail.value = emailContent;
    } catch (e) {
      errorMessage.value = 'Failed to generate email. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void clearFields() {
    recipientC.clear();
    subjectC.clear();
    bodyC.clear();
    generatedEmail.value = '';
    errorMessage.value = '';
  }
}
