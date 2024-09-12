import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mygemini/features/screens/home/home_screen.dart';

class Onboard {
  final String title;
  final String subtitle;
  final String lottie;

  Onboard({required this.title, required this.subtitle, required this.lottie});
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Onboard> _onboardItems = [
    Onboard(
      title: 'Welcome to AI Assistant',
      subtitle: 'Your all-in-one AI companion for various tasks',
      lottie: 'ai_hand_waving',
    ),
    Onboard(
      title: 'Chat with AI',
      subtitle: 'Get answers and assistance on any topic',
      lottie: 'ai_play',
    ),
    Onboard(
      title: 'Translate Languages',
      subtitle: 'Break language barriers with our translation feature',
      lottie: 'ai_ask_me',
    ),
    Onboard(
      title: 'Email Assistant',
      subtitle: 'Compose and manage emails effortlessly',
      lottie: 'ai_play',
    ),
    Onboard(
      title: 'Code Assistant',
      subtitle: 'Get help with coding and debugging',
      lottie: 'ai_hand_waving',
    ),
    Onboard(
      title: 'Creative Assistant',
      subtitle: 'Unleash your creativity with AI-powered tools',
      lottie: 'ai_ask_me',
    ),
    Onboard(
      title: 'Document Analyzer',
      subtitle: 'Extract insights from your documents',
      lottie: 'ai_hand_waving',
    ),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardItems.length,
            itemBuilder: (context, index) {
              return _buildOnboardPage(_onboardItems[index], size);
            },
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _buildPageIndicator(),
                SizedBox(height: size.height * 0.03),
                _buildActionButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardPage(Onboard item, Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/lottie/${item.lottie}.json',
          height: size.height * 0.4,
        ),
        SizedBox(height: size.height * 0.05),
        Text(
          item.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            item.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
      ],
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
          width: _currentPage == index ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.blue
                : Colors.blue.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
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
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 15,
        ),
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
