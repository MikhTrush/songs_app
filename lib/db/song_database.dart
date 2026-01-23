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

  Future<List<Song>> searchOnlyText(String query) async {
    if (query.isEmpty) return [];

    final db = await instance.database;
    final maps = await db.query(
      'songs',
      where: 'title LIKE ? OR verses LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
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
    // 1. Слушайте слово сие (Ам. 3:1)
    await create(
      Song(
        id: 0,
        title: 'Слушайте слово сие',
        verses: [
          'Слушайте повесть любви в простоте,\nСлушайте дивный рассказ:\nБог нас навеки простил во Христе,\nБог нас от гибели спас.',
          'Если неправда потерянных дней\nМучит вас в тягостный час,\nВерьте всем сердцем и верою всей:\nБог нас от гибели спас.',
          'Если под мраком житейских скорбей\nПламень надежды погас,\nВспомните только хоть мыслью своей:\nБог нас от гибели спас.',
          'Если при виде соблазнов земных\nСлабый смущается глаз,\n– Слово да слышится в чувствах простых:\nБог нас от гибели спас.',
        ],
        // chorus: 'Бог нас от гибели спас!\nБог нас от гибели спас!\nДа, Бог нас навеки простил во Христе,\nБог нас от гибели спас!',
        categories: ['гимн'],
        tags: ['спасение', 'прощение', 'надежда', 'вера', 'любовь Божья'],
        themes: ['евангелие', 'утешение', 'покаяние'],
        // metadata: {
        //   'перевод': 'И. Проханов',
        //   'музыка': 'E. Gebhardt',
        //   'библейская ссылка': 'Ам. 3:1',
        //   'источники': ['Гусли 205', 'Гимны христиан 131', 'С.Д.П. 247'],
        //   'тоника': 'ля-мажор',
        // },
      ),
    );

    // 2. Дом Мой назовется домом молитвы (Ис. 56:7)
    await create(
      Song(
        id: 0,
        title: 'Дом Мой назовется домом молитвы',
        verses: [
          'Вот, настал молитвы час;\nС верой мы принесем\nГрех и страх, что мучат нас,\nСложим их пред Христом.\nНам дано давно познать:\nХочет Он нас принять\nИ Свое благословенье\nВ полноте всем нам дать.',
          'Вот, настал молитвы час;\nМолим: «Вечный наш Бог!\nДухом Ты повей на нас;\nУ Твоих все мы ног.\nПесню нам в уста вдохни,\nДуши воспламени!\nИ рукой любви и мира\nВ нас сердца осени!»',
          'Вот, настал молитвы час;\nТих и скромен наш дом,\nИ душа к душе меж нас\nЛьнет в общенье святом.\n«Мир разлей по всем сердцам,\nМир пошли с неба нам!\nИ теперь подобье неба,\nБоже, сделай в них Сам!»',
        ],
        // chorus: 'Чудный час мольбы!\nДивный час мольбы!\nЧас священного общенья!\nЗдесь так сладостно быть.',
        categories: ['гимн', 'молитва'],
        tags: ['молитва', 'община', 'благословение', 'духовное общение'],
        themes: ['церковь', 'богослужение', 'единство'],
        // metadata: {
        //   'перевод': 'И. Проханов',
        //   'музыка': 'И. Тэнней',
        //   'библейская ссылка': 'Ис. 56:7',
        //   'источники': ['Песни христианина 44', 'Гимны христиан 72', 'С.Д.П. 260'],
        //   'тоника': 'до-мажор',
        // },
      ),
    );

    // 3. Я услышу вас (Иер. 29:12)
    await create(
      Song(
        id: 0,
        title: 'Я услышу вас',
        verses: [
          'Боже, слышать слово Ты позволил снова,\nК нам склони святой Свой лик,\nЧтобы свет Твой в нас проник!',
          'И пребудь с дарами Мира ныне с нами,\nДай нам Духа благодать,\nДай Тебя душой принять.',
          'Восхвалите снова Вы Христа живого!\nОн – спасения венец,\nОн – наш Пастырь и Отец!',
        ],
        categories: ['гимн', 'молитва'],
        tags: ['ответ Бога', 'Дух Святой', 'прославление', 'пастырство'],
        themes: ['Божий ответ', 'присутствие Бога', 'тринитаризм'],
        // metadata: {
        //   'библейская ссылка': 'Иер. 29:12',
        //   'источники': ['Гусли 443', 'С.Д.П. 257'],
        //   'тоника': 'ре-мажор',
        // },
      ),
    );

    // 4. Укажи мне, Господи, путь (Пс. 118:33)
    await create(
      Song(
        id: 0,
        title: 'Укажи мне, Господи, путь',
        verses: [
          'Господь! душа внимать готова,\nЛишь слух и очи мне открой\nУслышать правду Божья слова,\nУвидеть свет небесный Твой.\nДай в душу слова разуменье\nИ в нем земных скорбей забвенье.',
          'Здесь все мы чада заблужденья,\nЗдесь все греха объяты тьмой,\nПока нас светом откровенья\nНе просветит Твой Дух Святой;\nБлагие мысли и желанья,\nДобро – Твое, Господь, даянье.',
          'Ты – Свет от Света, Бог Предвечный,\nЕдинородный Бога Сын,\nВнять слову с верою сердечной\nТы можешь силу дать Один.\nГосподь! прими мое моленье\nИ дай Себя мне в утешенье.',
        ],
        categories: ['гимн', 'псалом'],
        tags: ['откровение', 'разумение', 'Святое Писание', 'утешение', 'Дух Святой'],
        themes: ['молитва о руководстве', 'познание Бога', 'Слово Божье'],
        // metadata: {
        //   'библейская ссылка': 'Пс. 118:33',
        //   'источники': ['Гусли 422', 'Гимны христиан 2', 'С.Д.П. 252'],
        //   'тоника': 'до-мажор',
        // },
      ),
    );

    // 5. Дай мне уразуметь путь повелений Твоих (Пс. 118:27)
    await create(
      Song(
        id: 0,
        title: 'Дай мне уразуметь путь повелений Твоих',
        verses: [
          'О Спаситель! благодать\nНа благую весть излей;\nДай нам все слова понять,\nВсе слова любви Твоей.',
          'Ты открой всем нам сердца\nИ Твои слова посей,\nПусть на них падет роса\nМилости, любви Твоей!',
          'Да удобрит Божий Дух\nНаше сердце и наш слух;\nДа скорей произрастет\nВ нашей жизни вечный плод!',
        ],
        // chorus: 'Дай общение сердцам,\nВсех в одно соедини,\nОбрати лицо Ты к нам\nИ беседу в нас начни!',
        categories: ['гимн', 'псалом'],
        tags: ['общение', 'единство', 'благодать', 'плод Духа', 'Слово Божье'],
        themes: ['духовный рост', 'церковное единство', 'благодать'],
        // metadata: {
        //   'музыка': 'S. Marsh',
        //   'библейская ссылка': 'Пс. 118:27',
        //   'источники': ['Гусли 424', 'Гимны христиан 54', 'С.Д.П. 253'],
        //   'тоника': 'фа-мажор',
        // },
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
}
