import 'dart:developer';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class APIs {
  static Future<String> geminiAPI(
      List<Map<String, dynamic>> conversationContext) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception(
            'GEMINI_API_KEY is not set in the environment variables.');
      }

      final model =
          GenerativeModel(model: 'gemini-1.5-pro-latest', apiKey: apiKey);

      // Convert conversation context to Content objects
      final List<Content> history =
          await Future.wait(conversationContext.map((message) async {
        if (message['image'] != null) {
          final File imageFile = File(message['image']);
          final bytes = await imageFile.readAsBytes();
          return Content.multi([
            TextPart(message['content'] ?? ''),
            DataPart('image/jpeg', bytes),
          ]);
        } else {
          return Content.text(message['content'] ?? '');
        }
      }));

      // Generate content with history
      final response = await model.generateContent(history);

      print('Response from Gemini AI: ${response.text}');
      return response.text ?? 'No response text';
    } catch (e, stackTrace) {
      print('Loaded API Key: ${dotenv.env['GEMINI_API_KEY']}');
      print('Full response from Gemini AI: $e');
      if (e is GenerativeAIException) {
        print('An internal error has occurred: ${e.message}');
        return 'An internal error has occurred: ${e.message}';
      }

      log('Error communicating with Gemini AI: $e',
          error: e, stackTrace: stackTrace);
      return 'Error communicating with Gemini AI: $e';
    }
  }
}
