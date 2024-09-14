import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:mygemini/data/models/bot_type.dart';
import 'package:mygemini/utils/helper/global.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';

class HomeCard extends StatelessWidget {
  final BotType botType;

  const HomeCard({super.key, required this.botType});

  @override
  Widget build(BuildContext context) {
    Animate.restartOnHotReload = true;

    return Card(
      color: AppTheme.surfaceColor(context),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: botType.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildLottieAnimation(),
              const SizedBox(width: 16),
              Expanded(child: _buildTitle(context)),
              Icon(Icons.arrow_forward_ios, color: AppTheme.secondaryColor),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 300.ms, curve: Curves.easeIn);
  }

  Widget _buildLottieAnimation() {
    return Container(
      width: size.width * 0.15,
      height: size.width * 0.15,
      padding: botType.padding,
      child: Lottie.asset(
        'assets/lottie/${botType.lottie}',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      botType.title,
      style: AppTheme.bodyLarge.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
