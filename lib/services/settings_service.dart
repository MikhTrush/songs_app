import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyThemeMode = 'theme_mode';
  static const _keyFontSize = 'font_size';
  static const _keyDefaultMeetingType = 'default_meeting_type';
  static const _keyDefaultLocale = 'default_locale';
  static const _keyMeetingTypes = 'meeting_types';

  // Тема: 'light' | 'dark' | 'system'
  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode) ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }

  // Размер шрифта (в sp)
  Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyFontSize) ?? 18.0;
  }

  Future<void> setFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, size);
  }

  // Тип собрания по умолчанию
  Future<String> getDefaultMeetingType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDefaultMeetingType) ?? 'Воскресное собрание';
  }

  Future<void> setDefaultMeetingType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDefaultMeetingType, type);
  }

  // Список типов собраний
  Future<List<String>> getMeetingTypes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? types = prefs.getStringList(_keyMeetingTypes);
    
    if (types == null || types.isEmpty) {
      // Return default meeting types if none are stored
      return ['Воскресное собрание', 'Вечернее собрание'];
    }
    
    return types;
  }

  Future<void> setMeetingTypes(List<String> types) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyMeetingTypes, types);
  }

  Future<void> addMeetingType(String type) async {
    List<String> types = await getMeetingTypes();
    if (!types.contains(type)) {
      types.add(type);
      await setMeetingTypes(types);
    }
  }

  Future<void> removeMeetingType(String type) async {
    List<String> types = await getMeetingTypes();
    types.remove(type);
    await setMeetingTypes(types);
  }

  Future<void> setDefaultLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDefaultLocale, locale);
  }

  Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? localeString = prefs.getString(_keyDefaultLocale);
    if (localeString != null && localeString.isNotEmpty) {
      return Locale.fromSubtags(languageCode: localeString);
    } else {
      return const Locale(
        'ru',
      ); // Возвращаем русскую локаль по умолчанию, если не установлена
    }
  }
}