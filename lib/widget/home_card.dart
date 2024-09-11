import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:mygemini/data/models/home_type.dart';
import 'package:mygemini/utils/helper/global.dart';

class HomeCard extends StatelessWidget {
  final HomeType homeType;

  const HomeCard({super.key, required this.homeType});

  @override
  Widget build(BuildContext context) {
    Animate.restartOnHotReload = true;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
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
              _buildLottieAnimation(),
              const SizedBox(width: 16),
              Expanded(child: _buildTitle()),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFF95A5A6)),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 300.ms, curve: Curves.easeIn);
  }

  Widget _buildLottieAnimation() {
    return Container(
      width: mq.width * 0.15,
      height: mq.width * 0.15,
      padding: homeType.padding,
      child: Lottie.asset(
        'assets/lottie/${homeType.lottie}',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      homeType.title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF2C3E50),
        letterSpacing: 0.5,
      ),
    );
  }
}
