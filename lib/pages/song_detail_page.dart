import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // для форматирования даты
import 'package:songs_app/models/song_usage.dart';
import '../db/song_database.dart';
import '../models/song.dart';
import '../l10n/app_localizations.dart';

class SongDetailPage extends StatefulWidget {
  final Song song;

  const SongDetailPage({super.key, required this.song});

  @override
  State<SongDetailPage> createState() => _SongDetailPageState();
}

class _SongDetailPageState extends State<SongDetailPage> {
  late String _defaultMeetingType;

  @override
  void initState() {
    super.initState();
    // TODO: загрузить из настроек (сейчас хардкод)
    _defaultMeetingType = 'Воскресное собрание';
  }

  Future<void> _recordUsage() async {
    final usage = SongUsage(
      id: 0,
      songId: widget.song.id,
      usedAt: DateTime.now(),
      meetingType: _defaultMeetingType,
    );
    await SongDatabase.instance.recordUsage(usage);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.song_added_to_stats),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          _recordUsage();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
