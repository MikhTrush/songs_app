import 'package:flutter/material.dart';
import 'package:songs_app/db/song_database.dart';
import 'package:songs_app/l10n/app_localizations.dart';
import 'package:songs_app/models/collection.dart';
import 'package:songs_app/models/song.dart';
import 'package:songs_app/widgets/common_widgets.dart';

class CollectionDetailPage extends StatelessWidget {
  const CollectionDetailPage({super.key, required this.collection});

  final Collection collection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.collections)),
      body: Center(
        child: FutureBuilder(
          future: _getSongsForCollection(collection),
          builder: (context, snapshot) {
            final collection = snapshot.data ?? [];
            return ListView.builder(
              itemBuilder: (context, index) =>
                  SongTile(song: collection[index]),
            );
          },
        ),
      ),
    );
  }

  Future<List<Song>> _getSongsForCollection(Collection collection) async {
    if (collection.id == -1) {
      // NoCollection
      return await SongDatabase.instance.getSongsWithoutCollection();
    }

    if (collection.songIds.isEmpty) {
      return [];
    }

    final db = await SongDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      where: 'id IN (${collection.songIds.map((_) => '?').join(',')})',
      whereArgs: collection.songIds,
    );

    return maps.map((map) => Song.fromMap(map)).toList();
  }
}
