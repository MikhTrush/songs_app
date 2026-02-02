class Collection {
  final int id;
  final String name;
  final String description;
  final List<int> songIds;
  final bool isSystem;

  Collection({
    required this.id,
    required this.name,
    this.description = '',
    this.songIds = const [],
    this.isSystem = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'song_ids': songIds.join(','),
      'is_system': isSystem ? 1 : 0,
    };
  }

  factory Collection.fromMap(Map<String, dynamic> map) {
    final songIdsStr = map['song_ids'] as String?;
    final songIds =
        songIdsStr
            ?.split(',')
            .where((s) => s.isNotEmpty)
            .map((s) => int.parse(s))
            .toList() ??
        [];

    return Collection(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      songIds: songIds,
      isSystem: map['is_system'] ?? false,
    );
  }
}
