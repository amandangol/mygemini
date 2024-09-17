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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _setStatusBarStyle();
    Pref.showOnboarding = false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildWelcomeMessage()),
          SliverToBoxAdapter(child: _buildFeaturedCard()),
          SliverPadding(
            padding: EdgeInsets.all(size.width * 0.06),
            sliver: _buildSliverGrid(),
          ),
        ],
      ),
      floatingActionButton: _buildScrollToTopFAB(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppTheme.surfaceColor(context),
      elevation: 0,
      title: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage('assets/images/floating_robot.png'),
            radius: 25,
          ),
          const SizedBox(width: 5),
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
          Row(
            children: [
              Text(
                'Hello! ',
                style: AppTheme.headlineMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Image.asset(
                "assets/images/chatbot_icon.png",
                height: 40,
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'What would you like to do today?',
            style: AppTheme.bodyMedium,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trendbased Newsletter Generator',
                        style: AppTheme.headlineSmall
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create engaging newsletters with the latest trends using AI.',
                        style: AppTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => Get.to(
                            () => const TrendbasedNewsletterIntroduction()),
                        icon: const Icon(Icons.rocket_launch),
                        label: const Text('Get Started'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Lottie.asset(
                  'assets/lottie/lottie1.json',
                  width: size.width * 0.25,
                  height: size.width * 0.25,
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)));
  }

  Widget _buildSliverGrid() {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: size.width * 0.06,
        mainAxisSpacing: size.height * 0.03,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _buildHomeCard(BotType.values[index], index);
        },
        childCount: BotType.values.length,
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
              const SizedBox(height: 8),
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
                decoration: const BoxDecoration(
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

  Widget _buildScrollToTopFAB() {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        return AnimatedOpacity(
          opacity: _scrollController.offset > 100 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: FloatingActionButton(
            mini: true,
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: const Icon(Icons.arrow_upward),
          ),
        );
      },
    );
  }
}
