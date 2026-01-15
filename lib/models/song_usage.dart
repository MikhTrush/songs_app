class SongUsage {
  final int id;
  final int songId;
  final DateTime usedAt;        // когда спели
  final String meetingType;     // тип собрания (например, "Воскресное")

  SongUsage({
    required this.id,
    required this.songId,
    required this.usedAt,
    required this.meetingType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'song_id': songId,
      'used_at': usedAt.toIso8601String(),
      'meeting_type': meetingType,
    };
  }

  factory SongUsage.fromMap(Map<String, dynamic> map) {
    return SongUsage(
      id: map['id'],
      songId: map['song_id'],
      usedAt: DateTime.parse(map['used_at']),
      meetingType: map['meeting_type'],
    );
  }

}