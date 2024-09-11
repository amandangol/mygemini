import 'package:ai_assistant/data/services/api_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TranslatorController extends GetxController {
  final sourceTextC = TextEditingController();
  final targetTextC = TextEditingController();

  var sourceLang = 'English'.obs;
  var targetLang = 'Spanish'.obs;
  var isTranslating = false.obs;

  final supportedLanguages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Russian',
    'Chinese',
    'Japanese',
    'Korean',
    'Arabic',
    'Hindi',
    'Bengali',
    'Urdu',
    'Indonesian',
    'Turkish',
    'Dutch',
    'Swedish',
    'Norwegian',
    'Danish',
    'Finnish',
    'Greek',
    'Nepali'
  ];

  Future<void> translate() async {
    if (sourceTextC.text.trim().isNotEmpty) {
      isTranslating.value = true;

      final prompt = '''
      Translate the following text from ${sourceLang.value} to ${targetLang.value}:
      "${sourceTextC.text}"
      Only provide the translated text without any additional explanation.
      ''';

      try {
        final translatedText = await APIs.geminiAPI(prompt);
        targetTextC.text = translatedText.trim();
      } catch (e) {
        targetTextC.text = 'Error: Unable to translate. Please try again.';
      }

      isTranslating.value = false;
    }
  }

  void swapLanguages() {
    final temp = sourceLang.value;
    sourceLang.value = targetLang.value;
    targetLang.value = temp;

    final tempText = sourceTextC.text;
    sourceTextC.text = targetTextC.text;
    targetTextC.text = tempText;
  }
}
