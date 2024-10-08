import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mygemini/commonwidgets/custom_actionbuttons.dart';
import 'package:mygemini/commonwidgets/custom_appbar.dart';
import 'package:mygemini/commonwidgets/custom_intro_dialog.dart';
import 'package:mygemini/commonwidgets/selectable_markdown.dart';
import 'package:mygemini/features/screens/translator/controller/translator_controller.dart';
import 'package:mygemini/features/screens/translator/model/translator_model.dart';
import 'package:mygemini/utils/theme/ThemeData.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiTranslatorBot extends StatefulWidget {
  const AiTranslatorBot({super.key});

  @override
  State<AiTranslatorBot> createState() => _AiTranslatorBotState();
}

class _AiTranslatorBotState extends State<AiTranslatorBot> {
  final TranslatorController controller = Get.put(TranslatorController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    controller.chatMessages.listen((_) => _scrollToBottom());
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
    _checkFirstLaunch();
  }

  void _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunchTranslator') ?? true;
    if (isFirstLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showIntroDialog();
      });
      await prefs.setBool('isFirstLaunchTranslator', false);
    }
  }

  void _showIntroDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomIntroDialog(
          title: 'Welcome to AI Translator',
          features: [
            FeatureItem(
              icon: Icons.translate,
              title: 'AI-Powered Translation',
              description:
                  'Translate text between numerous languages with advanced AI.',
            ),
            FeatureItem(
              icon: Icons.chat_bubble_outline,
              title: 'Interactive Chat Interface',
              description:
                  'View your translation history in a user-friendly chat format.',
            ),
            FeatureItem(
              icon: Icons.swap_horiz,
              title: 'Quick Language Swap',
              description: 'Easily switch between source and target languages.',
            ),
            FeatureItem(
              icon: Icons.flag_outlined,
              title: 'Visual Language Selection',
              description:
                  'Choose languages with country flag icons for easy recognition.',
            ),
            FeatureItem(
              icon: Icons.share,
              title: 'Easy Sharing',
              description: 'Share your translated text directly from the app.',
            ),
          ],
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: _buildCustomAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() => _buildTranslationMessages(context)),
            ),
            _buildMaxLengthWarning(context),
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return CustomAppBar(
      title: 'AI Translator',
      onResetConversation: () {
        controller.resetConversation();
      },
      onInfoPressed: _showIntroDialog,
    );
  }

  Widget _buildTranslationMessages(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: AppTheme.defaultPadding,
      itemCount: controller.chatMessages.length,
      itemBuilder: (context, index) {
        final message = controller.chatMessages[index];
        return _buildMessageBubble(context, message);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, TranslationMessage message) {
    final isUserMessage = message.isUser;
    final bubbleColor =
        isUserMessage ? AppTheme.primaryColor : AppTheme.surfaceColor(context);
    final textColor = isUserMessage
        ? Colors.white
        : Theme.of(context).textTheme.bodyLarge!.color!;

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUserMessage ? 'You' : 'TranslatorBot',
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            SelectableMarkdown(
              data: message.text,
              textColor: textColor,
            ),
            if (!isUserMessage)
              Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: CustomActionButtons(
                    text: message.text,
                    shareSubject:
                        'Generated translation text from TranslatorBot Assistant',
                  )),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMaxLengthWarning(BuildContext context) {
    return Obx(() {
      if (controller.isMaxLengthReached.value) {
        return Container(
          padding: const EdgeInsets.all(8),
          color: Colors.yellow,
          child: Text(
            'Maximum conversation length reached. Please reset the conversation to continue.',
            style: AppTheme.bodyMedium.copyWith(color: Colors.black),
            textAlign: TextAlign.center,
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: AppTheme.defaultPadding,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLanguageSelector(context),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.inputController,
                  style: AppTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Enter text to translate...',
                    hintStyle: AppTheme.bodyMedium
                        .copyWith(color: Theme.of(context).hintColor),
                    border: Theme.of(context).inputDecorationTheme.border,
                    filled: true,
                    fillColor: AppTheme.primaryColorLight(context),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                ),
              ),
              const SizedBox(width: 12),
              Obx(() => _buildTranslateButton(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Obx(() =>
                  _buildLanguageDropdown(context, controller.sourceLang))),
          _buildSwapButton(context),
          Expanded(
              child: Obx(() =>
                  _buildLanguageDropdown(context, controller.targetLang))),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown(BuildContext context, Rx<String> language) {
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
                  child: Text(value, style: TextStyle(color: Colors.grey[600])),
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
        icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
        dropdownColor: AppTheme.surfaceColor(context),
        isExpanded: true,
        style: AppTheme.bodyMedium,
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
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSwapButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.swap_horiz, color: AppTheme.primaryColor),
      onPressed: controller.swapLanguages,
    );
  }

  Widget _buildTranslateButton(BuildContext context) {
    return ElevatedButton(
      onPressed: controller.isProcessing.value ? null : controller.translate,
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
      ),
      child: controller.isProcessing.value
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.translate, size: 24),
    );
  }

  String _getCountryCode(String language) {
    switch (language.toLowerCase()) {
      case 'afrikaans':
        return 'za';
      case 'albanian':
        return 'al';
      case 'amharic':
        return 'et';
      case 'arabic':
        return 'sa';
      case 'armenian':
        return 'am';
      case 'azerbaijani':
        return 'az';
      case 'basque':
        return 'es';
      case 'belarusian':
        return 'by';
      case 'bengali':
        return 'bd';
      case 'bosnian':
        return 'ba';
      case 'bulgarian':
        return 'bg';
      case 'burmese':
        return 'mm';
      case 'catalan':
        return 'es';
      case 'chinese':
        return 'cn';
      case 'croatian':
        return 'hr';
      case 'czech':
        return 'cz';
      case 'danish':
        return 'dk';
      case 'dutch':
        return 'nl';
      case 'english':
        return 'gb';
      case 'estonian':
        return 'ee';
      case 'filipino':
        return 'ph';
      case 'finnish':
        return 'fi';
      case 'french':
        return 'fr';
      case 'galician':
        return 'es';
      case 'georgian':
        return 'ge';
      case 'german':
        return 'de';
      case 'greek':
        return 'gr';
      case 'gujarati':
        return 'in';
      case 'haitian creole':
        return 'ht';
      case 'hausa':
        return 'ng';
      case 'hebrew':
        return 'il';
      case 'hindi':
        return 'in';
      case 'hungarian':
        return 'hu';
      case 'icelandic':
        return 'is';
      case 'igbo':
        return 'ng';
      case 'indonesian':
        return 'id';
      case 'irish':
        return 'ie';
      case 'italian':
        return 'it';
      case 'japanese':
        return 'jp';
      case 'javanese':
        return 'id';
      case 'kannada':
        return 'in';
      case 'kazakh':
        return 'kz';
      case 'khmer':
        return 'kh';
      case 'korean':
        return 'kr';
      case 'lao':
        return 'la';
      case 'latvian':
        return 'lv';
      case 'lithuanian':
        return 'lt';
      case 'macedonian':
        return 'mk';
      case 'malay':
        return 'my';
      case 'malayalam':
        return 'in';
      case 'maltese':
        return 'mt';
      case 'maori':
        return 'nz';
      case 'marathi':
        return 'in';
      case 'mongolian':
        return 'mn';
      case 'nepali':
        return 'np';
      case 'norwegian':
        return 'no';
      case 'persian':
        return 'ir';
      case 'polish':
        return 'pl';
      case 'portuguese':
        return 'pt';
      case 'punjabi':
        return 'in';
      case 'romanian':
        return 'ro';
      case 'russian':
        return 'ru';
      case 'serbian':
        return 'rs';
      case 'sinhala':
        return 'lk';
      case 'slovak':
        return 'sk';
      case 'slovenian':
        return 'si';
      case 'somali':
        return 'so';
      case 'spanish':
        return 'es';
      case 'swahili':
        return 'tz';
      case 'swedish':
        return 'se';
      case 'tamil':
        return 'in';
      case 'telugu':
        return 'in';
      case 'thai':
        return 'th';
      case 'turkish':
        return 'tr';
      case 'ukrainian':
        return 'ua';
      case 'urdu':
        return 'pk';
      case 'uzbek':
        return 'uz';
      case 'vietnamese':
        return 'vn';
      case 'welsh':
        return 'gb';
      case 'yoruba':
        return 'ng';
      case 'zulu':
        return 'za';
      default:
        return 'un';
    }
  }
}
