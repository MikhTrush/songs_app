import 'package:songs_app/models/song_usage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/song.dart';

// Add import for collection
import '../models/collection.dart';

class SongDatabase {
  static final SongDatabase instance = SongDatabase._init();
  static Database? _database;

  SongDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('songs.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Удаляем старую БД при любом изменении (только для dev!)
    await deleteDatabase(path); // ← ДОБАВЬ ЭТО

    return await openDatabase(
      path,
      version: 1, // ← ВСЕГДА 1
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE songs(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      verses TEXT NOT NULL,
      categories TEXT,
      tags TEXT,
      themes TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE collections(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE collection_songs(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      collection_id INTEGER NOT NULL,
      song_id INTEGER NOT NULL,
      FOREIGN KEY (collection_id) REFERENCES collections(id) ON DELETE CASCADE,
      FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE,
      UNIQUE(collection_id, song_id)
    )
  ''');

    // 🔥 ДОБАВЬ ЭТО:
    await db.execute('''
    CREATE TABLE song_usage(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      song_id INTEGER NOT NULL,
      used_at TEXT NOT NULL,
      meeting_type TEXT NOT NULL,
      FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE
    )
  ''');
  }

  Future<Song> create(Song song) async {
    final db = await instance.database;

    // Убираем id из данных для вставки
    final data = song.toMap();
    data.remove('id'); // ← КЛЮЧЕВОЕ ИЗМЕНЕНИЕ

    final id = await db.insert('songs', data);
    return Song(
      id: id, // ← используем сгенерированный id
      title: song.title,
      verses: song.verses,
      categories: song.categories,
      tags: song.tags,
      themes: song.themes,
    );
  }

  Future<List<Song>> search(String query) async {
    if (query.isEmpty) return [];

    final db = await instance.database;
    final maps = await db.query(
      'songs',
      where: 'title LIKE ? OR verses LIKE ? OR tags LIKE ? OR themes LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
    );

    return maps.map((e) => Song.fromMap(e)).toList();
  }

  // Для заполнения при первом запуске
  Future<void> insertInitialData() async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM songs'),
    );
    if (count == 0) {
      // Примеры песен — замени на реальные данные позже
      await create(
        Song(
          id: 0,
          title: 'Amazing Grace',
          verses: [
            'Amazing grace, how sweet the sound\nThat saved a wretch like me!',
            'I once was lost, but now am found,\nWas blind, but now I see.',
          ],
          categories: ['hymn'],
          tags: ['grace', 'redemption', 'faith'],
          themes: ['christian', 'hope'],
        ),
      );

      await create(
        Song(
          id: 0,
          title: 'How Great Thou Art',
          verses: [
            'O Lord my God, when I in awesome wonder\nConsider all the worlds Thy hands have made...',
            'Then sings my soul, my Savior God, to Thee:\nHow great Thou art, how great Thou art!',
          ],
          categories: ['hymn', 'praise'],
          tags: ['worship', 'creation', 'praise'],
          themes: ['christian', 'adoration'],
        ),
      );
    }
  }
  // В классе SongDatabase

  Future<SongUsage> recordUsage(SongUsage usage) async {
    final db = await instance.database;
    final data = usage.toMap()..remove('id'); // id генерируется автоматически
    final id = await db.insert('song_usage', data);
    return SongUsage(
      id: id,
      songId: usage.songId,
      usedAt: usage.usedAt,
      meetingType: usage.meetingType,
    );
  }

  Future<List<Map<String, dynamic>>> getUsageWithSongs() async {
    final db = await instance.database;
    return await db.rawQuery('''
    SELECT s.title, u.used_at, u.meeting_type
    FROM song_usage u
    JOIN songs s ON u.song_id = s.id
    ORDER BY u.used_at DESC
  ''');
  }

  // Collections methods
  Future<Collection> createCollection(Collection collection) async {
    final db = await instance.database;

    final data = {
      'name': collection.name,
      'description': collection.description,
    };

    final id = await db.insert('collections', data);
    return Collection(
      id: id,
      name: collection.name,
      description: collection.description,
      songIds: collection.songIds,
    );
  }

  Future<Collection?> getCollectionById(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'collections',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final collection = Collection.fromMap(maps.first);

      // Get associated song IDs
      final songMaps = await db.query(
        'collection_songs',
        where: 'collection_id = ?',
        whereArgs: [id],
        columns: ['song_id'],
      );

      final songIds = songMaps.map((map) => map['song_id'] as int).toList();

      return Collection(
        id: collection.id,
        name: collection.name,
        description: collection.description,
        songIds: songIds,
      );
    }

    return null;
  }

  Future<List<Collection>> getAllCollections() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('collections');

    final collections = <Collection>[];

    for (final map in maps) {
      final collection = Collection.fromMap(map);

      // Get associated song IDs
      final songMaps = await db.query(
        'collection_songs',
        where: 'collection_id = ?',
        whereArgs: [collection.id],
        columns: ['song_id'],
      );

      final songIds = songMaps.map((map) => map['song_id'] as int).toList();

      collections.add(
        Collection(
          id: collection.id,
          name: collection.name,
          description: collection.description,
          songIds: songIds,
        ),
      );
    }

    return collections;
  }

  Future<void> addToCollection(int collectionId, int songId) async {
    final db = await instance.database;

    await db.insert(
      'collection_songs',
      {'collection_id': collectionId, 'song_id': songId},
      conflictAlgorithm: ConflictAlgorithm.ignore, // Prevent duplicates
    );
  }

  Future<void> removeFromCollection(int collectionId, int songId) async {
    final db = await instance.database;

    await db.delete(
      'collection_songs',
      where: 'collection_id = ? AND song_id = ?',
      whereArgs: [collectionId, songId],
    );
  }

  Future<void> updateCollection(Collection collection) async {
    final db = await instance.database;

    // Update collection info
    await db.update(
      'collections',
      collection.toMap()..remove('song_ids'),
      where: 'id = ?',
      whereArgs: [collection.id],
    );

    // Clear existing links
    await db.delete(
      'collection_songs',
      where: 'collection_id = ?',
      whereArgs: [collection.id],
    );

    // Add new links
    for (final songId in collection.songIds) {
      await db.insert('collection_songs', {
        'collection_id': collection.id,
        'song_id': songId,
      });
    }
  }

  Future<void> deleteCollection(int id) async {
    final db = await instance.database;

    await db.delete('collections', where: 'id = ?', whereArgs: [id]);
  }

  // Filter songs by tags or themes
  Future<List<Song>> getSongsByTags(List<String> tags) async {
    if (tags.isEmpty) return [];

    final db = await instance.database;
    String whereClause = '';
    final whereArgs = <String>[];

    for (int i = 0; i < tags.length; i++) {
      if (i > 0) whereClause += ' OR ';
      whereClause += 'tags LIKE ?';
      whereArgs.add('%${tags[i]}%');
    }

    final maps = await db.query(
      'songs',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return maps.map((e) => Song.fromMap(e)).toList();
  }

  Future<List<Song>> getSongsByThemes(List<String> themes) async {
    if (themes.isEmpty) return [];

    final db = await instance.database;
    String whereClause = '';
    final whereArgs = <String>[];

    for (int i = 0; i < themes.length; i++) {
      if (i > 0) whereClause += ' OR ';
      whereClause += 'themes LIKE ?';
      whereArgs.add('%${themes[i]}%');
    }

    final maps = await db.query(
      'songs',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return maps.map((e) => Song.fromMap(e)).toList();
  }

  // Get all songs
  Future<List<Song>> getAllSongs() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('songs');
    return maps.map((map) => Song.fromMap(map)).toList();
  }
}
