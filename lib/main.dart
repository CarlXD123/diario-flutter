import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🚀 ARRANCA LA UI INMEDIATAMENTE
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );

  // 🔒 Inicializaciones SEGURAS (no bloquean la UI)
  _safeInit();
}

Future<void> _safeInit() async {
  try {
    await NotificationService.initialize();
  } catch (e, s) {
    debugPrint('❌ Error NotificationService: $e');
    debugPrintStack(stackTrace: s);
  }

  try {
    await DatabaseService.initDB();
  } catch (e, s) {
    debugPrint('❌ Error DatabaseService: $e');
    debugPrintStack(stackTrace: s);
  }

  try {
    await MobileAds.instance.initialize();
  } catch (e, s) {
    debugPrint('❌ Error MobileAds: $e');
    debugPrintStack(stackTrace: s);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      home: HomeScreen(),
    );
  }
}
