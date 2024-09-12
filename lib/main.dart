import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:mygemini/controllers/theme_controller.dart';
import 'package:mygemini/features/screens/splash/splash_screen.dart';
import 'package:mygemini/utils/helper/pref.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';

import 'utils/helper/global.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Pref.initialize();

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
        theme: lightTheme, // Light Theme
        darkTheme: darkTheme, // Dark Theme
        themeMode: themeController.theme, // Set theme mode
        home: const SplashScreen(),
      ),
    );
  }
}
