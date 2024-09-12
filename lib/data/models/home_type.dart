import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygemini/features/screens/chatbot/controller/chathistory_controller.dart';
import 'package:mygemini/features/screens/chatbot/chatbot.dart';
import 'package:mygemini/features/screens/creative_contentbot/creativecontent_bot.dart';
import 'package:mygemini/features/screens/document_analyzer/document_analyzer.dart';
import 'package:mygemini/features/screens/email_gen/emailbot_assistant.dart';
import 'package:mygemini/features/screens/translator/translator_screen.dart';

import '../../features/screens/code_generator/codebot_assistant.dart';

enum HomeType {
  aiChatBot,
  aiTranslator,
  aiEmailWriter,
  aiCodeBot,
  aiCreativeContent,
  aiDocumentAnalyzer
}

extension MyHomeType on HomeType {
  // title
  String get title => switch (this) {
        HomeType.aiChatBot => 'ChatBot Assistant',
        HomeType.aiTranslator => 'TranslatorBot Assistant',
        HomeType.aiEmailWriter => 'EmailBot Assistant',
        HomeType.aiCodeBot => 'CodeBot Assistant',
        HomeType.aiCreativeContent => 'Creative Content Assistant',
        HomeType.aiDocumentAnalyzer => 'DocAnalyzer Assistant',
      };

  // lottie
  String get lottie => switch (this) {
        HomeType.aiChatBot => 'ai_hand_waving.json',
        HomeType.aiTranslator => 'ai_ask_me.json',
        HomeType.aiEmailWriter => 'ai_ask_me.json',
        HomeType.aiCodeBot => 'ai_play.json',
        HomeType.aiCreativeContent => 'ai_hand_waving.json',
        HomeType.aiDocumentAnalyzer => 'ai_ask_me.json'
      };

  // for alignment
  bool get leftAlign => switch (this) {
        HomeType.aiChatBot => true,
        HomeType.aiTranslator => true,
        HomeType.aiEmailWriter => false,
        HomeType.aiCodeBot => true,
        HomeType.aiCreativeContent => true,
        HomeType.aiDocumentAnalyzer => true,
      };

  // for padding
  EdgeInsets get padding => switch (this) {
        HomeType.aiChatBot => EdgeInsets.zero,
        HomeType.aiTranslator => EdgeInsets.zero,
        HomeType.aiEmailWriter => EdgeInsets.zero,
        HomeType.aiCodeBot => EdgeInsets.zero,
        HomeType.aiCreativeContent => EdgeInsets.zero,
        HomeType.aiDocumentAnalyzer => EdgeInsets.zero,
      };

  // for navigation
  VoidCallback get onTap => switch (this) {
        HomeType.aiChatBot => () => Get.to(
              () => Chatbot(),
              binding: BindingsBuilder(() {
                Get.lazyPut(() => ChatHistoryController(), fenix: true);
              }),
            ),
        HomeType.aiTranslator => () => Get.to(() => AiTranslatorBot()),
        HomeType.aiEmailWriter => () => Get.to(() => AiEmailBot()),
        HomeType.aiCodeBot => () => Get.to(() => AiCodeBot()),
        HomeType.aiCreativeContent => () => Get.to(() => CreativeBotView()),
        HomeType.aiDocumentAnalyzer => () =>
            Get.to(() => DocumentAnalyzerFeature()),
      };
}
