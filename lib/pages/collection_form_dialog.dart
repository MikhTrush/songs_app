import 'package:flutter/material.dart';
import 'package:songs_app/db/song_database.dart';
import 'package:songs_app/l10n/app_localizations.dart';
import 'package:songs_app/models/collection.dart';
import 'package:songs_app/models/song.dart';

class CollectionFormDialog extends StatefulWidget {
  final Collection? collection;

  const CollectionFormDialog({super.key, this.collection});

  @override
  State<CollectionFormDialog> createState() => _CollectionFormDialogState();
}


class _CollectionFormDialogState extends State<CollectionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<Song> _allSongs = [];
  Set<int> _selectedSongIds = <int>{};

  @override
  void initState() {
    super.initState();

    if (widget.collection != null) {
      _nameController.text = widget.collection!.name;
      _descriptionController.text = widget.collection!.description;
      _selectedSongIds = widget.collection!.songIds.toSet();
    }

    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final songs = await SongDatabase.instance.getAllSongs();
    setState(() {
      _allSongs = songs;
      if (widget.collection != null) {
        // Pre-select songs that are already in the collection
        _selectedSongIds = widget.collection!.songIds.toSet();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.collection != null
            ? AppLocalizations.of(context)!.edit_collection
            : AppLocalizations.of(context)!.create_collection,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.name_field,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.please_enter_name;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.description,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.select_songs,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Column(
                  children: _allSongs
                      .map(
                        (song) => CheckboxListTile(
                          key: ValueKey(song.id),
                          title: Text(song.title),
                          value: _selectedSongIds.contains(song.id),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedSongIds.add(song.id);
                              } else {
                                _selectedSongIds.remove(song.id);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              final collection = Collection(
                id:
                    widget.collection?.id ??
                    0, // Will be ignored for new collections
                name: _nameController.text,
                description: _descriptionController.text,
                songIds: _selectedSongIds.toList(),
              );
              Navigator.pop(context, collection);
            }
          },
          child: Text(
            widget.collection != null
                ? AppLocalizations.of(context)!.update
                : AppLocalizations.of(context)!.create,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
