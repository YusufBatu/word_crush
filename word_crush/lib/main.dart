// ============================================================
// main.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_colors.dart';
import 'core/services/dictionary_service.dart';
import 'features/game/game_provider.dart';
import 'features/splash/username_screen.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Preload dictionary
  // Preload dictionary
  await DictionaryService.load();

  // Check if username exists
  final prefs = await SharedPreferences.getInstance();
  final username = prefs.getString('username');
  final initialScreen = (username == null || username.isEmpty)
      ? const UsernameScreen()
      : const HomeScreen();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: WordCrushApp(initialScreen: initialScreen),
    ),
  );
}

class WordCrushApp extends StatelessWidget {
  final Widget initialScreen;
  const WordCrushApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Crush',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryStart,
          surface: AppColors.surface,
          background: AppColors.background,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: initialScreen,
    );
  }
}
