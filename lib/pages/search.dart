import 'dart:math';

import 'package:flutter/material.dart';
import 'package:songs_app/l10n/app_localizations.dart';
import 'package:songs_app/models/category.dart';
import 'package:songs_app/pages/song_detail_page.dart';
import '../db/song_database.dart';
import '../models/song.dart';
import 'collections_page.dart'; // Import the collections page

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    //  required this.setLocale
  });

  // final Function setLocale;

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

  void _getCategories() {
    categories = CategoryModel.getCategories();
  }

  @override
  void initState() {
    controller.addListener(_onTextChange);
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    await SongDatabase.instance.insertInitialData();
  }

  void _onSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() => _isLoading = true);
    final results = await SongDatabase.instance.searchOnlyText(query);
    setState(() {
      _searchResults = results;
      _isLoading = false;
      _currentQuery = query.toLowerCase(); // Store the current search query
    });
  }

  // Add this new variable to store the current search term
  String _currentQuery = '';

  // Add this helper method to highlight matches
  Widget _buildHighlightedText(
    String fullText,
    String searchTerm, {
    bool isTitle = false,
  }) {
    if (searchTerm.isEmpty) {
      return Text(
        fullText,
        style: isTitle ? Theme.of(context).textTheme.titleLarge : null,
      );
    }

    final lowerFullText = fullText.toLowerCase();
    final lowerSearchTerm = searchTerm.toLowerCase();

    // Use case-insensitive search to find all matches
    final matches = <(int start, int end)>[]; // Store match positions
    int searchStart = 0;

    while (searchStart <= lowerFullText.length - lowerSearchTerm.length) {
      final matchIndex = lowerFullText.indexOf(lowerSearchTerm, searchStart);
      if (matchIndex == -1) break;

      matches.add((matchIndex, matchIndex + lowerSearchTerm.length));
      searchStart = matchIndex + 1; // Move by 1 to catch overlapping matches
    }

    if (matches.isEmpty) {
      return Text(
        fullText,
        style: isTitle ? Theme.of(context).textTheme.titleLarge : null,
      );
    }

    // Build text spans based on match positions
    final List<TextSpan> spans = [];
    int currentPosition = 0;

    for (final (start, end) in matches) {
      // Add text before match
      if (currentPosition < start) {
        spans.add(TextSpan(text: fullText.substring(currentPosition, start)));
      }

      // Add highlighted match
      spans.add(
        TextSpan(
          text: fullText.substring(start, end),
          style: TextStyle(
            backgroundColor: Colors.yellow.withOpacity(0.7),
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      currentPosition = end;
    }

    // Add remaining text after last match
    if (currentPosition < fullText.length) {
      spans.add(TextSpan(text: fullText.substring(currentPosition)));
    }

    return RichText(
      text: TextSpan(
        style: isTitle
            ? Theme.of(context).textTheme.titleLarge
            : DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }

  // Helper function to find the first verse containing the search term
  String _findVerseWithMatch(Song song, String searchTerm) {
    if (searchTerm.isEmpty) return song.verses.isNotEmpty ? song.verses[0] : '';

    final lowerSearchTerm = searchTerm.toLowerCase();

    for (String verse in song.verses) {
      if (verse.toLowerCase().contains(lowerSearchTerm)) {
        return _trimVerseToLines(verse, 3);
      }
    }

    // Fallback to first verse if no match found
    return song.verses.isNotEmpty ? _trimVerseToLines(song.verses[0], 3) : '';
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
          TextField(
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.search_songs,
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          if (_isLoading) LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final song = _searchResults[index];

                // Check if the title contains the search term
                final titleContainsMatch =
                    _currentQuery.isEmpty ||
                    song.title.toLowerCase().contains(
                      _currentQuery.toLowerCase(),
                    );

                // Get the verse to display based on whether title contains match
                final verseToDisplay = _findVerseWithMatch(song, _currentQuery);

                return ListTile(
                  title: _buildHighlightedText(
                    song.title,
                    _currentQuery,
                    isTitle: true,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHighlightedText(verseToDisplay, _currentQuery),
                      if (song.categories.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2, bottom: 2),
                          child: Wrap(
                            spacing: 4,
                            children: song.categories
                                .take(3)
                                .map(
                                  (cat) => TagChip(
                                    cat: cat,
                                    color: Colors.blue.withAlpha(40),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      if (song.tags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2, bottom: 2),
                          child: Wrap(
                            spacing: 4,
                            children: song.tags
                                .take(3)
                                .map(
                                  (tag) => TagChip(
                                    cat: tag,
                                    color: Colors.green.withAlpha(40),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      if (song.themes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2, bottom: 2),
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: song.themes
                                .take(3)
                                .map(
                                  (theme) => TagChip(
                                    cat: theme,
                                    color: Colors.orange.withAlpha(40),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
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
      actions: [
        Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).iconTheme.color,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'collections',
                child: Row(
                  children: [
                    Icon(Icons.collections),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.collections),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'statistics',
                child: Row(
                  children: [
                    Icon(
                      Icons.calculate,
                    ), // Changed to a calculation icon for stats
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.statistics),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.settings),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'collections') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CollectionsPage()),
                );
              } else if (value == 'statistics') {
                // We'll implement statistics page later in Phase 2
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.statistics_coming_soon,
                    ),
                  ),
                );
              } else if (value == 'settings') {
                Navigator.pushNamed(context, '/settings');
              }
            },
          ),
        ),
      ],
    );
  }

  Column categoryColumn(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40),
        SizedBox(
          height: 40,
          child: Padding(
            padding: EdgeInsetsGeometry.only(left: 20),
            child: Text(
              AppLocalizations.of(context)!.helloWorld,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.left,
            ),
          ),
        ),
        SizedBox(height: 40),
        Container(
          height: 150,
          color: Colors.white,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: EdgeInsets.only(left: 20, right: 20),
            separatorBuilder: (context, index) {
              return SizedBox(width: 5);
            },
            itemBuilder: (context, index) {
              return Container(
                width: 100,
                decoration: BoxDecoration(
                  color: Color(
                    int.parse('0xFF${categories[index].colorHex.substring(1)}'),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(categories[index].icon, color: Colors.white, size: 30),
                    SizedBox(height: 8),
                    Text(
                      categories[index].name,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget changeLanguage(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsetsGeometry.all(30),
        child: GestureDetector(
          onTap: () {
            final currentLocale = Localizations.localeOf(context).languageCode;
            if (currentLocale == 'en') {
              // widget.setLocale(Locale('ru'));
            } else {
              // widget.setLocale(Locale('en'));
            }
          },
          child: SizedBox(
            height: 100,
            width: 100,
            child: Icon(Icons.language, size: 100),
          ),
        ),
      ),
    );
  }

  Widget textCtrl(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(10.0),
      child: Center(
        child: Column(
          children: [
            TextField(controller: controller),
            Text(text),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _getCategories();

    return Scaffold(
      appBar: _appbar(context),
      body: _searchSection(context),
      // Adding a bottom navigation bar to access different sections
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onTextChange() {
    setState(() {
      text = controller.text.toLowerCase();
    });
  }
}

class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.cat, this.color = Colors.blue});

  final Color color;
  final String cat;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(3)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
        child: Text(cat),
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 40, left: 20, right: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.30),
            blurRadius: 40,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          // fillColor: Theme.of(context).cardColor,
          contentPadding: EdgeInsets.all(15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          hintText: AppLocalizations.of(context)!.search,
          hintStyle: Theme.of(context).textTheme.labelMedium,
          prefixIcon: Icon(Icons.search),
          suffixIcon: SizedBox(
            width: 50,
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  VerticalDivider(
                    color: Theme.of(context).colorScheme.secondary,
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                  ),
                  Icon(Icons.filter_list_outlined),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
