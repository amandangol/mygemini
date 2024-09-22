import 'dart:developer';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
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

      log('Response received from Gemini AI ($modelName)', name: 'APIs');
      return response.text ?? 'No response text';
    } on SocketException catch (e) {
      log('Network error: $e', error: e, name: 'APIs');
      return 'Network error: Please check your internet connection and try again.';
    } on ClientException catch (e) {
      if (e.message.contains('Failed host lookup')) {
        log('DNS lookup failed: $e', error: e, name: 'APIs');
        return 'Network error: Unable to connect to the server. Please check your internet connection and try again.';
      }
      log('Client error: $e', error: e, name: 'APIs');
      return 'An error occurred while communicating with the server. Please try again later.';
    } catch (e, stackTrace) {
      if (e.toString().contains('Resource has been exhausted')) {
        log('Quota exhausted: $e',
            error: e, stackTrace: stackTrace, name: 'APIs');
        return 'Quota exceeded: You have used up your allowed requests for this period. Please try again later or switch to gemini-1.5-flash model.';
      }
      log('Error communicating with Gemini AI ($modelName): $e',
          error: e, stackTrace: stackTrace, name: 'APIs');
      print('Error communicating with Gemini AI ($modelName): $e');
      return 'An unexpected error occurred. Please try again later.';
    }
  }
}
