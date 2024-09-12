import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygemini/data/services/api_service.dart';
import 'package:mygemini/features/screens/email_gen/model/emailmessage_model.dart';

class EmailBotController extends GetxController {
  final userInputController = TextEditingController();

  var emailMessages = <EmailMessage>[].obs;
  var isLoading = false.obs;

  var currentState = EmailState.askingRecipient.obs;
  var recipient = ''.obs;
  var subject = ''.obs;
  var body = ''.obs;
  var lastGeneratedEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _addBotMessage("Hi! I'm EmailBot. Who would you like to send an email to?");
  }

  @override
  void onClose() {
    userInputController.dispose();
    super.onClose();
  }

  Future<void> sendMessage() async {
    if (userInputController.text.isEmpty) return;

    final userMessage = userInputController.text;
    _addUserMessage(userMessage);
    userInputController.clear();

    isLoading.value = true;

    try {
      switch (currentState.value) {
        case EmailState.askingRecipient:
          recipient.value = userMessage;
          currentState.value = EmailState.askingSubject;
          _addBotMessage("Great! What's the subject of your email?");
          break;
        case EmailState.askingSubject:
          subject.value = userMessage;
          currentState.value = EmailState.askingBody;
          _addBotMessage(
              "Excellent! Now, what details would you like to include in the body of the email?");
          break;
        case EmailState.askingBody:
          body.value = userMessage;
          currentState.value = EmailState.generatingEmail;
          await _generateEmail();
          break;
        case EmailState.generatingEmail:
          await _handlePostGenerationInteraction(userMessage);
          break;
      }
    } catch (e) {
      _addBotMessage(
          "I'm sorry, I encountered an error. Can you please try again?");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _generateEmail() async {
    _addBotMessage(
        "Alright, I'm generating the email now. Please wait a moment...");

    try {
      List<Map<String, String>> prompt = [
        {
          "role": "user",
          "content":
              'Write a professional email to ${recipient.value} about ${subject.value}. Include the following details: ${body.value}'
        }
      ];
      String emailContent = await APIs.geminiAPI(prompt);
      lastGeneratedEmail.value = emailContent;
      _addBotMessage(emailContent, isEmail: true);
      _addBotMessage(
          "Here's the generated email. Would you like me to explain any part of it, modify it, or start a new email?");
    } catch (e) {
      _addBotMessage(
          "I'm sorry, I couldn't generate the email. Can you please try again?");
    }
  }

  Future<void> _handlePostGenerationInteraction(String userMessage) async {
    if (userMessage.toLowerCase().contains('explain')) {
      _addBotMessage(
          "Certainly! I'd be happy to explain the email. Which part would you like me to elaborate on?");
    } else if (userMessage.toLowerCase().contains('modify')) {
      _addBotMessage(
          "Sure, I can help you modify the email. What changes would you like to make?");
      // Here you could set up a new state for handling modifications
    } else if (userMessage.toLowerCase().contains('new') ||
        userMessage.toLowerCase().contains('start over')) {
      resetConversation();
    } else {
      // Generate a response based on the user's input
      List<Map<String, String>> prompt = [
        {
          "role": "user",
          "content":
              'The user asked: "${userMessage}" in response to this email:\n\n${lastGeneratedEmail.value}\n\nProvide a helpful response:'
        }
      ];
      String response = await APIs.geminiAPI(prompt);
      _addBotMessage(response);
      _addBotMessage(
          "Is there anything else you'd like to know about the email, or would you like to start a new email?");
    }
  }

  void _addUserMessage(String message) {
    emailMessages.add(EmailMessage(content: message, isUser: true));
  }

  void _addBotMessage(String message, {bool isEmail = false}) {
    emailMessages
        .add(EmailMessage(content: message, isUser: false, isEmail: isEmail));
  }

  void resetConversation() {
    emailMessages.clear();
    currentState.value = EmailState.askingRecipient;
    recipient.value = '';
    subject.value = '';
    body.value = '';
    lastGeneratedEmail.value = '';
    _addBotMessage("Let's start over! Who would you like to send an email to?");
  }
}

enum EmailState {
  askingRecipient,
  askingSubject,
  askingBody,
  generatingEmail,
}
