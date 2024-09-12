import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygemini/controllers/chathistory_controller.dart';
import 'package:mygemini/features/screens/chatbot/chatbot.dart';
import 'package:mygemini/features/screens/document_analyzer/document_analyzer.dart';
import 'package:mygemini/features/screens/email_gen/email_gen.dart';
import 'package:mygemini/features/screens/image_captioner/image_captioner.dart';
import 'package:mygemini/features/screens/translation/translator_screen.dart';

import '../../features/screens/code_generator/code_gen.dart';

enum HomeType {
  aiChatBot,
  aiTranslator,
  aiEmailWriter,
  aiCodeGenerator,
  aiImageCaptioner,
  aiDocumentAnalyzer
}

extension MyHomeType on HomeType {
  // title
  String get title => switch (this) {
        HomeType.aiChatBot => 'AI ChatBot',
        HomeType.aiTranslator => 'AI Translator',
        HomeType.aiEmailWriter => 'AI Email Writer',
        HomeType.aiCodeGenerator => 'AI Code Generator',
        HomeType.aiImageCaptioner => 'AI Image Caption',
        HomeType.aiDocumentAnalyzer => 'AI Document Analyzer',
      };

  // lottie
  String get lottie => switch (this) {
        HomeType.aiChatBot => 'ai_hand_waving.json',
        HomeType.aiTranslator => 'ai_ask_me.json',
        HomeType.aiEmailWriter => 'ai_ask_me.json',
        HomeType.aiCodeGenerator => 'ai_ask_me.json',
        HomeType.aiImageCaptioner => 'ai_ask_me.json',
        HomeType.aiDocumentAnalyzer => 'ai_ask_me.json'
      };

  // for alignment
  bool get leftAlign => switch (this) {
        HomeType.aiChatBot => true,
        HomeType.aiTranslator => true,
        HomeType.aiEmailWriter => false,
        HomeType.aiCodeGenerator => true,
        HomeType.aiImageCaptioner => true,
        HomeType.aiDocumentAnalyzer => true,
      };

  // for padding
  EdgeInsets get padding => switch (this) {
        HomeType.aiChatBot => EdgeInsets.zero,
        HomeType.aiTranslator => EdgeInsets.zero,
        HomeType.aiEmailWriter => EdgeInsets.zero,
        HomeType.aiCodeGenerator => EdgeInsets.zero,
        HomeType.aiImageCaptioner => EdgeInsets.zero,
        HomeType.aiDocumentAnalyzer => EdgeInsets.zero,
      };

  // for navigation
  VoidCallback get onTap => switch (this) {
        HomeType.aiChatBot => () => Get.to(
              () => const Chatbot(),
              binding: BindingsBuilder(() {
                Get.lazyPut(() => ChathistoryController(), fenix: true);
              }),
            ),
        HomeType.aiTranslator => () => Get.to(() => TranslatorFeature()),
        HomeType.aiEmailWriter => () => Get.to(() => EmailWriterFeature()),
        HomeType.aiCodeGenerator => () => Get.to(() => AiCodeGenerator()),
        HomeType.aiImageCaptioner => () => Get.to(() => ImageCaptioner()),
        HomeType.aiDocumentAnalyzer => () =>
            Get.to(() => DocumentAnalyzerFeature()),
      };
}
