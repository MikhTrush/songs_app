// settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songs_app/pages/app_info_page.dart';
import '../providers/settings_provider.dart'; // ← ваш новый SettingsProvider
import '../l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Реактивно читаем все настройки
    final provider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings_title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Тема
          buildThemeTile(context, provider),

          buildLocaleTile(context, provider),

          // Размер шрифта
          buildFontSizeTile(context, provider),

          // Тип собрания по умолчанию
          ListTile(
            title: Text(AppLocalizations.of(context)!.meeting_type_option),
            subtitle: Text(provider.defaultMeetingType),
            onTap: () => _showDefaultMeetingTypeDialog(context, provider),
          ),

          // Управление списком типов собраний
          ListTile(
            title: Text(AppLocalizations.of(context)!.manage_meeting_types),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...provider.meetingTypes.map(
                  (type) => Container(
                    margin: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text(type)),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18.0),
                          onPressed: () => provider.removeMeetingType(type),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddMeetingTypeDialog(context, provider),
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.app_info),
            trailing: IconButton(
              icon: const Icon(Icons.info),
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppInfoPage()),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }

  Column buildFontSizeTile(BuildContext context, SettingsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.font_size_option,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
    );
  }

  ListTile buildLocaleTile(BuildContext context, SettingsProvider provider) {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.language_option),
      trailing: DropdownButton<String>(
        value: provider.locale.languageCode,
        items: [
          ...AppLocalizations.supportedLocales.map(
            (locale) => DropdownMenuItem(
              value: locale.languageCode,
              child: Text(locale.languageCode),
            ),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            context.read<SettingsProvider>().setLocale(value);
          }
        },
      ),
    );
  }

  ListTile buildThemeTile(BuildContext context, SettingsProvider provider) {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.theme_option),
      trailing: DropdownButton<String>(
        value: provider.themeMode,
        items: [
          DropdownMenuItem(
            value: 'system',
            child: Text(AppLocalizations.of(context)!.system_theme),
          ),
          DropdownMenuItem(
            value: 'light',
            child: Text(AppLocalizations.of(context)!.light_theme),
          ),
          DropdownMenuItem(
            value: 'dark',
            child: Text(AppLocalizations.of(context)!.dark_theme),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            context.read<SettingsProvider>().setThemeMode(value);
          }
        },
      ),
    );
  }

  void _showDefaultMeetingTypeDialog(
    BuildContext context,
    SettingsProvider provider,
  ) {
    final controller = TextEditingController(text: provider.defaultMeetingType);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.default_meeting_type),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.enter_meeting_type_hint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final newType = controller.text.trim();
              if (newType.isNotEmpty) {
                context.read<SettingsProvider>().setDefaultMeetingType(newType);
              }
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _showAddMeetingTypeDialog(
    BuildContext context,
    SettingsProvider provider,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.add_meeting_type),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.enter_meeting_type_hint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final newType = controller.text.trim();
              if (newType.isNotEmpty &&
                  !provider.meetingTypes.contains(newType)) {
                context.read<SettingsProvider>().addMeetingType(newType);
              }
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );
  }
}
