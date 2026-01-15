import 'package:songs_app/models/song_usage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/song.dart';

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

    // return await openDatabase(path, version: 1, onCreate: _createDB);
    // В _initDB:
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE songs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        verses TEXT NOT NULL,
        categories TEXT
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
    );
  }

  Future<List<Song>> search(String query) async {
    if (query.isEmpty) return [];

    final db = await instance.database;
    final maps = await db.query(
      'songs',
      where: 'title LIKE ? OR verses LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return maps.map((e) => Song.fromMap(e)).toList();
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
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
}
