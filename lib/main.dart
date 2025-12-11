// main.dart
import 'package:diario/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'services/database_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await MobileAds.instance.initialize();

    final themeProvider = ThemeProvider();
    await themeProvider.loadPrefs();

    await DatabaseService.initDB(); // <- puede estar fallando

    runApp(
      ChangeNotifierProvider.value(
        value: themeProvider,
        child: const MyApp(),
      ),
    );
  } catch (e, stack) {
    print("❌ Error al iniciar la app: $e");
    print("Stacktrace: $stack");
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      home: HomeScreen(),
    );
  }
}
