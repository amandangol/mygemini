import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygemini/controllers/chathistory_controller.dart';
import 'package:mygemini/ui/screens/chatbot/chatbot.dart';
import 'package:mygemini/ui/screens/email_gen/email_gen.dart';
import 'package:mygemini/ui/screens/image_feature.dart';
import 'package:mygemini/ui/screens/translation/translator_feature.dart';

import '../../ui/screens/code_generator/code_gen.dart';

enum HomeType { aiChatBot, aiTranslator, aiEmailWriter, aiCodeGenerator }

extension MyHomeType on HomeType {
  // title
  String get title => switch (this) {
        HomeType.aiChatBot => 'AI ChatBot',
        HomeType.aiTranslator => 'AI Translator',
        HomeType.aiEmailWriter => 'AI Email Writer',
        HomeType.aiCodeGenerator => 'AI Code Generator',
      };

  // lottie
  String get lottie => switch (this) {
        HomeType.aiChatBot => 'ai_hand_waving.json',
        HomeType.aiTranslator => 'ai_ask_me.json',
        HomeType.aiEmailWriter => 'ai_ask_me.json',
        HomeType.aiCodeGenerator => 'ai_ask_me.json',
      };

  // for alignment
  bool get leftAlign => switch (this) {
        HomeType.aiChatBot => true,
        HomeType.aiTranslator => true,
        HomeType.aiEmailWriter => false,
        HomeType.aiCodeGenerator => true,
      };

  // for padding
  EdgeInsets get padding => switch (this) {
        HomeType.aiChatBot => EdgeInsets.zero,
        HomeType.aiTranslator => EdgeInsets.zero,
        HomeType.aiEmailWriter => const EdgeInsets.all(20),
        HomeType.aiCodeGenerator => EdgeInsets.zero,
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
      };
}
