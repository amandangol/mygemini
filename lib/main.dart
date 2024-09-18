import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mygemini/controllers/theme_controller.dart';
import 'package:mygemini/data/models/chathistory.dart';
import 'package:mygemini/data/models/message.dart';
import 'package:mygemini/features/screens/chatbot/controller/chathistory_controller.dart';
import 'package:mygemini/features/screens/chatbot/controller/chat_controller.dart';
import 'package:mygemini/features/screens/splash/splash_screen.dart';
import 'package:mygemini/utils/helper/pref.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';
import 'package:path_provider/path_provider.dart';

import 'utils/helper/global.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for Flutter
  Directory appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);

  // Register Hive adapters
  Hive.registerAdapter(ChatHistoryAdapter()); // Adapter for ChatHistory
  Hive.registerAdapter(MessageAdapter()); // Adapter for Message
  Hive.registerAdapter(MessageTypeAdapter()); // Adapter for MessageType

  // Open Hive box for ChatHistory and clear it
  // var box = await Hive.openBox<ChatHistory>('chatHistory');
  // await box.clear(); // Clear existing data

  // Initialize preferences
  await Pref.initialize();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // System UI and orientation settings
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Start the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final themeController = Get.put(ThemeController());
  final chatHistoryController = Get.put(ChatHistoryController());
  final chatController = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.theme,
        home: const SplashScreen(),
      ),
    );
  }
}
