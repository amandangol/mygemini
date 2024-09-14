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

  static const int maxConversationLength = 50;
  var isMaxLengthReached = false.obs;

  @override
  void onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    _loadConversation();
    if (emailMessages.isEmpty) {
      _addBotMessage(
          "Hi! I'm EmailBot. Who would you like to send an email to?");
    }
    _checkMaxLength();
  }

  @override
  void onClose() {
    userInputController.dispose();
    super.onClose();
  }

  void _loadConversation() {
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
      await _saveConversation(); // Save after each interaction
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

  Future<void> resetConversation() async {
    emailMessages.clear();
    currentState.value = EmailState.askingRecipient;
    recipient.value = '';
    subject.value = '';
    body.value = '';
    lastGeneratedEmail.value = '';
    isMaxLengthReached.value = false;
    _addBotMessage("Let's start over! Who would you like to send an email to?");
    await _saveConversation(); // Save the reset state
  }

  void _addUserMessage(String message) {
    emailMessages.add(EmailMessage(content: message, isUser: true));
    _saveConversation();
  }

  void _addBotMessage(String message, {bool isEmail = false}) {
    emailMessages
        .add(EmailMessage(content: message, isUser: false, isEmail: isEmail));
    _saveConversation();
  }
}

enum EmailState {
  askingRecipient,
  askingSubject,
  askingBody,
  generatingEmail,
}
