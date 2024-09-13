import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygemini/utils/helper/pref.dart';

class ThemeController extends GetxController {
  //using rxbool to observe change
  var isDarkMode = Pref.isDarkMode.obs;

  ThemeMode get theme => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Pref.isDarkMode = isDarkMode.value; // Save to Hive when toggled
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  void onInit() {
    super.onInit();
    // Apply the saved theme when the app starts
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
