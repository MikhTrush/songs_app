import 'dart:io';

import 'package:flutter/material.dart';
import 'package:songs_app/l10n/app_localizations.dart';
import 'package:songs_app/services/settings_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/widgets.dart'; // для PlatformDispatcher
// import 'pages/user_form.dart';
import 'pages/home.dart';
// import 'l10n';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Для десктопа:
  if (isDesktop()) {
    databaseFactory = databaseFactoryFfi;
  }

  runApp(MyApp());
}

bool isDesktop() {
  return !(Platform.isAndroid || Platform.isIOS);
}

class MyApp2 extends StatefulWidget {
  const MyApp2({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp2> {
  late Future<String> _futureThemeMode;
  final SettingsService _settings = SettingsService();

  @override
  void initState() {
    super.initState();
    _futureThemeMode = _settings.getThemeMode();
  }

  // Brightness _getBrightness(String mode) {
  //   if (mode == 'dark') return Brightness.dark;
  //   if (mode == 'light') return Brightness.light;
  //   // system: определяем по текущей теме устройства
  //   return View.of(context).brightness;
  // }

  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      theme: ThemeData(
        // brightness: _getBrightness(await _futureThemeMode), // ← динамическая яркость
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      // theme: ThemeData(
      //   fontFamily: 'Poppins',
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: Colors.teal,
      //     brightness: Brightness.light,
      //   ),
      //   textTheme: TextTheme(
      //     titleLarge: TextStyle(
      //       color: Theme.of(context).primaryColorDark,
      //       fontSize: 18,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      // ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomePage(),
    );
  }
}

// Замени класс MyApp на StatelessWidget (упрощает управление состоянием)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Locale setLocale = Locale('en');
    return FutureBuilder<String>(
      future: SettingsService().getThemeMode(),
      builder: (context, snapshot) {
        final themeMode = snapshot.data ?? 'system';
        final brightness = _resolveBrightness(themeMode, context);

        return MaterialApp(
          locale: const Locale(
            'en',
          ), // временно фиксируем; позже вынесешь в состояние
          theme: ThemeData(
            brightness: brightness,
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal).copyWith(brightness: brightness),
            textTheme: const TextTheme(
              titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomePage(), // твой основной экран с BottomNav
        );
      },
    );
  }

  Brightness _resolveBrightness(String mode, BuildContext context) {
    if (mode == 'light') return Brightness.light;
    if (mode == 'dark') return Brightness.dark;

    // Для 'system': определяем через PlatformDispatcher
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return platformBrightness;
  }
}
