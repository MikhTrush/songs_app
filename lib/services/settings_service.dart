import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyThemeMode = 'theme_mode';
  static const _keyFontSize = 'font_size';
  static const _keyDefaultMeetingType = 'default_meeting_type';

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
}