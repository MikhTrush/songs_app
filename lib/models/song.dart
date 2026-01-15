class Song {
  final int id;
  final String title;
  final List<String> verses;      // вместо lyrics
  final List<String> categories;

  Song({
    required this.id,
    required this.title,
    required this.verses,
    required this.categories,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'verses': verses.join('\n---\n'), // разделитель между куплетами
      'categories': categories.join(','),
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    final versesStr = map['verses'] as String?;
    final verses = <String>[];
    if (versesStr != null) {
      // Разделяем по нашему разделителю
      verses.addAll(versesStr.split('\n---\n'));
    }

    final catsStr = map['categories'] as String?;
    final categories = catsStr?.split(',') ?? [];

    return Song(
      id: map['id'],
      title: map['title'],
      verses: verses,
      categories: categories,
    );
  }
}