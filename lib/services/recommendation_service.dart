import '../db/song_database.dart';
import '../models/song.dart';
class RecommendationService {
  static final RecommendationService _instance = RecommendationService._internal();
  final SongDatabase _db = SongDatabase.instance;

  factory RecommendationService() {
    return _instance;
  }

  RecommendationService._internal();

  /// Gets recommended songs based on themes or tags, prioritizing less frequently used songs
  Future<List<Song>> getRecommendationsByTheme(List<String> themes, {int limit = 10}) async {
    // First get all songs matching the themes
    final matchingSongs = await _db.getSongsByThemes(themes);
    
    // Get usage statistics for these songs
    final usageStats = await _getUsageStats(matchingSongs.map((song) => song.id).toList());
    
    // Sort by usage frequency (ascending - least used first) and then by title
    matchingSongs.sort((a, b) {
      final usageCountA = usageStats[a.id] ?? 0;
      final usageCountB = usageStats[b.id] ?? 0;
      
      // Primary sort: by usage count (ascending)
      int compare = usageCountA.compareTo(usageCountB);
      
      // Secondary sort: by title if usage counts are equal
      if (compare == 0) {
        compare = a.title.compareTo(b.title);
      }
      
      return compare;
    });
    
    // Return limited results
    return matchingSongs.take(limit).toList();
  }

  /// Gets recommended songs based on tags, prioritizing less frequently used songs
  Future<List<Song>> getRecommendationsByTags(List<String> tags, {int limit = 10}) async {
    // First get all songs matching the tags
    final matchingSongs = await _db.getSongsByTags(tags);
    
    // Get usage statistics for these songs
    final usageStats = await _getUsageStats(matchingSongs.map((song) => song.id).toList());
    
    // Sort by usage frequency (ascending - least used first) and then by title
    matchingSongs.sort((a, b) {
      final usageCountA = usageStats[a.id] ?? 0;
      final usageCountB = usageStats[b.id] ?? 0;
      
      // Primary sort: by usage count (ascending)
      int compare = usageCountA.compareTo(usageCountB);
      
      // Secondary sort: by title if usage counts are equal
      if (compare == 0) {
        compare = a.title.compareTo(b.title);
      }
      
      return compare;
    });
    
    // Return limited results
    return matchingSongs.take(limit).toList();
  }

  /// Gets recommended songs based on a combination of themes and tags
  Future<List<Song>> getRecommendationsByCriteria({
    List<String>? themes,
    List<String>? tags,
    int limit = 10,
  }) async {
    final allSongs = <Song>[];
    
    // Add songs matching themes if provided
    if (themes != null && themes.isNotEmpty) {
      allSongs.addAll(await _db.getSongsByThemes(themes));
    }
    
    // Add songs matching tags if provided
    if (tags != null && tags.isNotEmpty) {
      final tagSongs = await _db.getSongsByTags(tags);
      
      // Combine and deduplicate songs
      final songMap = <int, Song>{};
      for (final song in allSongs) {
        songMap[song.id] = song;
      }
      for (final song in tagSongs) {
        songMap[song.id] = song;
      }
      
      allSongs.clear();
      allSongs.addAll(songMap.values);
    }
    
    // Get usage statistics for these songs
    final usageStats = await _getUsageStats(allSongs.map((song) => song.id).toList());
    
    // Sort by usage frequency (ascending - least used first) and then by title
    allSongs.sort((a, b) {
      final usageCountA = usageStats[a.id] ?? 0;
      final usageCountB = usageStats[b.id] ?? 0;
      
      // Primary sort: by usage count (ascending)
      int compare = usageCountA.compareTo(usageCountB);
      
      // Secondary sort: by title if usage counts are equal
      if (compare == 0) {
        compare = a.title.compareTo(b.title);
      }
      
      return compare;
    });
    
    // Return limited results
    return allSongs.take(limit).toList();
  }

  /// Get usage statistics for a list of song IDs
  Future<Map<int, int>> _getUsageStats(List<int> songIds) async {
    if (songIds.isEmpty) return {};

    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT song_id, COUNT(*) as count
      FROM song_usage
      WHERE song_id IN (${songIds.map((_) => '?').join(',')})
      GROUP BY song_id
    ''', songIds);

    final result = <int, int>{};
    for (final map in maps) {
      result[map['song_id'] as int] = map['count'] as int;
    }

    return result;
  }
  
  /// Get songs that haven't been used at all (usage count = 0)
  Future<List<Song>> getUnusedSongs({int limit = 10}) async {
    final allSongs = await _db.getAllSongs();
    final allSongIds = allSongs.map((song) => song.id).toList();
    
    // Get songs that have usage records
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT song_id
      FROM song_usage
      WHERE song_id IN (${allSongIds.map((_) => '?').join(',')})
    ''', allSongIds);
    
    final usedSongIds = maps.map((map) => map['song_id'] as int).toSet();
    
    // Filter to only songs that have never been used
    final unusedSongs = allSongs.where((song) => !usedSongIds.contains(song.id)).toList();
    
    // Sort by title and return limited results
    unusedSongs.sort((a, b) => a.title.compareTo(b.title));
    return unusedSongs.take(limit).toList();
  }
}