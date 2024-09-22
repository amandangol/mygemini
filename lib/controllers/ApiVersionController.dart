import 'package:get/get.dart';
import 'dart:developer' as developer;

import 'package:mygemini/utils/helper/pref.dart';

class ApiVersionController extends GetxController {
  final RxBool isUsingProVersion = Pref.isUsingProVersion.obs;

  void toggleApiVersion() {
    isUsingProVersion.value = !isUsingProVersion.value;
    Pref.toggleApiVersion = isUsingProVersion.value;

    developer.log('API version switched to: $currentApiVersion',
        name: 'ApiVersionController');
  }

  String get currentApiVersion =>
      isUsingProVersion.value ? "gemini-1.5-pro-latest" : "gemini-1.5-flash";
}
