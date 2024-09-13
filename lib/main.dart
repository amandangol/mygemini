import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:mygemini/controllers/theme_controller.dart';
import 'package:mygemini/features/screens/onboarding/onboading_screen.dart';
import 'package:mygemini/features/screens/splash/splash_screen.dart';
import 'package:mygemini/utils/helper/pref.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';
import 'package:path_provider/path_provider.dart';

import 'utils/helper/global.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  Directory appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);

  // Open Hive box
  await Pref.initialize(); // Initialize Hive in  Pref class

  await dotenv.load(fileName: ".env");
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, // Light Theme
        darkTheme: AppTheme.darkTheme, // Dark Theme
        themeMode: themeController.theme, // Set theme mode
        home: const SplashScreen(),
      ),
    );
  }
}
