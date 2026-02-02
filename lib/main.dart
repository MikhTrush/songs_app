// main.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songs_app/l10n/app_localizations.dart';
import 'package:songs_app/pages/main_navigation.dart';
import 'package:songs_app/providers/settings_provider.dart'; // ← ваш новый провайдер
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// оставляем для совместимости

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (isDesktop()) {
    databaseFactory = databaseFactoryFfi;
  }

  // Создаём и загружаем провайдер ДО runApp
  final settingsProvider = SettingsProvider();
  await settingsProvider.load();

  runApp(
    ChangeNotifierProvider<SettingsProvider>.value(
      value: settingsProvider,
      child: const MyApp(),
    ),
  );
}

bool isDesktop() {
  return !(Platform.isAndroid || Platform.isIOS);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, child) {
        final themeMode = provider.themeMode;
        final locale = provider.locale;
        final baseFontSize = provider.fontSize; // например, 16

        // Определяем размеры на основе базового fontsize
        final double bodySize = baseFontSize;
        final double titleLargeSize = baseFontSize + 2; // чуть крупнее
        final double displayLargeSize =
            baseFontSize + 6; // или baseFontSize * 4.5 — как удобнее

        return MaterialApp(
          locale: locale,
          theme: buildTheme(displayLargeSize, titleLargeSize, bodySize),
          darkTheme: ThemeData(
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: Brightness.dark,
            ),
            textTheme: TextTheme(
              displayLarge: TextStyle(
                fontSize: displayLargeSize,
                fontWeight: FontWeight.bold,
              ),
              titleLarge: TextStyle(
                fontSize: titleLargeSize,
                fontWeight: FontWeight.bold,
              ),
              bodyMedium: TextStyle(
                fontSize: bodySize,
                fontFamily: 'Merryweather',
              ),
            ),
          ),
          themeMode: _resolveThemeMode(themeMode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainNavigation(),
        );
      },
    );
  }

  ThemeData buildTheme(double displayLargeSize, double titleLargeSize, double bodySize) {
    return ThemeData(
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          textTheme: TextTheme(
            displayLarge: TextStyle(
              fontSize: displayLargeSize,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: TextStyle(
              fontSize: titleLargeSize,
              fontWeight: FontWeight.bold,
            ),
            bodyMedium: TextStyle(
              fontSize: bodySize,
              fontFamily: 'Merryweather',
            ),
          ),
        );
  }

  ThemeMode _resolveThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
