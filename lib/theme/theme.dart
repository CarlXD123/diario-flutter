import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.deepPurple,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
  ),
  colorScheme: const ColorScheme.light(
    primary: Colors.deepPurple,
    secondary: Colors.amber,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.all(Colors.deepPurple),
    trackColor: MaterialStateProperty.all(Colors.deepPurple.shade100),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.teal,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
  ),
  colorScheme: const ColorScheme.dark(
    primary: Colors.teal,
    secondary: Colors.orange,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.all(Colors.tealAccent),
    trackColor: MaterialStateProperty.all(Colors.teal),
  ),
);
