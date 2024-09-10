import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_assistant/controllers/translator_controller.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class TranslatorFeature extends StatelessWidget {
  TranslatorFeature({Key? key}) : super(key: key);

  final TranslatorController controller = Get.put(TranslatorController());

  // Define new color scheme
  final Color primaryColor = const Color(0xFF6B9080);
  final Color backgroundColor = const Color(0xFFF6FFF8);
  final Color accentColor = const Color(0xFFCCE3DE);
  final Color textColor = const Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildLanguageSelector(),
              const SizedBox(height: 32),
              _buildTranslationFields(),
              const SizedBox(height: 32),
              _buildTranslateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            'AI Translator',
            textStyle: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
            speed: const Duration(milliseconds: 25),
          ),
        ],
        totalRepeatCount: 1,
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Obx(() => _buildLanguageDropdown(controller.sourceLang))),
          _buildSwapButton(),
          Expanded(
              child: Obx(() => _buildLanguageDropdown(controller.targetLang))),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown(Rx<String> language) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: language.value,
        items: controller.supportedLanguages.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Row(
              children: [
                _buildFlagIcon(value),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(value, style: TextStyle(color: textColor)),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            language.value = newValue;
          }
        },
        icon: Icon(Icons.arrow_drop_down, color: primaryColor),
        dropdownColor: accentColor,
        isExpanded: true,
        style: TextStyle(color: textColor),
      ),
    );
  }

  Widget _buildFlagIcon(String language) {
    String countryCode = _getCountryCode(language);
    return CachedNetworkImage(
      imageUrl: 'https://flagcdn.com/w40/$countryCode.png',
      width: 24,
      height: 24,
      placeholder: (context, url) => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      errorWidget: (context, url, error) => Container(
        width: 24,
        height: 24,
        color: accentColor,
        child: Center(
          child: Text(
            language.substring(0, 2).toUpperCase(),
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
          ),
        ),
      ),
    );
  }

  Widget _buildSwapButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14159,
          child: IconButton(
            icon: Icon(Icons.swap_horiz, color: primaryColor),
            onPressed: () {
              controller.swapLanguages();
              // Trigger the animation again
              (context as Element).markNeedsBuild();
            },
          ),
        );
      },
    );
  }

  Widget _buildTranslationFields() {
    return Column(
      children: [
        _buildTextField(controller.sourceTextC, 'Enter text to translate'),
        const SizedBox(height: 16),
        Obx(() => controller.isTranslating.value
            ? LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                backgroundColor: accentColor,
              )
            : _buildTextField(
                controller.targetTextC, 'Translation will appear here',
                readOnly: true)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController textController, String hintText,
      {bool readOnly = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: textController,
        maxLines: 5,
        readOnly: readOnly,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: textColor.withOpacity(0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildTranslateButton() {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: ElevatedButton(
          onPressed: controller.translate,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Translate', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Icon(Icons.translate),
            ],
          ),
        ),
      ),
    );
  }

  String _getCountryCode(String language) {
    switch (language.toLowerCase()) {
      case 'english':
        return 'gb';
      case 'spanish':
        return 'es';
      case 'french':
        return 'fr';
      case 'german':
        return 'de';
      case 'italian':
        return 'it';
      case 'portuguese':
        return 'pt';
      case 'russian':
        return 'ru';
      case 'chinese':
        return 'cn';
      case 'japanese':
        return 'jp';
      case 'korean':
        return 'kr';
      case 'nepali':
        return 'np';
      default:
        return 'un';
    }
  }
}
