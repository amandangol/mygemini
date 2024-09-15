import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:mygemini/controllers/theme_controller.dart';
import 'package:mygemini/data/models/bot_type.dart';
import 'package:mygemini/features/screens/home/TrendbasedNewsletterIntroduction.dart';
import 'package:mygemini/utils/helper/global.dart';
import 'package:mygemini/utils/helper/pref.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
    size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeMessage(),
            _buildFeaturedCard(),
            _buildGridView(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surfaceColor(context),
      elevation: 0,
      title: Row(
        children: [
          Hero(
            tag: 'app_logo',
            child: const CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage('assets/images/chatbot_logo.png'),
              radius: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text('MyGemini', style: AppTheme.headlineMedium),
        ],
      ),
      actions: [
        _buildThemeToggle(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, User!',
            style: AppTheme.headlineLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'What would you like to do today?',
            style: AppTheme.bodyLarge,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildFeaturedCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: Card(
        color: AppTheme.primaryColor.withOpacity(0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Try our new Trendbased Newsletter Generator',
                      style: AppTheme.headlineSmall
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create engaging newsletters with the latest trends using AI.',
                      style: AppTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => TrendbasedNewsletterIntroduction());
                      },
                      child: Text('Get Started'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Lottie.asset(
                'assets/lottie/lottie1.json',
                width: size.width * 0.2,
                height: size.width * 0.2,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildGridView() {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.06),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: size.width * 0.06,
          mainAxisSpacing: size.height * 0.03,
        ),
        itemCount: BotType.values.length,
        itemBuilder: (context, index) {
          return _buildHomeCard(BotType.values[index], index);
        },
      ),
    );
  }

  Widget _buildHomeCard(BotType botType, int index) {
    return Card(
      color: AppTheme.surfaceColor(context),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: botType.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLottieAnimation(botType),
              const SizedBox(height: 16),
              _buildTitle(botType),
              const SizedBox(height: 8),
              _buildDescription(botType),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (100 * index).ms)
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  Widget _buildLottieAnimation(BotType botType) {
    return Container(
      width: size.width * 0.2,
      height: size.width * 0.2,
      padding: botType.padding,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
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
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(BotType botType) {
    return Text(
      botType.description,
      style: AppTheme.bodySmall,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildThemeToggle() {
    return Obx(() => GestureDetector(
          onTap: () {
            themeController.toggleTheme();
            _setStatusBarStyle();
          },
          child: Container(
            width: 50,
            height: 25,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: themeController.isDarkMode.value
                  ? AppTheme.primaryColor
                  : Colors.grey[300],
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: themeController.isDarkMode.value
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: Icon(
                    themeController.isDarkMode.value
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    size: 16,
                    color: themeController.isDarkMode.value
                        ? AppTheme.primaryColor
                        : Colors.orange,
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
