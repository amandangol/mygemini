import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mygemini/data/services/api_service.dart';
import 'package:mygemini/features/screens/translator/model/translator_model.dart';

class TranslatorController extends GetxController {
  final TextEditingController inputController = TextEditingController();

  var sourceLang = 'English'.obs;
  var targetLang = 'Spanish'.obs;
  var isProcessing = false.obs;

  var chatMessages = <TranslationMessage>[].obs;

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
  void onInit() {
    super.onInit();
    addMessage(
        "Welcome to the AI Translator. Enter text to translate from ${sourceLang.value} to ${targetLang.value} or many other languages and vice versa",
        isUser: false);
  }

  Future<void> translate() async {
    final textToTranslate = inputController.text.trim();
    if (textToTranslate.isEmpty) return;

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

  void swapLanguages() {
    final temp = sourceLang.value;
    sourceLang.value = targetLang.value;
    targetLang.value = temp;
    addMessage(
        "Languages swapped. Now translating from ${sourceLang.value} to ${targetLang.value}.",
        isUser: false);
  }

  void addMessage(String message, {required bool isUser}) {
    chatMessages.add(TranslationMessage(text: message, isUser: isUser));
  }

  void resetConversation() {
    chatMessages.clear();
    addMessage(
        "Welcome to the AI Translator. Enter text to translate from ${sourceLang.value} to ${targetLang.value}.",
        isUser: false);
  }
}
