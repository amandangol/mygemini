import 'package:ai_assistant/utils/helper/global.dart';
import 'package:ai_assistant/data/models/onboard.dart';
import 'package:ai_assistant/ui/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pc = PageController();

    final list = [
      // onboarding 1
      Onboard(
          title: 'Ask me Aything',
          subtitle:
              'I can be your Best Friend & You can ask me anything. I will help you!',
          lottie: 'ai_ask_me'),

      // onboarding 2
      Onboard(
          title: 'Imagination to Reality',
          subtitle:
              'Just Imagine anything & let me know. I will create something wonderful for you!',
          lottie: 'ai_play'),
    ];

    return Scaffold(
      body: PageView.builder(
        controller: pc,
        itemCount: list.length,
        itemBuilder: (context, index) {
          final isLast = index == list.length - 1;

          return Column(
            children: [
              // animation
              Lottie.asset('assets/lottie/${list[index].lottie}.json',
                  height: mq.height * .6, width: isLast ? mq.width * .7 : null),

              // title
              Text(
                list[index].title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5),
              ),

              // add some spacing
              SizedBox(
                height: mq.height * .015,
              ),

              // subtitle
              SizedBox(
                width: mq.width * .7,
                child: Text(
                  list[index].subtitle,
                  style: const TextStyle(
                      fontSize: 13.5, letterSpacing: .5, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // dots
              Wrap(
                  spacing: 10,
                  children: List.generate(
                      2,
                      (i) => Container(
                            width: i == index ? 15 : 10,
                            height: 8,
                            decoration: BoxDecoration(
                                color: i == index ? Colors.blue : Colors.grey,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5))),
                          ))),

              const Spacer(),

              // button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    minimumSize: Size(mq.width * .3, 50),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white),
                onPressed: () {
                  if (isLast) {
                    Get.off(() => const HomeScreen());
                    // Navigator.of(context).pushReplacement(
                    //     MaterialPageRoute(builder: (_) => const HomeScreen()));
                  } else {
                    pc.nextPage(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.ease);
                  }
                },
                child: Text(
                  isLast ? 'Finish' : 'Next',
                ),
              ),

              const Spacer(
                flex: 2,
              ),
            ],
          );
        },
      ),
    );
  }
}
