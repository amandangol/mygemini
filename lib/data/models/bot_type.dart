import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygemini/features/screens/chatbot/controller/chathistory_controller.dart';
import 'package:mygemini/features/screens/chatbot/chatbot.dart';
import 'package:mygemini/features/screens/creative_contentbot/creativecontent_bot.dart';
import 'package:mygemini/features/screens/document_analyzer/document_analyzer.dart';
import 'package:mygemini/features/screens/email_gen/emailbot_assistant.dart';
import 'package:mygemini/features/screens/image_assistant/image_assistant.dart';
import 'package:mygemini/features/screens/learning_assistant/learning_assistant.dart';
import 'package:mygemini/features/screens/translator/translator_screen.dart';

import '../../features/screens/code_generator/codebot_assistant.dart';

enum BotType {
  aiChatBot,
  aiTranslator,
  aiEmailWriter,
  aiCodeBot,
  aiCreativeContent,
  aiDocumentAnalyzer,
  aiLearningBot,
  aiImager
}

extension MyBotType on BotType {
  String get title => switch (this) {
        BotType.aiChatBot => 'AI Chat Assistant',
        BotType.aiTranslator => 'AI Translator',
        BotType.aiEmailWriter => 'AI Email Composer',
        BotType.aiCodeBot => 'AI Code Generator',
        BotType.aiCreativeContent => 'AI Content Creator',
        BotType.aiDocumentAnalyzer => 'AI Document Analyzer',
        BotType.aiLearningBot => 'AI Learning Assistant',
        BotType.aiImager => 'AI Trend Newsletter',
      };

  String get lottie => switch (this) {
        BotType.aiChatBot => 'ai_hand_waving.json',
        BotType.aiTranslator => 'ai_ask_me.json',
        BotType.aiEmailWriter => 'ai_ask_me.json',
        BotType.aiCodeBot => 'ai_play.json',
        BotType.aiCreativeContent => 'ai_hand_waving.json',
        BotType.aiDocumentAnalyzer => 'ai_ask_me.json',
        BotType.aiLearningBot => 'ai_ask_me.json',
        BotType.aiImager => 'ai_ask_me.json'
      };

  bool get leftAlign => switch (this) {
        BotType.aiChatBot => true,
        BotType.aiTranslator => true,
        BotType.aiEmailWriter => false,
        BotType.aiCodeBot => true,
        BotType.aiCreativeContent => true,
        BotType.aiDocumentAnalyzer => true,
        BotType.aiLearningBot => true,
        BotType.aiImager => true,
      };

  EdgeInsets get padding => switch (this) {
        BotType.aiChatBot => EdgeInsets.zero,
        BotType.aiTranslator => EdgeInsets.zero,
        BotType.aiEmailWriter => EdgeInsets.zero,
        BotType.aiCodeBot => EdgeInsets.zero,
        BotType.aiCreativeContent => EdgeInsets.zero,
        BotType.aiDocumentAnalyzer => EdgeInsets.zero,
        BotType.aiLearningBot => EdgeInsets.zero,
        BotType.aiImager => EdgeInsets.zero,
      };

  VoidCallback get onTap => switch (this) {
        BotType.aiChatBot => () => Get.to(
              () => ChatScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut(() => ChatHistoryController(), fenix: true);
              }),
            ),
        BotType.aiTranslator => () => Get.to(() => AiTranslatorBot()),
        BotType.aiEmailWriter => () => Get.to(() => AiEmailBot()),
        BotType.aiCodeBot => () => Get.to(() => AiCodeBot()),
        BotType.aiCreativeContent => () => Get.to(() => CreativeBotView()),
        BotType.aiDocumentAnalyzer => () =>
            Get.to(() => DocumentAnalyzerFeature()),
        BotType.aiLearningBot => () => Get.to(() => LearningChatbot()),
        BotType.aiImager => () => Get.to(() => TrendNewsletterGenerator()),
      };
}
