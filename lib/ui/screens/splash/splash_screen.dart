import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygemini/ui/screens/home/home_screen.dart';
import 'package:mygemini/ui/screens/onboarding/onboading_screen.dart';
import 'package:mygemini/utils/helper/global.dart';
import 'package:mygemini/utils/helper/pref.dart';
import 'package:mygemini/widget/custom_loading.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // wait for some time on splash & then move to next screen
    Future.delayed(const Duration(seconds: 2), () {
      // Navigator.of(context).pushReplacement(MaterialPageRoute(
      //     builder: (_) => Pref.showOnboarding
      //         ? const OnboardingScreen()
      //         : const HomeScreen()));
      Get.off(() =>
          Pref.showOnboarding ? const OnboardingScreen() : const HomeScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initializing device size
    mq = MediaQuery.sizeOf(context);

    return Scaffold(
      body: SizedBox(
        width: double.maxFinite,
        child: Column(
          children: [
            // for adding some space
            const Spacer(flex: 3),
            Card(
              color: const Color.fromARGB(255, 173, 214, 248),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.all(mq.width * .05),
                child: Image.asset(
                  'assets/images/logo-chatbot.png',
                  width: mq.width * .45,
                ),
              ),
            ),
            const Spacer(),
            const CustomLoading(),
            const Spacer()
          ],
        ),
      ),
    );
  }
}
