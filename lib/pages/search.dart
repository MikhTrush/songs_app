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
    final results = await SongDatabase.instance.search(query);
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
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
                return ListTile(
                  title: Text(song.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${song.verses[0].substring(0, min(60, song.verses[0].length))}...',
                      ),
                      if (song.categories.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          children: song.categories
                              .take(3)
                              .map(
                                (cat) => Chip(
                                  label: Text(
                                    cat,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: Colors.blue.withAlpha(40),
                                ),
                              )
                              .toList(),
                        ),
                      if (song.tags.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          children: song.tags
                              .take(3)
                              .map(
                                (tag) => Chip(
                                  label: Text(
                                    tag,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: Colors.green.withAlpha(40),
                                ),
                              )
                              .toList(),
                        ),
                      if (song.themes.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          children: song.themes
                              .take(3)
                              .map(
                                (theme) => Chip(
                                  label: Text(
                                    theme,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: Colors.orange.withAlpha(40),
                                ),
                              )
                              .toList(),
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
      leading: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Icon(Icons.menu, color: Theme.of(context).iconTheme.color),
      ),
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
