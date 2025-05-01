import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider with ChangeNotifier {
  final _box = Hive.box('settingsBox');

  bool get isDarkMode => _box.get('isDarkMode', defaultValue: false);

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    final current = isDarkMode;
    _box.put('isDarkMode', !current);
    notifyListeners();
  }
}

