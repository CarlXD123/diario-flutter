import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  MaterialColor _customColor = Colors.deepPurple;
  MaterialColor get customColor => _customColor;

  ThemeData get currentTheme {
      return ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        primarySwatch: _customColor,
        scaffoldBackgroundColor: Colors.white,

        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: _customColor,
          foregroundColor: Colors.white,
        ),

        // 🟣 DRAWER (AQUÍ ESTÁ LA MAGIA)
        drawerTheme: DrawerThemeData(
          backgroundColor: _customColor,
        ),

        // Botones elevados
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _customColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),

        // TextButton (botones planos)
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _customColor,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        // OutlinedButton (con borde)
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _customColor,
            side: BorderSide(color: _customColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),

        // FloatingActionButton
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _customColor,
          foregroundColor: Colors.white,
        ),

        // Iconos
        iconTheme: IconThemeData(color: _customColor),

        // Progress indicators
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: _customColor,
        ),

        // Campos de texto (opcional)
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _customColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          labelStyle: TextStyle(color: _customColor),
        ),
      );
    }



  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveToPrefs();
    notifyListeners();
  }

  void setColor(MaterialColor color) {
    _customColor = color;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = (prefs.getBool('isDark') ?? false) ? ThemeMode.dark : ThemeMode.light;

    final index = prefs.getInt('customColorIndex') ?? 5; // Default to deepPurple
    if (index >= 0 && index < Colors.primaries.length) {
      _customColor = Colors.primaries[index];
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _themeMode == ThemeMode.dark);
    await prefs.setInt('customColorIndex', Colors.primaries.indexOf(_customColor));
  }

  Future<void> loadPrefs() async {
    await _loadFromPrefs();
  }
}
