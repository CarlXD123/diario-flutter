import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Color _primaryColor = Colors.deepPurple;

  ThemeNotifier() {
    _loadPreferences();
  }

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    final colorValue = prefs.getInt('primaryColor') ?? Colors.deepPurple.value;

    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _primaryColor = Color(colorValue);

    notifyListeners();
  }

  void toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await prefs.setBool('isDarkMode', isDark);
    notifyListeners();
  }

  void setPrimaryColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    _primaryColor = color;
    await prefs.setInt('primaryColor', color.value);
    notifyListeners();
  }
}
