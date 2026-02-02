import 'package:flutter/material.dart';
import '../models/song.dart';
import '../db/song_database.dart';
import '../l10n/app_localizations.dart';

class SongFormPage extends StatefulWidget {
  final Song? song;

  const SongFormPage({super.key, this.song});

  @override
  State<SongFormPage> createState() => _SongFormPageState();
}

class _SongFormPageState extends State<SongFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _versesController = TextEditingController();
  final _startingChorusController = TextEditingController();
  final _chorusController = TextEditingController();
  final _endingChorusController = TextEditingController();
  final _categoriesController = TextEditingController();
  final _tagsController = TextEditingController();
  final _themesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.song != null) {
      _titleController.text = widget.song!.title;
      
      // Format verses for display
      final verseTexts = widget.song!.verses.map((verse) => verse.lines.join('\n')).toList();
      _versesController.text = verseTexts.join('\n\n');
      
      _categoriesController.text = widget.song!.categories.join(',');
      _tagsController.text = widget.song!.tags.join(',');
      _themesController.text = widget.song!.themes.join(',');
      
      // Initialize chorus controllers
      if (widget.song!.startingChorus != null) {
        _startingChorusController.text = widget.song!.startingChorus!.join('\n');
      }
      if (widget.song!.chorus != null) {
        _chorusController.text = widget.song!.chorus!.join('\n');
      }
      if (widget.song!.endingChorus != null) {
        _endingChorusController.text = widget.song!.endingChorus!.join('\n');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.song != null
              ? AppLocalizations.of(context)!.edit_song
              : AppLocalizations.of(context)!.create_song,
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState?.validate() == true) {
                _saveSong();
              }
            },
            child: Text(
              widget.song != null
                  ? AppLocalizations.of(context)!.update
                  : AppLocalizations.of(context)!.create,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.title,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.please_enter_title;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _versesController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.verses,
                ),
                maxLines: 10,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startingChorusController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.starting_chorus,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _chorusController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.chorus,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endingChorusController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.ending_chorus,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoriesController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.categories,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.tags,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _themesController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.themes,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSong() {
    if (_formKey.currentState?.validate() != true) return;

    // Parse verses - split by double newlines and create Verse objects
    final verseBlocks = _versesController.text.split('\n\n')
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty)
        .toList();
    
    List<Verse> verses = [];
    for (int i = 0; i < verseBlocks.length; i++) {
      // Split each verse block into lines
      final lines = verseBlocks[i].split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      verses.add(Verse(number: (i+1).toString(), lines: lines));
    }
        
    // Process chorus fields
    List<String>? startingChorus = _startingChorusController.text.trim().isEmpty 
        ? null 
        : _startingChorusController.text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    
    List<String>? chorus = _chorusController.text.trim().isEmpty 
        ? null 
        : _chorusController.text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        
    List<String>? endingChorus = _endingChorusController.text.trim().isEmpty 
        ? null 
        : _endingChorusController.text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    final categories = _categoriesController.text.split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final tags = _tagsController.text.split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final themes = _themesController.text.split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final song = Song(
      id: widget.song?.id ?? 0, // Will be ignored for new songs
      title: _titleController.text,
      verses: verses,
      startingChorus: startingChorus,
      chorus: chorus,
      endingChorus: endingChorus,
      categories: categories,
      tags: tags,
      themes: themes,
    );

    if (widget.song != null) {
      SongDatabase.instance.updateSong(song).then((_) {
        Navigator.pop(context, song);
      });
    } else {
      SongDatabase.instance.create(song).then((savedSong) {
        Navigator.pop(context, savedSong);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _versesController.dispose();
    _startingChorusController.dispose();
    _chorusController.dispose();
    _endingChorusController.dispose();
    _categoriesController.dispose();
    _tagsController.dispose();
    _themesController.dispose();
    super.dispose();
  }
}