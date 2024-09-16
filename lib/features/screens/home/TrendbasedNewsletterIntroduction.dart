import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';
import 'package:mygemini/features/screens/trendbased_news_gen/trendbased_newsletter.dart';

class TrendbasedNewsletterIntroduction extends StatelessWidget {
  const TrendbasedNewsletterIntroduction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Trendbased Newsletter Generator",
          style: AppTheme.headlineMedium.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w200,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Lottie.asset(
                  'assets/lottie/lottie2.json',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Create Engaging Newsletters with AI',
                style: AppTheme.headlineMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildFeatureCard(
                icon: Icons.trending_up,
                title: 'Trend Analysis',
                description: 'Get the latest trends in your chosen topic',
              ),
              _buildFeatureCard(
                icon: Icons.article_outlined,
                title: 'Content Generation',
                description:
                    'Generate engaging articles and summaries based on trending topics.',
              ),
              _buildFeatureCard(
                icon: Icons.chat_bubble_outline,
                title: 'Interactive Chat',
                description:
                    'Refine and customize your newsletter through conversation.',
              ),
              _buildFeatureCard(
                icon: Icons.people_outline,
                title: 'Easy Sharing',
                description: 'Share your generated newsletter with just a tap.',
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => TrendNewsletterGenerator());
                  },
                  child: Text('Start Creating Newsletters'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 48, color: AppTheme.primaryColor),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTheme.bodyMedium
                          .copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(description, style: AppTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
