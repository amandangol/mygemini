import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:mygemini/controllers/ApiVersionController.dart';
import 'package:mygemini/controllers/theme_controller.dart';
import 'package:mygemini/data/models/bot_type.dart';
import 'package:mygemini/features/screens/home/TrendbasedNewsletterIntroduction.dart';
import 'package:mygemini/utils/helper/pref.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ThemeController themeController = Get.find<ThemeController>();
  final ApiVersionController apiVersionController =
      Get.find<ApiVersionController>();

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
      backgroundColor: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor,
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
              'https://static.vecteezy.com/system/resources/previews/021/835/780/original/artificial-intelligence-chatbot-assistance-background-free-vector.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 40),
                        SizedBox(height: 10),
                        Text(
                          'Image failed to load',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
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
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: _showSettingsModal,
        ),
      ],
    );
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Settings', style: AppTheme.headlineMedium),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      children: [
                        _buildSettingsItem(
                          title: 'Dark Mode',
                          subtitle: 'Toggle dark mode on/off',
                          trailing: Obx(() => Switch(
                                value: themeController.isDarkMode.value,
                                onChanged: (bool value) {
                                  themeController.toggleTheme();
                                  _setStatusBarStyle();
                                },
                                activeColor: AppTheme.primaryColor,
                                inactiveThumbColor: Colors.grey[400],
                                inactiveTrackColor: Colors.grey[300],
                              )),
                        ),
                        const Divider(),
                        _buildSettingsItem(
                          title: 'API Model',
                          subtitle:
                              'Choose between gemini-1.5-flash model and gemini-1.5-pro-latest model',
                          trailing: Obx(() => Switch(
                                value: apiVersionController
                                    .isUsingProVersion.value,
                                onChanged: (bool value) {
                                  apiVersionController.toggleApiVersion();
                                  _showApiSwitchSnackbar();
                                },
                                activeColor: AppTheme.primaryColor,
                                inactiveThumbColor: Colors.grey[400],
                                inactiveTrackColor: Colors.grey[300],
                              )),
                        ),
                        const Divider(),
                        // Add more settings items here
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      title: Text(title, style: AppTheme.bodyLarge),
      subtitle: Text(subtitle, style: AppTheme.bodySmall),
      trailing: trailing,
    );
  }

  void _showApiSwitchSnackbar() {
    Get.snackbar(
      'API Model Changed',
      'Now using ${apiVersionController.currentApiVersion}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
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
          Obx(() => Text(
                'Powered by ${apiVersionController.currentApiVersion}',
                style: AppTheme.bodyMedium.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).hintColor,
                ),
              )),
          const SizedBox(height: 20),
          Text(
            'How can I assist you today?',
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).hintColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark
            ? AppTheme.secondaryColor.withOpacity(0.8)
            : AppTheme.primaryColor.withOpacity(0.8),
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
