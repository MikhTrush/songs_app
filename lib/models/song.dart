class Song {
  final int id;
  final String title;
  final List<String> verses;      // instead of lyrics
  final List<String> categories;  // for general categories
  final List<String> tags;        // for specific tags
  final List<String> themes;      // for thematic tags

  Song({
    required this.id,
    required this.title,
    required this.verses,
    this.categories = const [],
    this.tags = const [],
    this.themes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'verses': verses.join('\n---\n'), // delimiter between verses
      'categories': categories.join(','),
      'tags': tags.join(','),
      'themes': themes.join(','),
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    final versesStr = map['verses'] as String?;
    final verses = <String>[];
    if (versesStr != null) {
      // Split by our delimiter
      verses.addAll(versesStr.split('\n---\n'));
    }

    final catsStr = map['categories'] as String?;
    final categories = catsStr?.split(',').where((s) => s.isNotEmpty).toList() ?? [];

    final tagsStr = map['tags'] as String?;
    final tags = tagsStr?.split(',').where((s) => s.isNotEmpty).toList() ?? [];

    final themesStr = map['themes'] as String?;
    final themes = themesStr?.split(',').where((s) => s.isNotEmpty).toList() ?? [];

    return Song(
      id: map['id'],
      title: map['title'],
      verses: verses,
      categories: categories,
      tags: tags,
      themes: themes,
    );
  }
}