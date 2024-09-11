import 'dart:developer';

import 'package:ai_assistant/utils/helper/api_key.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class APIs {
  static Future<String> geminiAPI(String msg) async {
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final content = Content.text(msg);
      final response = await model.generateContent([content]);

      log('response from gemini ai: ${response.text}');
      return '${response.text}';
    } catch (e) {
      log('error comunicating with gemini: $e');
      return 'Error comunicating with Gemini AI';
    }
  }
}
