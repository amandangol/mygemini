import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mygemini/data/services/api_service.dart';
import 'package:mygemini/features/screens/translator/model/translator_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslatorController extends GetxController {
  final TextEditingController inputController = TextEditingController();

  var sourceLang = 'English'.obs;
  var targetLang = 'Spanish'.obs;
  var isProcessing = false.obs;

  var chatMessages = <TranslationMessage>[].obs;

  late SharedPreferences _prefs;

  static const int maxConversationLength = 50;
  var isMaxLengthReached = false.obs;

  final List<String> supportedLanguages = [
    'Afrikaans',
    'Albanian',
    'Amharic',
    'Arabic',
    'Armenian',
    'Azerbaijani',
    'Basque',
    'Belarusian',
    'Bengali',
    'Bosnian',
    'Bulgarian',
    'Burmese',
    'Catalan',
    'Chinese',
    'Croatian',
    'Czech',
    'Danish',
    'Dutch',
    'English',
    'Estonian',
    'Filipino',
    'Finnish',
    'French',
    'Galician',
    'Georgian',
    'German',
    'Greek',
    'Gujarati',
    'Haitian Creole',
    'Hausa',
    'Hebrew',
    'Hindi',
    'Hungarian',
    'Icelandic',
    'Igbo',
    'Indonesian',
    'Irish',
    'Italian',
    'Japanese',
    'Javanese',
    'Kannada',
    'Kazakh',
    'Khmer',
    'Korean',
    'Lao',
    'Latvian',
    'Lithuanian',
    'Macedonian',
    'Malay',
    'Malayalam',
    'Maltese',
    'Maori',
    'Marathi',
    'Mongolian',
    'Nepali',
    'Norwegian',
    'Persian',
    'Polish',
    'Portuguese',
    'Punjabi',
    'Romanian',
    'Russian',
    'Serbian',
    'Sinhala',
    'Slovak',
    'Slovenian',
    'Somali',
    'Spanish',
    'Swahili',
    'Swedish',
    'Tamil',
    'Telugu',
    'Thai',
    'Turkish',
    'Ukrainian',
    'Urdu',
    'Uzbek',
    'Vietnamese',
    'Welsh',
    'Yoruba',
    'Zulu'
  ];

  @override
  void onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    _loadConversation();
    if (chatMessages.isEmpty) {
      addMessage(
          "Welcome to the AI Translator. Enter text to translate from ${sourceLang.value} to ${targetLang.value} or many other languages and vice versa",
          isUser: false);
    }
    _checkMaxLength();
  }

  void _loadConversation() {
    final savedMessages = _prefs.getStringList('translatorMessages');
    if (savedMessages != null) {
      chatMessages.value = savedMessages
          .map((e) => TranslationMessage.fromJson(json.decode(e)))
          .toList();
      if (chatMessages.length > maxConversationLength) {
        chatMessages.value =
            chatMessages.sublist(chatMessages.length - maxConversationLength);
      }
    }
    sourceLang.value = _prefs.getString('sourceLang') ?? 'English';
    targetLang.value = _prefs.getString('targetLang') ?? 'Spanish';
    _checkMaxLength();
  }

  void _checkMaxLength() {
    isMaxLengthReached.value = chatMessages.length >= maxConversationLength;
  }

  Future<void> _saveConversation() async {
    if (chatMessages.length > maxConversationLength) {
      chatMessages.value =
          chatMessages.sublist(chatMessages.length - maxConversationLength);
    }
    await _prefs.setStringList('translatorMessages',
        chatMessages.map((e) => json.encode(e.toJson())).toList());
    await _prefs.setString('sourceLang', sourceLang.value);
    await _prefs.setString('targetLang', targetLang.value);
    _checkMaxLength();
  }

  Future<void> translate() async {
    final textToTranslate = inputController.text.trim();
    if (textToTranslate.isEmpty || isMaxLengthReached.value) return;

    addMessage(textToTranslate, isUser: true);
    inputController.clear();
    isProcessing.value = true;

    try {
      final translatedText = await performTranslation(textToTranslate);
      addMessage(translatedText, isUser: false);
    } catch (e) {
      addMessage("Error: Unable to translate. Please try again.",
          isUser: false);
    } finally {
      isProcessing.value = false;
      await _saveConversation();
    }
  }

  Future<String> performTranslation(String text) async {
    final List<Map<String, String>> prompt = [
      {
        "role": "user",
        "content": '''
        Translate the following text from ${sourceLang.value} to ${targetLang.value}:
        "$text"
        Only provide the translated text without any additional explanation.
        '''
      }
    ];

    final translatedText = await APIs.geminiAPI(prompt);
    return translatedText.trim();
  }

  Future<void> swapLanguages() async {
    final temp = sourceLang.value;
    sourceLang.value = targetLang.value;
    targetLang.value = temp;
    addMessage(
        "Languages swapped. Now translating from ${sourceLang.value} to ${targetLang.value}.",
        isUser: false);
    await _saveConversation();
  }

  void addMessage(String message, {required bool isUser}) {
    chatMessages.add(TranslationMessage(text: message, isUser: isUser));
    _saveConversation();
  }

  Future<void> resetConversation() async {
    chatMessages.clear();
    sourceLang.value = 'English';
    targetLang.value = 'Spanish';
    isMaxLengthReached.value = false;
    addMessage(
        "Welcome to the AI Translator. Enter text to translate from ${sourceLang.value} to ${targetLang.value}.",
        isUser: false);
    await _saveConversation();
  }
}
