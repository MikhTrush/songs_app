// settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart'; // ← ваш новый SettingsProvider

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Реактивно читаем все настройки
    final provider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Тема
          ListTile(
            title: const Text('Тема'),
            subtitle: Text(
              provider.themeMode == 'system'
                  ? 'Как в системе'
                  : provider.themeMode == 'light'
                      ? 'Светлая'
                      : 'Тёмная',
            ),
            trailing: DropdownButton<String>(
              value: provider.themeMode,
              items: const [
                DropdownMenuItem(value: 'system', child: Text('Как в системе')),
                DropdownMenuItem(value: 'light', child: Text('Светлая')),
                DropdownMenuItem(value: 'dark', child: Text('Тёмная')),
              ],
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsProvider>().setThemeMode(value);
                }
              },
            ),
          ),

          // Размер шрифта
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Размер шрифта', style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: provider.fontSize,
                min: 14,
                max: 28,
                divisions: 14,
                label: provider.fontSize.toInt().toString(),
                onChanged: (value) {
                  context.read<SettingsProvider>().setFontSize(value);
                },
              ),
            ],
          ),

          // Тип собрания
          ListTile(
            title: const Text('Тип собрания по умолчанию'),
            subtitle: Text(provider.defaultMeetingType),
            onTap: () => _showMeetingTypeDialog(context, provider),
          ),
        ],
      ),
    );
  }

  void _showMeetingTypeDialog(BuildContext context, SettingsProvider provider) {
    final controller = TextEditingController(text: provider.defaultMeetingType);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Тип собрания'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Например: Вечернее собрание'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final newType = controller.text.trim();
              if (newType.isNotEmpty) {
                context.read<SettingsProvider>().setDefaultMeetingType(newType);
              }
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}