import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class APIs {
  static Future<String> geminiAPI(
      List<Map<String, String>> conversationContext) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception(
            'GEMINI_API_KEY is not set in the environment variables.');
      }

      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

      // Convert conversation context to Content objects
      final List<Content> history = conversationContext.map((message) {
        return Content.text(message['content'] ?? '');
      }).toList();

      // Generate content with history
      final response = await model.generateContent(history);

      print('Response from Gemini AI: ${response.text}');
      return response.text ?? 'No response text';
    } catch (e, stackTrace) {
      print('Loaded API Key: ${dotenv.env['GEMINI_API_KEY']}');
      print('Full response from Gemini AI: $e');
      if (e is GenerativeAIException) {
        print('Content was blocked for safety reasons.');
        return 'Content was blocked for safety reasons';
      }

      log('Error communicating with Gemini AI: $e',
          error: e, stackTrace: stackTrace);
      return 'Error communicating with Gemini AI';
    }
  }
}
