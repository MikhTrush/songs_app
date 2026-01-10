import 'dart:io';

import 'package:flutter/material.dart';
import 'package:songs_app/l10n/app_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomePage(setLocale: setLocale,),
    );
  }
}
