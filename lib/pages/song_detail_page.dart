import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // для форматирования даты
import 'package:provider/provider.dart';
import 'package:songs_app/models/song_usage.dart';
import '../db/song_database.dart';
import '../models/song.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';

class SongDetailPage extends StatefulWidget {
  final Song song;

  const SongDetailPage({super.key, required this.song});

  @override
  State<SongDetailPage> createState() => _SongDetailPageState();
}

class _SongDetailPageState extends State<SongDetailPage> {
  late String _defaultMeetingType;
  late List<String> _meetingTypes;

  @override
  void initState() {
    super.initState();
    // Initialize with default values
    _defaultMeetingType = 'Воскресное собрание';
    _meetingTypes = ['Воскресное собрание', 'Вечернее собрание'];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        // Update values when settings change
        _defaultMeetingType = settingsProvider.defaultMeetingType;
        _meetingTypes = settingsProvider.meetingTypes;
        
        return Scaffold(
          appBar: AppBar(title: Text(widget.song.title)),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Отображение куплетов
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.song.verses.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          widget.song.verses[index],
                          style: const TextStyle(fontSize: 18, height: 1.5),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showRecordUsageDialog(context, settingsProvider);
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _showRecordUsageDialog(BuildContext context, SettingsProvider settingsProvider) async {
    DateTime selectedDate = DateTime.now();
    String meetingType = settingsProvider.defaultMeetingType;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.record_song_usage),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.date_label,
                      ),
                      readOnly: true,
                      controller: TextEditingController()
                        ..text = DateFormat('dd.MM.yyyy').format(selectedDate),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: meetingType,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.meeting_type_label,
                      ),
                      items: settingsProvider.meetingTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            meetingType = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () async {
                    final usage = SongUsage(
                      id: 0,
                      songId: widget.song.id,
                      usedAt: selectedDate,
                      meetingType: meetingType,
                    );
                    await SongDatabase.instance.recordUsage(usage);
                    
                    if (mounted) {
                      Navigator.of(context).pop(); // Close dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.song_added_to_stats),
                        ),
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.record),
                ),
              ],
            );
          },
        );
      },
    );
  }
}