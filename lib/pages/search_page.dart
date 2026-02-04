import 'package:flutter/material.dart';
import 'package:songs_app/l10n/app_localizations.dart';
import 'package:songs_app/models/category.dart';
import 'package:songs_app/widgets/search_field.dart';
import 'package:songs_app/pages/song_detail_page.dart';
import 'package:songs_app/widgets/song_search_item.dart';
import 'package:songs_app/widgets/tag_chip.dart';
import '../db/song_database.dart';
import '../models/song.dart';
// Import the collections page

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  _SearchPageState();

  List<CategoryModel> categories = [];
  List<Song> _searchResults = [];
  bool _isLoading = false;

  final controller = TextEditingController();

  String text = '';

  @override
  void initState() {
    controller.addListener(_onTextChange);
    super.initState();
  }

  void _onSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Implement logic to exlude already shown songs
    final numberResults = RegExp(r'^\d+$').hasMatch(query)
        ? await SongDatabase.instance.searchNumber(query)
        : <Song>[]; // или пустой список нужного типа

    final titleResults = await SongDatabase.instance.searchOnlyTitle(
      query.toLowerCase(),
    );

    final textResults = await SongDatabase.instance.searchOnlyText(
      query.toLowerCase(),
    );

    setState(() {
      _searchResults = [...numberResults, ...titleResults, ...textResults];
      _isLoading = false;
      _currentQuery = query.toLowerCase(); // Store the current search query
    });
  }

  // Add this new variable to store the current search term
  String _currentQuery = '';

  // Helper function to find the first verse or chorus containing the search term
  String _findVerseWithMatch(Song song, String searchTerm) {
    if (searchTerm.isEmpty) {
      return song.verses.isNotEmpty ? song.verses[0].text : '';
    }

    final lowerSearchTerm = searchTerm.toLowerCase();

    // Check starting chorus first
    if (song.startingChorus != null) {
      for (String line in song.startingChorus!) {
        if (line.toLowerCase().contains(lowerSearchTerm)) {
          return _trimVerseToLines(line, 3);
        }
      }
    }

    // Then check verses
    for (Verse verse in song.verses) {
      if (verse.text.toLowerCase().contains(lowerSearchTerm)) {
        return _trimVerseToLines(verse.text, 3);
      }
    }

    // Then check main chorus
    if (song.chorus != null) {
      for (String line in song.chorus!) {
        if (line.toLowerCase().contains(lowerSearchTerm)) {
          return _trimVerseToLines(line, 3);
        }
      }
    }

    // Finally check ending chorus
    if (song.endingChorus != null) {
      for (String line in song.endingChorus!) {
        if (line.toLowerCase().contains(lowerSearchTerm)) {
          return _trimVerseToLines(line, 3);
        }
      }
    }

    // Fallback to first verse if no match found
    return song.verses.isNotEmpty
        ? _trimVerseToLines(song.verses[0].text, 3)
        : '';
  }

  // Helper function to trim a verse to a specific number of lines
  String _trimVerseToLines(String verse, int maxLines) {
    if (maxLines <= 0) return '';

    // Split the verse into lines
    List<String> lines = verse.split('\n');

    // If we have fewer lines than the max, return as is
    if (lines.length <= maxLines) {
      return verse;
    }

    // Calculate which lines to show based on the middle of the content
    int startIndex = (lines.length - maxLines) ~/ 2;
    int endIndex = startIndex + maxLines;

    // Create the trimmed result with ellipses if needed
    List<String> selectedLines = lines.sublist(startIndex, endIndex);
    String result = selectedLines.join('\n');

    // Add ellipses at the beginning if we skipped lines at the start
    if (startIndex > 0) {
      result = '...\n$result';
    }

    // Add ellipses at the end if we skipped lines at the end
    if (endIndex < lines.length) {
      result = '$result\n...';
    }

    return result;
  }

  Widget _searchSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          SearchField(context: context, controller: controller),
          if (_isLoading) LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final song = _searchResults[index];

                // Get the verse to display based on whether title contains match
                final verseToDisplay = _findVerseWithMatch(song, _currentQuery);

                return SongSearchItem(
                  song: song,
                  verseToDisplay: verseToDisplay,
                  context: context,
                  currentQuery: _currentQuery,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SongDetailPage(song: song),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  AppBar _appbar(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.songs_app_title),
      elevation: 0,
      centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _appbar(context), body: _searchSection(context));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onTextChange() {
    _onSearch(controller.text.toLowerCase());
  }
}
