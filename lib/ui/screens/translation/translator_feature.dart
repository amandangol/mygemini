import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mygemini/commonwidgets/custom_inputfield.dart';
import 'package:mygemini/controllers/translator_controller.dart';

class TranslatorFeature extends StatelessWidget {
  TranslatorFeature({Key? key}) : super(key: key);

  final TranslatorController controller = Get.put(TranslatorController());

  final Color primaryColor = const Color(0xFF3498DB);
  final Color backgroundColor = const Color(0xFFF0F4F8);
  final Color textColor = const Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('AI Translator',
            style: TextStyle(
                color: Color(0xFF2C3E50), fontWeight: FontWeight.w300)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
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

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
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
        dropdownColor: Colors.white,
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
        color: Colors.white,
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
        CustomInputField(
          controller: controller.sourceTextC,
          label: 'Source Text',
          hint: 'Enter text to translate',
          maxLines: 5,
          readOnly: false,
        ),
        const SizedBox(height: 16),
        Obx(() => controller.isTranslating.value
            ? LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                backgroundColor: Colors.white,
              )
            : CustomInputField(
                controller: controller.targetTextC,
                label: 'Translation',
                hint: 'Translation will appear here',
                maxLines: 5,
                readOnly: false,
              )),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildTranslateButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3498DB).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: controller.translate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Translate',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            SizedBox(width: 8),
            Icon(Icons.translate, color: Colors.white),
          ],
        ),
      ),
    )
        .animate(target: controller.isTranslating.value ? 1 : 0)
        .shimmer(duration: 1000.ms, color: Colors.white.withOpacity(0.3))
        .shake(hz: 4, curve: Curves.easeInOutCubic);
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
