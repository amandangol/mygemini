import 'dart:developer';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:get/get.dart';
import 'package:mygemini/controllers/ApiVersionController.dart';

class APIs {
  static Future<String> geminiAPI(
      List<Map<String, dynamic>> conversationContext) async {
    final apiVersionController = Get.find<ApiVersionController>();
    final modelName = apiVersionController.currentApiVersion;

    log('Starting Gemini API request using $modelName', name: 'APIs');

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception(
            'GEMINI_API_KEY is not set in the environment variables.');
      }

      final model = GenerativeModel(model: modelName, apiKey: apiKey);

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

      log('Sending request to Gemini AI ($modelName)', name: 'APIs');
      // Generate content with history
      final response = await model.generateContent(history);

      print(
        'Response received from Gemini AI ($modelName): $response',
      );

      log('Response received from Gemini AI ($modelName)', name: 'APIs');
      return response.text ?? 'No response text';
    } catch (e, stackTrace) {
      log('Error communicating with Gemini AI ($modelName): $e',
          error: e, stackTrace: stackTrace, name: 'APIs');
      return 'Error communicating with Gemini AI: $e';
    }
  }
}
