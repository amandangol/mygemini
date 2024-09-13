import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class Pref {
  static late Box _box;

  static Future<void> initialize() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocDir.path);

    // Open the box
    _box = await Hive.openBox('myData');
  }

  // Onboarding preference
  static bool get showOnboarding =>
      _box.get('showOnboarding', defaultValue: true);
  static set showOnboarding(bool v) => _box.put('showOnboarding', v);

  // Dark mode preference
  static bool get isDarkMode => _box.get('isDarkMode', defaultValue: false);
  static set isDarkMode(bool v) => _box.put('isDarkMode', v);
}
