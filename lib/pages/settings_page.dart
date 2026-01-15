import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Future<String> _futureThemeMode;
  late Future<double> _futureFontSize;
  late Future<String> _futureMeetingType;

  final SettingsService _settings = SettingsService();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    _futureThemeMode = _settings.getThemeMode();
    _futureFontSize = _settings.getFontSize();
    _futureMeetingType = _settings.getDefaultMeetingType();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Тема
          FutureBuilder<String>(
            future: _futureThemeMode,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final mode = snapshot.data!;
              return ListTile(
                title: const Text('Тема'),
                subtitle: Text(mode == 'system' ? 'Как в системе' : mode == 'light' ? 'Светлая' : 'Тёмная'),
                trailing: DropdownButton<String>(
                  value: mode,
                  items: const [
                    DropdownMenuItem(value: 'system', child: Text('Как в системе')),
                    DropdownMenuItem(value: 'light', child: Text('Светлая')),
                    DropdownMenuItem(value: 'dark', child: Text('Тёмная')),
                  ],
                  onChanged: (value) async {
                    if (value != null) {
                      await _settings.setThemeMode(value);
                      setState(() => _futureThemeMode = _settings.getThemeMode());
                      // TODO: обновить тему всего приложения
                    }
                  },
                ),
              );
            },
          ),

          // Размер шрифта
          FutureBuilder<double>(
            future: _futureFontSize,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final size = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Размер шрифта', style: TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: size,
                    min: 14,
                    max: 28,
                    divisions: 14,
                    label: size.toInt().toString(),
                    onChanged: (value) async {
                      await _settings.setFontSize(value);
                      setState(() => _futureFontSize = _settings.getFontSize());
                    },
                  ),
                ],
              );
            },
          ),

          // Тип собрания
          FutureBuilder<String>(
            future: _futureMeetingType,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              return ListTile(
                title: const Text('Тип собрания по умолчанию'),
                subtitle: Text(snapshot.data!),
                onTap: () => _showMeetingTypeDialog(context),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showMeetingTypeDialog(BuildContext context) async {
    final current = await _settings.getDefaultMeetingType();
    final controller = TextEditingController(text: current);

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
            onPressed: () async {
              await _settings.setDefaultMeetingType(controller.text);
              Navigator.pop(context);
              setState(() => _futureMeetingType = _settings.getDefaultMeetingType());
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}