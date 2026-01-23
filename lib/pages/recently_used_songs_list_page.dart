import 'package:flutter/material.dart';
import '../db/song_database.dart';
import '../models/song.dart';
import 'song_detail_page.dart';
import '../l10n/app_localizations.dart';

class RecentlyUsedSongsListPage extends StatelessWidget {
  const RecentlyUsedSongsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.recently_used_songs),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: SongDatabase.instance.getRecentlyUsedSongs(limit: 50), // Increased limit for the full page
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final recentlyUsedSongs = snapshot.data ?? [];

          if (recentlyUsedSongs.isEmpty) {
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
            itemCount: recentlyUsedSongs.length,
            itemBuilder: (context, index) {
              final song = recentlyUsedSongs[index];
              final usedAt = DateTime.parse(song['used_at']);
              final formattedDate = '${usedAt.day}.${usedAt.month}.${usedAt.year}';
              
              return ListTile(
                title: Text(song['title']),
                subtitle: Text('${AppLocalizations.of(context)!.songs_spoken(formattedDate)} (${song['meeting_type']})'),
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