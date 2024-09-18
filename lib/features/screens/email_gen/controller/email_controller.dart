import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygemini/data/services/api_service.dart';
import 'package:mygemini/features/screens/email_gen/model/emailmessage_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailBotController extends GetxController {
  final userInputController = TextEditingController();

  var emailMessages = <EmailMessage>[].obs;
  var isLoading = false.obs;
  late SharedPreferences _prefs;

  var currentState = EmailState.askingRecipient.obs;
  var recipient = ''.obs;
  var subject = ''.obs;
  var body = ''.obs;
  var lastGeneratedEmail = ''.obs;
  var emailStyle = EmailStyle.professional.obs;
  var showStyleSelection = false.obs;
  var emailProgress = 0.0.obs;

  static const int maxConversationLength = 50;
  var isMaxLengthReached = false.obs;

  @override
  void onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    _loadConversation();
    if (emailMessages.isEmpty) {
      _addBotMessage(
          "Welcome to the AI Email Composer! Let's start by deciding who you want to send an email to. Who's the recipient?");
    }
    _checkMaxLength();
  }

  @override
  void onClose() {
    userInputController.dispose();
    super.onClose();
  }

  Future<void> _loadConversation() async {
    final savedMessages = _prefs.getStringList('emailMessages');
    if (savedMessages != null) {
      emailMessages.value = savedMessages
          .map((e) => EmailMessage.fromJson(json.decode(e)))
          .toList();
      // Trim the conversation if it's too long
      if (emailMessages.length > maxConversationLength) {
        emailMessages.value =
            emailMessages.sublist(emailMessages.length - maxConversationLength);
      }
      currentState.value =
          EmailState.values[_prefs.getInt('currentState') ?? 0];
      recipient.value = _prefs.getString('recipient') ?? '';
      subject.value = _prefs.getString('subject') ?? '';
      body.value = _prefs.getString('body') ?? '';
      lastGeneratedEmail.value = _prefs.getString('lastGeneratedEmail') ?? '';
    }
    _checkMaxLength();
  }

  void _checkMaxLength() {
    isMaxLengthReached.value = emailMessages.length >= maxConversationLength;
  }

  Future<void> _saveConversation() async {
    // Trim the conversation if it's too long before saving
    if (emailMessages.length > maxConversationLength) {
      emailMessages.value =
          emailMessages.sublist(emailMessages.length - maxConversationLength);
    }
    await _prefs.setStringList('emailMessages',
        emailMessages.map((e) => json.encode(e.toJson())).toList());
    await _prefs.setInt('currentState', currentState.value.index);
    await _prefs.setString('recipient', recipient.value);
    await _prefs.setString('subject', subject.value);
    await _prefs.setString('body', body.value);
    await _prefs.setString('lastGeneratedEmail', lastGeneratedEmail.value);
    _checkMaxLength();
  }

  Future<void> sendMessage() async {
    if (userInputController.text.isEmpty || isMaxLengthReached.value) return;

    final userMessage = userInputController.text;
    _addUserMessage(userMessage);
    userInputController.clear();

    isLoading.value = true;

    try {
      switch (currentState.value) {
        case EmailState.askingRecipient:
          recipient.value = userMessage;
          currentState.value = EmailState.askingSubject;
          _addBotMessage("Great! Now, what's the subject of your email?");
          emailProgress.value = 0.25;
          break;
        case EmailState.askingSubject:
          subject.value = userMessage;
          currentState.value = EmailState.askingBody;
          _addBotMessage(
              "Excellent! Now, please provide some key points or details you want to include in the email body.");
          emailProgress.value = 0.5;
          break;
        case EmailState.askingBody:
          body.value = userMessage;
          currentState.value = EmailState.choosingStyle;
          showStyleSelection.value = true;
          _addBotMessage(
              "Thanks for the details. Now, please choose an email style that best fits your needs.");
          emailProgress.value = 0.75;
          break;
        case EmailState.choosingStyle:
          await _generateEmail();
          break;
        case EmailState.refiningEmail:
          await _handleEmailRefinement(userMessage);
          break;
      }
    } catch (e) {
      _addBotMessage(
          "I'm sorry, I encountered an error. Can you please try again?");
    } finally {
      isLoading.value = false;
      await _saveConversation();
    }
  }

  Future<void> selectEmailStyle(EmailStyle style) async {
    emailStyle.value = style;
    showStyleSelection.value = false;
    await _generateEmail(); // Directly generate the email after style selection
  }

  Future<void> _generateEmail() async {
    isLoading.value = true;
    _addBotMessage(
        "Thank you for providing all the details. I'm generating the email now. Please wait a moment...");

    try {
      List<Map<String, String>> prompt = [
        {
          "role": "user",
          "content":
              'Write a ${emailStyle.value.toString().split('.').last} email to ${recipient.value} about ${subject.value}. Include the following details: ${body.value}'
        }
      ];
      String emailContent = await APIs.geminiAPI(prompt);
      lastGeneratedEmail.value = emailContent;
      _addBotMessage(emailContent, isEmail: true);
      _addBotMessage(
          "Here's the generated email. Would you like me to explain any part of it, modify it, or start a new email?");
      currentState.value = EmailState.refiningEmail;
      emailProgress.value = 1.0;
    } catch (e) {
      _addBotMessage(
          "I'm sorry, I couldn't generate the email. Can you please try again?");
    } finally {
      isLoading.value = false;
      await _saveConversation();
    }
  }

  Future<void> _handleEmailRefinement(String userMessage) async {
    if (userMessage.toLowerCase().contains('explain')) {
      _addBotMessage(
          "Certainly! I'd be happy to explain the email. Which part would you like me to elaborate on?");
    } else if (userMessage.toLowerCase().contains('modify')) {
      _addBotMessage(
          "Sure, I can help you modify the email. What changes would you like to make?");
    } else if (userMessage.toLowerCase().contains('new') ||
        userMessage.toLowerCase().contains('start over')) {
      resetConversation();
    } else {
      List<Map<String, String>> prompt = [
        {
          "role": "user",
          "content":
              'The user asked: "$userMessage" in response to this email:\n\n${lastGeneratedEmail.value}\n\nProvide a helpful response:'
        }
      ];
      String response = await APIs.geminiAPI(prompt);
      _addBotMessage(response);
      _addBotMessage(
          "Is there anything else you'd like to know about the email, or would you like to start a new email?");
    }
  }

  Future<void> resetConversation() async {
    emailMessages.clear();
    currentState.value = EmailState.askingRecipient;
    recipient.value = '';
    subject.value = '';
    body.value = '';
    lastGeneratedEmail.value = '';
    emailStyle.value = EmailStyle.professional;
    showStyleSelection.value = false;
    emailProgress.value = 0.0;
    isMaxLengthReached.value = false;
    _addBotMessage("Let's start over! Who would you like to send an email to?");
    await _saveConversation();
  }

  void _addUserMessage(String message) {
    emailMessages.add(EmailMessage(
      content: message,
      isUser: true,
    ));
    _saveConversation();
  }

  void _addBotMessage(String message, {bool isEmail = false}) {
    emailMessages.add(EmailMessage(
      content: message,
      isUser: false,
      isEmail: isEmail,
    ));
    _saveConversation();
  }
}

enum EmailState {
  askingRecipient,
  askingSubject,
  askingBody,
  choosingStyle,
  refiningEmail,
}

enum EmailStyle {
  professional,
  casual,
  formal,
  friendly,
  persuasive,
}
