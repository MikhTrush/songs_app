import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:songs_app/models/song_usage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/song.dart';
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
    // await deleteDatabase(path);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Схема с полной поддержкой новых полей
    await db.execute('''
    CREATE TABLE songs(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      number TEXT,
      is_system INTEGER NOT NULL DEFAULT 0,
      verses TEXT NOT NULL,
      starting_chorus TEXT,
      chorus TEXT,
      ending_chorus TEXT,
      categories TEXT,
      tags TEXT,
      themes TEXT
    )
  ''');

    await db.execute('CREATE INDEX idx_songs_number ON songs(number)');
    await db.execute('CREATE INDEX idx_songs_is_system ON songs(is_system)');
    await db.execute('CREATE INDEX idx_songs_title ON songs(title)');

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
    final data = song.toMap()..remove('id'); // id генерируется БД
    final id = await db.insert('songs', data);
    return song.copyWith(id: id);
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

  Future<List<Song>> searchTextAndTitle(String query) async {
    if (query.isEmpty) return [];

    final db = await instance.database;
    final maps = await db.query(
      'songs',
      where: 'title LIKE ? OR verses LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return maps.map((e) => Song.fromMap(e)).toList();
  }

  Future<List<Song>> searchOnlyTitle(String query) async {
    if (query.isEmpty) return [];

    final db = await instance.database;
    final maps = await db.query(
      'songs',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
    );

    return maps.map((e) => Song.fromMap(e)).toList();
  }

  Future<List<Song>> searchOnlyText(String query) async {
    if (query.isEmpty) return [];

    final db = await instance.database;
    final maps = await db.query(
      'songs',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
    );

    return maps.map((e) => Song.fromMap(e)).toList();
  }

  // В классе SongDatabase
  Future<void> insertSystemSongs() async {
    final db = await instance.database;

    // Проверяем, есть ли уже системные песни
    final hasSystemSongs = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM songs WHERE is_system = 1'),
    );

    if (hasSystemSongs != null && hasSystemSongs > 0) {
      print('✅ Системные песни уже загружены ($hasSystemSongs шт.)');
      return;
    }

    print('📥 Загрузка системных песен из сборника "Песнь Возрождения"...');

    // Загружаем JSON из ассетов
    final jsonString = await rootBundle.loadString(
      'assets/data/songs_sr_processed.json',
    );
    final songsJson = json.decode(jsonString) as List<dynamic>;

    final startTime = DateTime.now();

    // Используем ТРАНЗАКЦИЮ для максимальной производительности
    await db.transaction((txn) async {
      for (var i = 0; i < songsJson.length; i++) {
        final songJson = songsJson[i] as Map<String, dynamic>;

        // Преобразуем в объект Song
        final song = _songFromJson(songJson, isSystem: true);

        // Вставляем напрямую в транзакцию (без создания объекта через create())
        await txn.insert('songs', song.toMap()..remove('id'));

        if ((i + 1) % 100 == 0) {
          print('  Загружено ${i + 1}/${songsJson.length} песен');
        }
      }
    });

    final duration = DateTime.now().difference(startTime);
    print(
      '✅ Успешно загружено ${songsJson.length} системных песен за ${duration.inSeconds} сек.',
    );
  }

  /// Вспомогательный метод: создаёт объект Song из JSON
  Song _songFromJson(Map<String, dynamic> json, {required bool isSystem}) {
    return Song(
      id: 0, // будет заменён БД
      title: json['title'] as String,
      number: json['number']?.toString(),
      isSystem: isSystem,
      verses: (json['verses'] as List<dynamic>).map((v) {
        final verseJson = v as Map<String, dynamic>;
        return Verse(
          number: verseJson['number']?.toString(),
          lines: List<String>.from(verseJson['lines'] ?? []),
        );
      }).toList(),
      startingChorus: _parseStringList(json['starting_chorus']),
      chorus: _parseStringList(json['chorus']),
      endingChorus: _parseStringList(json['ending_chorus']),
      categories: ['SR'], // помечаем как сборник "Песнь Возрождения"
      tags: [],
      themes: [],
    );
  }

  List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List<String>) return value;
    if (value is List<dynamic>) return value.cast<String>();
    return null;
  }

  // Защита от удаления системных песен
  Future<void> deleteSong(int songId) async {
    final db = await instance.database;

    // Проверяем, является ли песня системной
    final songMap = await db.query(
      'songs',
      where: 'id = ?',
      whereArgs: [songId],
      columns: ['is_system', 'number'],
      limit: 1,
    );

    if (songMap.isNotEmpty && (songMap[0]['is_system'] as int) == 1) {
      throw Exception(
        '❌ Нельзя удалить системную песню №${songMap[0]['number']} из сборника "Песнь Возрождения"',
      );
    }

    // Удаляем из коллекций
    await db.delete(
      'collection_songs',
      where: 'song_id = ?',
      whereArgs: [songId],
    );

    // Удаляем саму песню
    await db.delete('songs', where: 'id = ?', whereArgs: [songId]);
  }

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

    // Add associated songs to the collection_songs table
    for (final songId in collection.songIds) {
      await db.insert('collection_songs', {
        'collection_id': id,
        'song_id': songId,
      });
    }

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

  // Get songs that are not in any collection
  Future<List<Song>> getSongsWithoutCollection() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT s.* FROM songs s
      LEFT JOIN collection_songs cs ON s.id = cs.song_id
      WHERE cs.song_id IS NULL
    ''');
    return maps.map((map) => Song.fromMap(map)).toList();
  }

  // Update an existing song
  Future<void> updateSong(Song song) async {
    final db = await instance.database;
    await db.update(
      'songs',
      song.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [song.id],
    );
  }

  // Remove a song from a specific collection but keep the song
  Future<void> removeSongFromCollectionOnly(
    int songId,
    int collectionId,
  ) async {
    final db = await instance.database;

    await db.delete(
      'collection_songs',
      where: 'collection_id = ? AND song_id = ?',
      whereArgs: [collectionId, songId],
    );
  }

  // Get recently used songs with their usage details
  Future<List<Map<String, dynamic>>> getRecentlyUsedSongs({
    int limit = 10,
  }) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT s.*, u.used_at, u.meeting_type
      FROM song_usage u
      JOIN songs s ON u.song_id = s.id
      ORDER BY u.used_at DESC
      LIMIT ?
    ''',
      [limit],
    );

    return maps;
  }

  Future<dynamic> searchNumber(String query) async {
    if (query.isEmpty) return [];

    final db = await instance.database;
    final maps = await db.query(
      'songs',
      where: 'number LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return maps.map((e) => Song.fromMap(e)).toList();
  }

  Future<void> insertInitialData() async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM songs'),
    );
    if (count == 0) {
      // 1. Слушайте слово сие (Ам. 3:1)
      await create(
        Song(
          id: 0,
          title: 'Слушайте слово сие',
          number: '205',
          verses: [
            Verse(
              lines: [
                'Слушайте повесть любви в простоте,',
                'Слушайте дивный рассказ:',
                'Бог нас навеки простил во Христе,',
                'Бог нас от гибели спас.',
              ],
            ),
            Verse(
              lines: [
                'Если неправда потерянных дней',
                'Мучит вас в тягостный час,',
                'Верьте всем сердцем и верою всей:',
                'Бог нас от гибели спас.',
              ],
            ),
            Verse(
              lines: [
                'Если под мраком житейских скорбей',
                'Пламень надежды погас,',
                'Вспомните только хоть мыслью своей:',
                'Бог нас от гибели спас.',
              ],
            ),
            Verse(
              lines: [
                'Если при виде соблазнов земных',
                'Слабый смущается глаз,',
                '– Слово да слышится в чувствах простых:',
                'Бог нас от гибели спас.',
              ],
            ),
          ],
          chorus: [
            'Бог нас от гибели спас!',
            'Бог нас от гибели спас!',
            'Да, Бог нас навеки простил во Христе,',
            'Бог нас от гибели спас!',
          ],
          categories: ['гимн'],
          tags: ['спасение', 'прощение', 'надежда', 'вера', 'любовь Божья'],
          themes: ['евангелие', 'утешение', 'покаяние'],
        ),
      );

      // 2. Дом Мой назовется домом молитвы (Ис. 56:7)
      await create(
        Song(
          id: 0,
          title: 'Дом Мой назовется домом молитвы',
          number: '72',
          verses: [
            Verse(
              lines: [
                'Вот, настал молитвы час;',
                'С верой мы принесем',
                'Грех и страх, что мучат нас,',
                'Сложим их пред Христом.',
                'Нам дано давно познать:',
                'Хочет Он нас принять',
                'И Свое благословенье',
                'В полноте всем нам дать.',
              ],
            ),
            Verse(
              lines: [
                'Вот, настал молитвы час;',
                'Молим: «Вечный наш Бог!',
                'Духом Ты повей на нас;',
                'У Твоих все мы ног.',
                'Песню нам в уста вдохни,',
                'Души воспламени!',
                'И рукой любви и мира',
                'В нас сердца осени!»',
              ],
            ),
            Verse(
              lines: [
                'Вот, настал молитвы час;',
                'Тих и скромен наш дом,',
                'И душа к душе меж нас',
                'Льнет в общенье святом.',
                '«Мир разлей по всем сердцам,',
                'Мир пошли с неба нам!',
                'И теперь подобье неба,',
                'Боже, сделай в них Сам!»',
              ],
            ),
          ],
          chorus: [
            'Чудный час мольбы!',
            'Дивный час мольбы!',
            'Час священного общенья!',
            'Здесь так сладостно быть.',
          ],
          categories: ['гимн', 'молитва'],
          tags: ['молитва', 'община', 'благословение', 'духовное общение'],
          themes: ['церковь', 'богослужение', 'единство'],
        ),
      );

      // 3. Я услышу вас (Иер. 29:12)
      await create(
        Song(
          id: 0,
          title: 'Я услышу вас',
          number: '443',
          verses: [
            Verse(
              lines: [
                'Боже, слышать слово Ты позволил снова,',
                'К нам склони святой Свой лик,',
                'Чтобы свет Твой в нас проник!',
              ],
            ),
            Verse(
              lines: [
                'И пребудь с дарами Мира ныне с нами,',
                'Дай нам Духа благодать,',
                'Дай Тебя душой принять.',
              ],
            ),
            Verse(
              lines: [
                'Восхвалите снова Вы Христа живого!',
                'Он – спасения венец,',
                'Он – наш Пастырь и Отец!',
              ],
            ),
          ],
          categories: ['гимн', 'молитва'],
          tags: ['ответ Бога', 'Дух Святой', 'прославление', 'пастырство'],
          themes: ['Божий ответ', 'присутствие Бога', 'тринитаризм'],
        ),
      );

      // 4. Укажи мне, Господи, путь (Пс. 118:33)
      await create(
        Song(
          id: 0,
          title: 'Укажи мне, Господи, путь',
          number: '422',
          verses: [
            Verse(
              lines: [
                'Господь! душа внимать готова,',
                'Лишь слух и очи мне открой',
                'Услышать правду Божья слова,',
                'Увидеть свет небесный Твой.',
                'Дай в душу слова разуменье',
                'И в нем земных скорбей забвенье.',
              ],
            ),
            Verse(
              lines: [
                'Здесь все мы чада заблужденья,',
                'Здесь все греха объяты тьмой,',
                'Пока нас светом откровенья',
                'Не просветит Твой Дух Святой;',
                'Благие мысли и желанья,',
                'Добро – Твое, Господь, даянье.',
              ],
            ),
            Verse(
              lines: [
                'Ты – Свет от Света, Бог Предвечный,',
                'Единородный Бога Сын,',
                'Внять слову с верою сердечной',
                'Ты можешь силу дать Один.',
                'Господь! прими мое моленье',
                'И дай Себя мне в утешенье.',
              ],
            ),
          ],
          categories: ['гимн', 'псалом'],
          tags: [
            'откровение',
            'разумение',
            'Святое Писание',
            'утешение',
            'Дух Святой',
          ],
          themes: ['молитва о руководстве', 'познание Бога', 'Слово Божье'],
        ),
      );

      // 5. Дай мне уразуметь путь повелений Твоих (Пс. 118:27)
      await create(
        Song(
          id: 0,
          title: 'Дай мне уразуметь путь повелений Твоих',
          number: '424',
          verses: [
            Verse(
              lines: [
                'О Спаситель! благодать',
                'На благую весть излей;',
                'Дай нам все слова понять,',
                'Все слова любви Твоей.',
              ],
            ),
            Verse(
              lines: [
                'Ты открой всем нам сердца',
                'И Твои слова посей,',
                'Пусть на них падет роса',
                'Милости, любви Твоей!',
              ],
            ),
            Verse(
              lines: [
                'Да удобрит Божий Дух',
                'Наше сердце и наш слух;',
                'Да скорей произрастет',
                'В нашей жизни вечный плод!',
              ],
            ),
          ],
          chorus: [
            'Дай общение сердцам,',
            'Всех в одно соедини,',
            'Обрати лицо Ты к нам',
            'И беседу в нас начни!',
          ],
          categories: ['гимн', 'псалом'],
          tags: [
            'общение',
            'единство',
            'благодать',
            'плод Духа',
            'Слово Божье',
          ],
          themes: ['духовный рост', 'церковное единство', 'благодать'],
        ),
      );
    }
  }
}
