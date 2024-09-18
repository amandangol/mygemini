import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:mygemini/controllers/theme_controller.dart';
import 'package:mygemini/data/models/bot_type.dart';
import 'package:mygemini/features/screens/home/TrendbasedNewsletterIntroduction.dart';
import 'package:mygemini/utils/helper/pref.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ThemeController themeController = Get.find<ThemeController>();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showFAB = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _setStatusBarStyle();
    Pref.showOnboarding = false;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _showFAB.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_showFAB.value) {
      _showFAB.value = true;
    } else if (_scrollController.offset <= 100 && _showFAB.value) {
      _showFAB.value = false;
    }
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor(context),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(child: _buildWelcomeSection(context)),
            SliverToBoxAdapter(child: _buildFeaturedCard(context)),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: _buildSliverGrid(context),
            ),
          ],
        ),
        floatingActionButton: _buildScrollToTopFAB(),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'MyGemini',
          style: AppTheme.headlineSmall.copyWith(
            color: Colors.white,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                offset: const Offset(1.0, 1.0),
                blurRadius: 3.0,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://media.istockphoto.com/id/1488335095/vector/3d-vector-robot-chatbot-ai-in-science-and-business-technology-and-engineering-concept.jpg?s=612x612&w=0&k=20&c=MSxiR6V1gROmrUBe1GpylDXs0D5CHT-mn0Up8D50mr8=',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    isDark
                        ? AppTheme.primaryColor.withOpacity(0.8)
                        : AppTheme.primaryColor.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        _buildThemeToggle(),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(context).copyWith(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Your AI Assistant Suite',
            style: AppTheme.headlineMedium.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Powered by Gemini-1.5-pro',
            style: AppTheme.bodySmall.copyWith(
              fontStyle: FontStyle.italic,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'How can I assist you today?',
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Get started by asking for assistance in daily tasks, document analyzing, or learning new concepts.',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slide(begin: const Offset(0, 0.1), end: Offset.zero);
  }

  Widget _buildFeaturedCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.8),
            AppTheme.primaryColor.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trendbased Newsletter Generator',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Create engaging newsletters with the latest trends using AI.',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  Get.to(() => const TrendbasedNewsletterIntroduction()),
              icon:
                  const Icon(Icons.rocket_launch, color: AppTheme.primaryColor),
              label: const Text('Get Started',
                  style: TextStyle(color: AppTheme.primaryColor)),
              style: ElevatedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
        );
  }

  Widget _buildSliverGrid(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) =>
            _buildHomeCard(BotType.values[index], index, context),
        childCount: BotType.values.length,
      ),
    );
  }

  Widget _buildHomeCard(BotType botType, int index, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              Text(
                botType.title,
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                botType.description,
                style: AppTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (100 * index).ms).fadeIn(duration: 300.ms).scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
        );
  }

  Widget _buildLottieAnimation(BotType botType) {
    return Container(
      width: 70,
      height: 70,
      padding: botType.padding,
      decoration: BoxDecoration(
        color: AppTheme.primaryColorLight(context),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Lottie.asset(
        'assets/lottie/${botType.lottie}',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Obx(() => IconButton(
          icon: Icon(
            themeController.isDarkMode.value
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            themeController.toggleTheme();
            _setStatusBarStyle();
          },
        ));
  }

  Widget _buildScrollToTopFAB() {
    return ValueListenableBuilder<bool>(
      valueListenable: _showFAB,
      builder: (context, show, child) {
        return AnimatedScale(
          scale: show ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton(
            mini: true,
            backgroundColor: AppTheme.primaryColor,
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: const Icon(Icons.arrow_upward, color: Colors.white),
          ),
        );
      },
    );
  }
}
