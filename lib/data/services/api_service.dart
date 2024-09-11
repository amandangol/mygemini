import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class APIs {
  static Future<String> geminiAPI(String msg) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception(
            'GEMINI_API_KEY is not set in the environment variables.');
      }

      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final content = Content.text(msg);
      final response = await model.generateContent([content]);

      print('Response from Gemini AI: ${response.text}');
      return response.text ?? 'No response text';
    } catch (e, stackTrace) {
      print('Loaded API Key: ${dotenv.env['GEMINI_API_KEY']}');
      print('Full response from Gemini AI: $e');

      log('Error communicating with Gemini AI: $e',
          error: e, stackTrace: stackTrace);
      return 'Error communicating with Gemini AI';
    }
  }
}
