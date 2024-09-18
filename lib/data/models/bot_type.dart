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
  aiChatBot, // Most versatile and commonly used
  aiLearningBot, // High impact for education
  aiCodeBot, // Essential for developers
  aiDocumentAnalyzer, // Important for productivity
  aiCreativeContent, // Valuable for content creators
  aiEmailWriter, // Useful for professional communication
  aiTranslator, // Important but might be less frequently used
  aiTrendNewsLetter, // Useful but might be considered less critical
}

extension MyBotType on BotType {
  String get title => switch (this) {
        BotType.aiChatBot => 'AI Chat Assistant',
        BotType.aiLearningBot => 'AI Learning Assistant',
        BotType.aiCodeBot => 'AI Code Generator',
        BotType.aiDocumentAnalyzer => 'AI Document Analyzer',
        BotType.aiCreativeContent => 'AI Content Creator',
        BotType.aiEmailWriter => 'AI Email Composer',
        BotType.aiTranslator => 'AI Translator',
        BotType.aiTrendNewsLetter => 'AI Trend Newsletter',
      };

  String get description => switch (this) {
        BotType.aiChatBot =>
          'Engage in intelligent conversations on any topic with our AI-powered chat assistant.',
        BotType.aiLearningBot =>
          'Enhance your learning experience with personalized AI tutoring on various subjects.',
        BotType.aiCodeBot =>
          'Generate clean, efficient code snippets and get programming help from our AI code assistant.',
        BotType.aiDocumentAnalyzer =>
          'Extract key insights and summarize lengthy documents with our AI-powered analyzer.',
        BotType.aiCreativeContent =>
          'Spark your creativity with AI-generated content ideas, from blog posts to social media.',
        BotType.aiEmailWriter =>
          'Compose professional and personalized emails effortlessly with AI assistance.',
        BotType.aiTranslator =>
          'Break language barriers with our advanced AI translator, supporting multiple languages.',
        BotType.aiTrendNewsLetter =>
          'Stay informed with AI-curated newsletters based on the latest trends and your interests.',
      };

  String get lottie => switch (this) {
        BotType.aiChatBot => 'lottie2.json',
        BotType.aiLearningBot => 'lottie3.json',
        BotType.aiCodeBot => 'lottie3.json',
        BotType.aiDocumentAnalyzer => 'ai_ask_me.json',
        BotType.aiCreativeContent => 'ai_ask_me.json',
        BotType.aiEmailWriter => 'lottie2.json',
        BotType.aiTranslator => 'lottie3.json',
        BotType.aiTrendNewsLetter => 'lottie2.json',
      };

  bool get leftAlign => switch (this) {
        BotType.aiChatBot => true,
        BotType.aiLearningBot => true,
        BotType.aiCodeBot => true,
        BotType.aiDocumentAnalyzer => true,
        BotType.aiCreativeContent => true,
        BotType.aiEmailWriter => false,
        BotType.aiTranslator => true,
        BotType.aiTrendNewsLetter => true,
      };

  EdgeInsets get padding => switch (this) {
        BotType.aiChatBot => EdgeInsets.zero,
        BotType.aiLearningBot => EdgeInsets.zero,
        BotType.aiCodeBot => EdgeInsets.zero,
        BotType.aiDocumentAnalyzer => EdgeInsets.zero,
        BotType.aiCreativeContent => EdgeInsets.zero,
        BotType.aiEmailWriter => EdgeInsets.zero,
        BotType.aiTranslator => EdgeInsets.zero,
        BotType.aiTrendNewsLetter => EdgeInsets.zero,
      };

  VoidCallback get onTap => switch (this) {
        BotType.aiChatBot => () => Get.to(
              () => const ChatScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut(() => ChatHistoryController(), fenix: true);
              }),
            ),
        BotType.aiLearningBot => () => Get.to(() => const LearningChatbot()),
        BotType.aiCodeBot => () => Get.to(() => const AiCodeBot()),
        BotType.aiDocumentAnalyzer => () =>
            Get.to(() => const DocumentAnalyzerFeature()),
        BotType.aiCreativeContent => () =>
            Get.to(() => const CreativeBotView()),
        BotType.aiEmailWriter => () => Get.to(() => const AiEmailBot()),
        BotType.aiTranslator => () => Get.to(() => const AiTranslatorBot()),
        BotType.aiTrendNewsLetter => () =>
            Get.to(() => const TrendNewsletterGenerator()),
      };
}
