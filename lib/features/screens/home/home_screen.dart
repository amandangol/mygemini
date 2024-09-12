import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:mygemini/controllers/theme_controller.dart';
import 'package:mygemini/data/models/home_type.dart';
import 'package:mygemini/utils/helper/global.dart';
import 'package:mygemini/utils/helper/pref.dart';
import 'package:mygemini/widget/home_card.dart';
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
      appBar: _buildAppBar(),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.02,
          ),
          itemCount: HomeType.values.length,
          itemBuilder: (context, index) {
            return _buildHomeCard(HomeType.values[index]);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surfaceColor(context),
      elevation: 0,
      title: Text(appName, style: AppTheme.headlineMedium),
      actions: [
        _buildThemeToggle(),
      ],
    );
  }

  Widget _buildThemeToggle() {
    return Obx(() => Switch(
          value: themeController.isDarkMode.value,
          onChanged: (value) {
            themeController.toggleTheme();
            _setStatusBarStyle();
          },
          activeColor: AppTheme.primaryColor,
        ));
  }

  Widget _buildHomeCard(HomeType homeType) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.02),
      child: Card(
        color: AppTheme.surfaceColor(context),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: homeType.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildLottieAnimation(homeType),
                const SizedBox(width: 16),
                Expanded(child: _buildTitle(homeType)),
                Icon(Icons.arrow_forward_ios, color: AppTheme.secondaryColor),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildLottieAnimation(HomeType homeType) {
    return Container(
      width: size.width * 0.15,
      height: size.width * 0.15,
      padding: homeType.padding,
      child: Lottie.asset(
        'assets/lottie/${homeType.lottie}',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle(HomeType homeType) {
    return Text(
      homeType.title,
      style: AppTheme.bodyLarge.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
