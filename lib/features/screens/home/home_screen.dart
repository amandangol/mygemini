import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:mygemini/controllers/theme_controller.dart';
import 'package:mygemini/data/models/bot_type.dart';
import 'package:mygemini/utils/helper/global.dart';
import 'package:mygemini/utils/helper/pref.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final themeController = Get.put(ThemeController());

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _setStatusBarStyle();
    Pref.showOnboarding = false;
  }

  void _setStatusBarStyle() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          themeController.isDarkMode.value ? Brightness.light : Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            _buildWelcomeMessage(),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.02,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: size.width * 0.04,
                  mainAxisSpacing: size.height * 0.02,
                ),
                itemCount: BotType.values.length,
                itemBuilder: (context, index) {
                  return _buildHomeCard(BotType.values[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('assets/images/logo.png'),
                radius: 20,
              ),
              const SizedBox(width: 12),
              Text('MyGemini', style: AppTheme.headlineSmall),
            ],
          ),
          _buildThemeToggle(),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Text(
        'What would you like to do today?',
        style: AppTheme.headlineSmall,
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildThemeToggle() {
    return Obx(() => GestureDetector(
          onTap: () {
            themeController.toggleTheme();
            _setStatusBarStyle();
          },
          child: Container(
            width: 60,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: themeController.isDarkMode.value
                  ? AppTheme.primaryColor
                  : Colors.grey[300],
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  left: themeController.isDarkMode.value ? 30 : 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Icon(
                        themeController.isDarkMode.value
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        size: 20,
                        color: themeController.isDarkMode.value
                            ? AppTheme.primaryColor
                            : Colors.orange,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildHomeCard(BotType botType) {
    return Card(
      color: AppTheme.surfaceColor(context),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: botType.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLottieAnimation(botType),
              const SizedBox(height: 12),
              _buildTitle(botType),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  Widget _buildLottieAnimation(BotType botType) {
    return Container(
      width: size.width * 0.15,
      height: size.width * 0.15,
      padding: botType.padding,
      child: Lottie.asset(
        'assets/lottie/${botType.lottie}',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle(BotType botType) {
    return Text(
      botType.title,
      style: AppTheme.bodyMedium.copyWith(
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }
}
