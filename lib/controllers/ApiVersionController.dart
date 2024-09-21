import 'package:get/get.dart';
import 'dart:developer' as developer;

class ApiVersionController extends GetxController {
  final RxBool isUsingProVersion = true.obs;

  void toggleApiVersion() {
    isUsingProVersion.toggle();
    developer.log('API version switched to: $currentApiVersion',
        name: 'ApiVersionController');
  }

  String get currentApiVersion =>
      isUsingProVersion.value ? "gemini-1.5-pro-latest" : "gemini-1.5-flash";
}
