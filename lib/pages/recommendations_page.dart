import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/recommendation_service.dart';
import 'song_detail_page.dart';
import '../l10n/app_localizations.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  final RecommendationService _recommendationService = RecommendationService();
  final TextEditingController _themeController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  List<Song> _recommendedSongs = [];
  bool _isLoading = false;
  String _activeFilter = 'themes'; // Can be 'themes', 'tags', or 'unused'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.recommendations),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input section for themes/tags
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.enter_themes_or_tags,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    
                    // Tabs for switching between themes and tags input
                    ToggleButtons(
                      isSelected: [
                        _activeFilter == 'themes',
                        _activeFilter == 'tags',
                        _activeFilter == 'unused'
                      ],
                      onPressed: (index) {
                        setState(() {
                          if (index == 0) _activeFilter = 'themes';
                          if (index == 1) _activeFilter = 'tags';
                          if (index == 2) _activeFilter = 'unused';
                          
                          // Clear the recommendations when switching tabs
                          _recommendedSongs = [];
                        });
                      },
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(AppLocalizations.of(context)!.by_themes),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(AppLocalizations.of(context)!.by_tags),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(AppLocalizations.of(context)!.unused),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    if (_activeFilter != 'unused') ...[
                      TextField(
                        controller: _activeFilter == 'themes' ? _themeController : _tagController,
                        decoration: InputDecoration(
                          labelText: _activeFilter == 'themes' 
                              ? AppLocalizations.of(context)!.enter_themes_hint 
                              : AppLocalizations.of(context)!.enter_tags_hint,
                          hintText: _activeFilter == 'themes' 
                              ? AppLocalizations.of(context)!.example_themes
                              : AppLocalizations.of(context)!.example_tags,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: _getRecommendations,
                          ),
                        ),
                        onSubmitted: (_) => _getRecommendations(),
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    ElevatedButton(
                      onPressed: _getRecommendations,
                      child: Text(AppLocalizations.of(context)!.get_recommendations),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Results section
            if (_isLoading)
              const LinearProgressIndicator()
            else if (_recommendedSongs.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _recommendedSongs.length,
                  itemBuilder: (context, index) {
                    final song = _recommendedSongs[index];
                    return Card(
                      child: ListTile(
                        title: Text(song.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (song.categories.isNotEmpty)
                              Wrap(
                                spacing: 4,
                                children: song.categories.take(3).map((cat) => 
                                  Chip(
                                    label: Text(cat, style: const TextStyle(fontSize: 10)),
                                    backgroundColor: Colors.blue.withAlpha(40),
                                  ),
                                ).toList(),
                              ),
                            if (song.tags.isNotEmpty)
                              Wrap(
                                spacing: 4,
                                children: song.tags.take(3).map((tag) => 
                                  Chip(
                                    label: Text(tag, style: const TextStyle(fontSize: 10)),
                                    backgroundColor: Colors.green.withAlpha(40),
                                  ),
                                ).toList(),
                              ),
                            if (song.themes.isNotEmpty)
                              Wrap(
                                spacing: 4,
                                children: song.themes.take(3).map((theme) => 
                                  Chip(
                                    label: Text(theme, style: const TextStyle(fontSize: 10)),
                                    backgroundColor: Colors.orange.withAlpha(40),
                                  ),
                                ).toList(),
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SongDetailPage(song: song),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              )
            else if (!_isLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.enter_recommendations_prompt,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.recommendations_info,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _getRecommendations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Song> recommendations = [];

      if (_activeFilter == 'themes') {
        final themesInput = _themeController.text.trim();
        if (themesInput.isNotEmpty) {
          final themes = themesInput.split(',').map((s) => s.trim()).toList();
          recommendations = await _recommendationService.getRecommendationsByTheme(themes);
        }
      } else if (_activeFilter == 'tags') {
        final tagsInput = _tagController.text.trim();
        if (tagsInput.isNotEmpty) {
          final tags = tagsInput.split(',').map((s) => s.trim()).toList();
          recommendations = await _recommendationService.getRecommendationsByTags(tags);
        }
      } else if (_activeFilter == 'unused') {
        recommendations = await _recommendationService.getUnusedSongs();
      }

      setState(() {
        _recommendedSongs = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting recommendations: $e')),
      );
    }
  }

  @override
  void dispose() {
    _themeController.dispose();
    _tagController.dispose();
    super.dispose();
  }
}