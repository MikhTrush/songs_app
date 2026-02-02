import 'dart:convert';

import 'package:songs_app/models/song.dart';

class SongConverter {
  static Song fromParsedJson(Map<String, dynamic> parsedJson, int id) {
    final verses = (parsedJson['verses'] as List?)
        ?.map((v) => Verse(
              number: v['number']?.toString(),
              lines: List<String>.from(v['lines'] ?? []),
            ))
        .toList() ?? [];

    List<String>? parseChorus(key) {
      final value = parsedJson[key];
      if (value is List) return List<String>.from(value);
      return null;
    }

    return Song(
      id: id,
      title: parsedJson['title'] as String,
      number: parsedJson['number']?.toString(),
      verses: verses,
      startingChorus: parseChorus('starting_chorus'),
      chorus: parseChorus('chorus'),
      endingChorus: parseChorus('ending_chorus'),
      // categories/tags/themes можно заполнить позже через редактирование
    );
  }

  /// Конвертирует весь файл songs_sr_processed.json
  static List<Song> convertAll(String jsonContent) {
    final data = json.decode(jsonContent) as List<dynamic>;
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final songJson = entry.value as Map<String, dynamic>;
      return fromParsedJson(songJson, index + 1); // id начинается с 1
    }).toList();
  }
}