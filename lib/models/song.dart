// enum Familiarity {
//   unknown,
//   notFamiliar,
//   slightlyFamiliar,
//   familiar,
//   veryFamiliar,
//   extremelyFamiliar
// }

class Verse {
  final String? number; // "1", "2", etc. или null для ненумерованных блоков
  final List<String> lines;

  Verse({this.number, required this.lines});

  /// Возвращает текст куплета как одну строку с переносами
  String get text => lines.join('\n');

  Map<String, dynamic> toMap() => {'number': number, 'lines': lines};

  factory Verse.fromMap(Map<String, dynamic> map) => Verse(
    number: map['number']?.toString(),
    lines: List<String>.from(map['lines'] ?? []),
  );
}

class Song {
  final int id;
  final String title;
  final String? number; // номер в сборнике (например, "118")
  final List<Verse> verses;
  final List<String>? startingChorus; // припев в начале (опционально)
  final List<String>? chorus; // основной припев (опционально)
  final List<String>? endingChorus; // финальный припев (опционально)
  final List<String> categories;
  final List<String> tags;
  final List<String> themes;

  Song({
    required this.id,
    required this.title,
    this.number,
    required this.verses,
    this.startingChorus,
    this.chorus,
    this.endingChorus,
    this.categories = const [],
    this.tags = const [],
    this.themes = const [],
  });

  /// Возвращает полный текст песни в человекочитаемом формате
  String get fullText {
    final parts = <String>[];

    if (startingChorus != null) {
      parts.add('(Припев в начале)\n${startingChorus!.join('\n')}\n');
    }

    for (final verse in verses) {
      if (verse.number != null) {
        parts.add('Куплет ${verse.number}\n${verse.text}');
      } else {
        parts.add(verse.text);
      }
      if (chorus != null) {
        parts.add('\n(Припев)\n${chorus!.join('\n')}');
      }
      parts.add(''); // пустая строка между куплетами
    }

    if (endingChorus != null) {
      parts.add('(Финальный припев)\n${endingChorus!.join('\n')}');
    }

    return parts.join('\n').trim();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'number': number,
      'verses': verses.map((v) => v.toMap()).toList(),
      'starting_chorus': startingChorus,
      'chorus': chorus,
      'ending_chorus': endingChorus,
      'categories': categories.join(','),
      'tags': tags.join(','),
      'themes': themes.join(','),
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    // Миграция старого формата (для обратной совместимости)
    if (map.containsKey('lyrics') && map['lyrics'] != null) {
      return _migrateFromOldFormat(map);
    }

    final versesJson = map['verses'] as List?;
    final verses =
        versesJson
            ?.map((v) => Verse.fromMap(v as Map<String, dynamic>))
            .toList() ??
        [];

    List<String>? parseStringList(dynamic value) {
      if (value is List<String>) return value;
      if (value is List<dynamic>) return value.cast<String>();
      return null;
    }

    return Song(
      id: map['id'] as int,
      title: map['title'] as String,
      number: map['number']?.toString(),
      verses: verses,
      startingChorus: parseStringList(map['starting_chorus']),
      chorus: parseStringList(map['chorus']),
      endingChorus: parseStringList(map['ending_chorus']),
      categories: _splitCsv(map['categories']),
      tags: _splitCsv(map['tags']),
      themes: _splitCsv(map['themes']),
    );
  }

  /// Миграция из старого формата (для существующих данных)
  static Song _migrateFromOldFormat(Map<String, dynamic> map) {
    final lyricsStr = map['lyrics'] as String?;
    final verses = <Verse>[];

    if (lyricsStr != null) {
      final blocks = lyricsStr.split('\n---\n');
      for (var i = 0; i < blocks.length; i++) {
        final lines = blocks[i]
            .split('\n')
            .where((l) => l.trim().isNotEmpty)
            .toList();
        verses.add(Verse(number: (i + 1).toString(), lines: lines));
      }
    }

    return Song(
      id: map['id'] as int,
      title: map['title'] as String,
      number: map['number']?.toString(),
      verses: verses,
      categories: _splitCsv(map['categories']),
      tags: _splitCsv(map['tags']),
      themes: _splitCsv(map['themes']),
    );
  }

  static List<String> _splitCsv(dynamic value) {
    if (value == null) return [];
    if (value is List<String>) return value;
    if (value is String) {
      return value
          .split(',')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList();
    }
    return [];
  }

  Song copyWith({
    int? id,
    String? title,
    String? number,
    List<Verse>? verses,
    List<String>? startingChorus,
    List<String>? chorus,
    List<String>? endingChorus,
    List<String>? categories,
    List<String>? tags,
    List<String>? themes,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      number: number ?? this.number,
      verses: verses ?? this.verses,
      startingChorus: startingChorus ?? this.startingChorus,
      chorus: chorus ?? this.chorus,
      endingChorus: endingChorus ?? this.endingChorus,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      themes: themes ?? this.themes,
    );
  }
}
