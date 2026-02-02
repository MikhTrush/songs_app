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
                // Display the starting chorus if it exists
                if (widget.song.startingChorus != null &&
                    widget.song.startingChorus!.isNotEmpty)
                  _buildChorusSection(
                    widget.song.startingChorus!,
                    AppLocalizations.of(context)!.starting_chorus,
                  ),

                // Display verses with chorus after each (if chorus exists)
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final sections = <Widget>[];

                      // 1. Первый припев (если есть) — всегда в начале
                      if (widget.song.startingChorus != null) {
                        sections.add(
                          _buildChorusSection(
                            widget.song.startingChorus!,
                            AppLocalizations.of(context)!.starting_chorus,
                          ),
                        );
                      }

                      // 2. Куплеты + второй припев ТОЛЬКО после первого куплета
                      for (int i = 0; i < widget.song.verses.length; i++) {
                        final verse = widget.song.verses[i];
                        final verseNumber = verse.number ?? (i + 1);

                        sections.add(
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${AppLocalizations.of(context)!.verse} $verseNumber',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  verse.text,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );

                        // Второй припев — строго один раз после первого куплета
                        if (i == 0 && widget.song.chorus != null) {
                          sections.add(
                            _buildChorusSection(
                              widget.song.chorus!,
                              AppLocalizations.of(context)!.chorus,
                            ),
                          );
                        }
                      }

                      // 3. Последний припев (если есть) — всегда в конце
                      if (widget.song.endingChorus != null) {
                        sections.add(
                          _buildChorusSection(
                            widget.song.endingChorus!,
                            AppLocalizations.of(
                              context,
                            )!.ending_chorus, // убедитесь, что строка существует в локализации
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: sections.length,
                        itemBuilder: (context, index) => sections[index],
                      );
                    },
                  ),
                ),

                // Display the ending chorus if it exists
                if (widget.song.endingChorus != null &&
                    widget.song.endingChorus!.isNotEmpty)
                  _buildChorusSection(
                    widget.song.endingChorus!,
                    AppLocalizations.of(context)!.ending_chorus,
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

  Widget _buildChorusSection(List<String> lines, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '($label)',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            lines.join('\n'),
            style: const TextStyle(
              fontSize: 18,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRecordUsageDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) async {
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
                        labelText: AppLocalizations.of(
                          context,
                        )!.meeting_type_label,
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
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.song_added_to_stats,
                          ),
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
