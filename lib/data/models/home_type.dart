import 'package:ai_assistant/ui/screens/chatbot/chatbot_feature.dart';
import 'package:ai_assistant/ui/screens/email_writer/email_writer.dart';
import 'package:ai_assistant/ui/screens/image_feature.dart';
import 'package:ai_assistant/ui/screens/translation/translator_feature.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../ui/screens/AiCodeGenerator/code_generator.dart';

enum HomeType {
  aiChatBot,
  aiImage,
  aiTranslator,
  aiEmailWriter,
  aiCodeGenerator
}

extension MyHomeType on HomeType {
  // title
  String get title => switch (this) {
        HomeType.aiChatBot => 'AI ChatBot',
        HomeType.aiImage => 'AI Image Creator',
        HomeType.aiTranslator => 'AI Translator',
        HomeType.aiEmailWriter => 'AI Email Writer',
        HomeType.aiCodeGenerator => 'AI Code Generator',
      };

  // lottie
  String get lottie => switch (this) {
        HomeType.aiChatBot => 'ai_hand_waving.json',
        HomeType.aiImage => 'ai_play.json',
        HomeType.aiTranslator => 'ai_ask_me.json',
        HomeType.aiEmailWriter => 'ai_ask_me.json',
        HomeType.aiCodeGenerator => 'ai_ask_me.json',
      };

  // for alignment
  bool get leftAlign => switch (this) {
        HomeType.aiChatBot => true,
        HomeType.aiImage => false,
        HomeType.aiTranslator => true,
        HomeType.aiEmailWriter => false,
        HomeType.aiCodeGenerator => true,
      };

  // for padding
  EdgeInsets get padding => switch (this) {
        HomeType.aiChatBot => EdgeInsets.zero,
        HomeType.aiImage => const EdgeInsets.all(20),
        HomeType.aiTranslator => EdgeInsets.zero,
        HomeType.aiEmailWriter => const EdgeInsets.all(20),
        HomeType.aiCodeGenerator => EdgeInsets.zero,
      };

  // for navigation
  VoidCallback get onTap => switch (this) {
        HomeType.aiChatBot => () => Get.to(() => const ChatbotFeature()),
        HomeType.aiImage => () => Get.to(() => const ImageFeature()),
        HomeType.aiTranslator => () => Get.to(() => TranslatorFeature()),
        HomeType.aiEmailWriter => () => Get.to(() => EmailWriterFeature()),
        HomeType.aiCodeGenerator => () => Get.to(() => AiCodeGenerator()),
      };
}
