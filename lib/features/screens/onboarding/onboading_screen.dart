import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mygemini/features/screens/home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardItems = [
    {
      'title': 'AI Assistant',
      'subtitle': 'Your all-in-one companion',
      'lottie': 'lottie1',
      'color': const Color(0xFF6C63FF),
      'features': ['Chat Assistant', 'Translator', 'Email Composer'],
    },
    {
      'title': 'Boost Productivity',
      'subtitle': 'Enhance your work with AI',
      'lottie': 'lottie3',
      'color': const Color(0xFF00C853),
      'features': ['Code Generator', 'Document Analyzer', 'Learning Assistant'],
    },
    {
      'title': 'Unleash Creativity',
      'subtitle': 'Create and stay updated',
      'lottie': 'lottie2',
      'color': const Color.fromARGB(255, 34, 200, 255),
      'features': ['Content Creator', 'Trend Newsletter'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSkip() {
    Get.off(() => const HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardItems.length,
            itemBuilder: (context, index) {
              return _buildOnboardPage(_onboardItems[index]);
            },
          ),
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _onSkip,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: _onboardItems[_currentPage]['color'],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _buildPageIndicator(),
                const SizedBox(height: 20),
                _buildActionButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardPage(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            item['color'].withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/${item['lottie']}.json',
            height: MediaQuery.of(context).size.height * 0.35,
          ),
          const SizedBox(height: 40),
          Text(
            item['title'],
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: item['color'],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item['subtitle'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
          _buildFeatureList(item['features'], item['color']),
        ],
      ),
    );
  }

  Widget _buildFeatureList(List<String> features, Color color) {
    return Column(
      children:
          features.map((feature) => _buildFeatureItem(feature, color)).toList(),
    );
  }

  Widget _buildFeatureItem(String feature, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: color, size: 20),
          const SizedBox(width: 10),
          Text(
            feature,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardItems.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 30 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? _onboardItems[_currentPage]['color']
                : _onboardItems[_currentPage]['color'].withOpacity(0.3),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: _onboardItems[_currentPage]['color'],
        padding: const EdgeInsets.symmetric(
          horizontal: 50,
          vertical: 15,
        ),
        elevation: 0,
      ),
      onPressed: () {
        if (_currentPage == _onboardItems.length - 1) {
          Get.off(() => const HomeScreen());
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Text(
        _currentPage == _onboardItems.length - 1 ? 'Get Started' : 'Next',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
