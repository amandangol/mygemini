import "package:ai_assistant/utils/helper/global.dart";
import "package:ai_assistant/data/models/home_type.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:lottie/lottie.dart";

class HomeCard extends StatelessWidget {
  final HomeType homeType;

  // Define new color scheme
  final Color primaryColor = const Color(0xFF6B9080);
  final Color backgroundColor = const Color(0xFFF6FFF8);
  final Color accentColor = const Color(0xFFCCE3DE);
  final Color textColor = const Color(0xFF2C3E50);

  const HomeCard({super.key, required this.homeType});

  @override
  Widget build(BuildContext context) {
    Animate.restartOnHotReload = true;

    return Card(
      color: accentColor.withOpacity(0.5),
      elevation: 0,
      margin: EdgeInsets.only(bottom: mq.height * .02),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: homeType.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: homeType.leftAlign
              ? _buildLeftAlignedContent()
              : _buildRightAlignedContent(),
        ),
      ),
    )
        .animate()
        .fade(duration: NumDurationExtensions(1).seconds, curve: Curves.easeIn);
  }

  Widget _buildLeftAlignedContent() {
    return Row(
      children: [
        _buildLottieAnimation(),
        const Spacer(),
        _buildTitle(),
        const Spacer(flex: 2),
      ],
    );
  }

  Widget _buildRightAlignedContent() {
    return Row(
      children: [
        const Spacer(flex: 2),
        _buildTitle(),
        const Spacer(),
        _buildLottieAnimation(),
      ],
    );
  }

  Widget _buildLottieAnimation() {
    return Container(
      width: mq.width * .3,
      height: mq.width * .3,
      padding: homeType.padding,
      child: Lottie.asset(
        'assets/lottie/${homeType.lottie}',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle() {
    return Flexible(
      child: Text(
        homeType.title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textColor,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
