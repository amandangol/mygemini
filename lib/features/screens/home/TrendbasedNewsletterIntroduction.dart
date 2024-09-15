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
        title: Text('Trendbased Newsletter Generator'),
        backgroundColor: AppTheme.primaryColor,
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
              SizedBox(height: 24),
              Text(
                'Create Engaging Newsletters with AI',
                style: AppTheme.headlineMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildFeatureCard(
                icon: Icons.trending_up,
                title: 'Trend Analysis',
                description:
                    'Automatically identify and incorporate the latest trends in your industry.',
              ),
              _buildFeatureCard(
                icon: Icons.article_outlined,
                title: 'Content Generation',
                description:
                    'Generate engaging articles and summaries based on trending topics.',
              ),
              _buildFeatureCard(
                icon: Icons.design_services,
                title: 'Layout Suggestions',
                description:
                    'Get AI-powered layout recommendations for visually appealing newsletters.',
              ),
              _buildFeatureCard(
                icon: Icons.people_outline,
                title: 'Audience Targeting',
                description:
                    'Tailor content to your specific audience demographics and interests.',
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
