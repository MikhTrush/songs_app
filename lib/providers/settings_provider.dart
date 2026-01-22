// settings_provider.dart
import 'package:flutter/material.dart';
import '../services/settings_service.dart'; 

class SettingsProvider extends ChangeNotifier {
  final SettingsService _service = SettingsService();

  // Кэшируемые значения
  late String _themeMode;
  late double _fontSize;
  late String _defaultMeetingType;
  late Locale _locale;

  // Геттеры для UI
  String get themeMode => _themeMode;
  double get fontSize => _fontSize;
  String get defaultMeetingType => _defaultMeetingType;
  Locale get locale => _locale;

  // Загрузка всех настроек один раз при старте
  Future<void> load() async {
    _themeMode = await _service.getThemeMode();
    _fontSize = await _service.getFontSize();
    _defaultMeetingType = await _service.getDefaultMeetingType();
    _locale = await _service.getLocale();
    notifyListeners();
  }

  // Методы изменения с автоматическим сохранением и обновлением UI
  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    await _service.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    await _service.setFontSize(size);
    notifyListeners();
  }

  Future<void> setDefaultMeetingType(String type) async {
    _defaultMeetingType = type;
    await _service.setDefaultMeetingType(type);
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    _locale = Locale.fromSubtags(languageCode: languageCode);
    await _service.setDefaultLocale(languageCode);
    notifyListeners();
  }
}