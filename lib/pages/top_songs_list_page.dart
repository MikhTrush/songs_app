import 'package:flutter/material.dart';
import '../db/song_database.dart';
import 'song_detail_page.dart';
import '../l10n/app_localizations.dart';

class TopSongsListPage extends StatelessWidget {
  const TopSongsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.top_songs_by_usage),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: SongDatabase.instance.getUsageWithSongs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final usageData = snapshot.data ?? [];

          // Count usages per song
          Map<String, int> songUsageCounts = {};
          for (var record in usageData) {
            String title = record['title'].toString();
            songUsageCounts[title] = (songUsageCounts[title] ?? 0) + 1;
          }

          // Sort by usage count descending
          var sortedEntries = songUsageCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          // Get all songs
          var allSongs = sortedEntries.map((entry) {
            return {
              'title': entry.key,
              'count': entry.value,
            };
          }).toList();

          if (allSongs.isEmpty) {
            return Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  AppLocalizations.of(
                    context,
                  )!.no_collections_yet,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: allSongs.length,
            itemBuilder: (context, index) {
              final song = allSongs[index];
              return ListTile(
                title: Text(song['title'] as String),
                subtitle: Text(
                  AppLocalizations.of(
                    context,
                  )!.times_used(song['count'].toString()),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  // Find the actual song object by title
                  final allSongs = await SongDatabase.instance.getAllSongs();
                  final songObj = allSongs.firstWhere(
                    (s) => s.title == song['title'],
                    orElse: () => allSongs.first,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongDetailPage(song: songObj),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}