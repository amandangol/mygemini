import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygemini/features/screens/chatbot/controller/chathistory_controller.dart';
import 'package:mygemini/features/screens/chatbot/chatbot.dart';
import 'package:mygemini/features/screens/creative_contentbot/creativecontent_bot.dart';
import 'package:mygemini/features/screens/document_analyzer/document_analyzer.dart';
import 'package:mygemini/features/screens/email_gen/emailbot_assistant.dart';
import 'package:mygemini/features/screens/trendbased_news_gen/trendbased_newsletter.dart';
import 'package:mygemini/features/screens/learning_assistant/learning_assistant.dart';
import 'package:mygemini/features/screens/translator/translator_screen.dart';
import 'package:mygemini/features/screens/code_generator/codebot_assistant.dart';

enum BotType {
  aiChatBot,
  aiTranslator,
  aiEmailWriter,
  aiCodeBot,
  aiCreativeContent,
  aiDocumentAnalyzer,
  aiLearningBot,
  aiTrendNewsLetter
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
        BotType.aiTrendNewsLetter => 'AI Trend Newsletter',
      };

  String get description => switch (this) {
        BotType.aiChatBot =>
          'Engage in intelligent conversations on any topic with our AI-powered chat assistant.',
        BotType.aiTranslator =>
          'Break language barriers with our advanced AI translator, supporting multiple languages.',
        BotType.aiEmailWriter =>
          'Compose professional and personalized emails effortlessly with AI assistance.',
        BotType.aiCodeBot =>
          'Generate clean, efficient code snippets and get programming help from our AI code assistant.',
        BotType.aiCreativeContent =>
          'Spark your creativity with AI-generated content ideas, from blog posts to social media.',
        BotType.aiDocumentAnalyzer =>
          'Extract key insights and summarize lengthy documents with our AI-powered analyzer.',
        BotType.aiLearningBot =>
          'Enhance your learning experience with personalized AI tutoring on various subjects.',
        BotType.aiTrendNewsLetter =>
          'Stay informed with AI-curated newsletters based on the latest trends and your interests.',
      };

  String get lottie => switch (this) {
        BotType.aiChatBot => 'lottie2.json',
        BotType.aiTranslator => 'ai_ask_me.json',
        BotType.aiEmailWriter => 'ai_ask_me.json',
        BotType.aiCodeBot => 'lottie2.json',
        BotType.aiCreativeContent => 'lottie2.json',
        BotType.aiDocumentAnalyzer => 'lottie3.json',
        BotType.aiLearningBot => 'lottie3.json',
        BotType.aiTrendNewsLetter => 'lottie2.json',
      };

  bool get leftAlign => switch (this) {
        BotType.aiChatBot => true,
        BotType.aiTranslator => true,
        BotType.aiEmailWriter => false,
        BotType.aiCodeBot => true,
        BotType.aiCreativeContent => true,
        BotType.aiDocumentAnalyzer => true,
        BotType.aiLearningBot => true,
        BotType.aiTrendNewsLetter => true,
      };

  EdgeInsets get padding => switch (this) {
        BotType.aiChatBot => EdgeInsets.zero,
        BotType.aiTranslator => EdgeInsets.zero,
        BotType.aiEmailWriter => EdgeInsets.zero,
        BotType.aiCodeBot => EdgeInsets.zero,
        BotType.aiCreativeContent => EdgeInsets.zero,
        BotType.aiDocumentAnalyzer => EdgeInsets.zero,
        BotType.aiLearningBot => EdgeInsets.zero,
        BotType.aiTrendNewsLetter => EdgeInsets.zero,
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
        BotType.aiTrendNewsLetter => () =>
            Get.to(() => TrendNewsletterGenerator()),
      };
}
