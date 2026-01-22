import 'package:flutter/material.dart';
import '../db/song_database.dart';
import '../models/collection.dart';
import '../models/song.dart';
import 'song_detail_page.dart';
import '../l10n/app_localizations.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  late Future<List<Collection>> _collectionsFuture;

  @override
  void initState() {
    super.initState();
    _collectionsFuture = SongDatabase.instance.getAllCollections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.collections),
      ),
      body: FutureBuilder<List<Collection>>(
        future: _collectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                AppLocalizations.of(
                  context,
                )!.error_occurred(snapshot.error.toString()),
              ),
            );
          }

          final collections = snapshot.data ?? [];

          if (collections.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(AppLocalizations.of(context)!.no_collections_yet),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final collection = collections[index];
                return Card(
                  child: ExpansionTile(
                    title: Text(collection.name),
                    subtitle: Text(
                      AppLocalizations.of(
                        context,
                      )!.songs_count(collection.songIds.length),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (collection.description.isNotEmpty)
                              Text(
                                collection.description,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            const SizedBox(height: 8),
                            FutureBuilder<List<Song>>(
                              future: _getSongsForCollection(collection),
                              builder: (context, songsSnapshot) {
                                if (songsSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const LinearProgressIndicator();
                                }
            
                                if (songsSnapshot.hasError) {
                                  return Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.error_occurred(songsSnapshot.error ?? ""),
                                  );
                                }
            
                                final songs = songsSnapshot.data ?? [];
            
                                if (songs.isEmpty) {
                                  return Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.no_songs_in_collection,
                                  );
                                }
            
                                return Column(
                                  children: songs
                                      .map(
                                        (song) => ListTile(
                                          title: Text(song.title),
                                          dense: true,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SongDetailPage(song: song),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                      .toList(),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.edit),
                                    label: Text(
                                      AppLocalizations.of(context)!.edit,
                                    ),
                                    onPressed: () =>
                                        _editCollection(context, collection),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.delete),
                                    label: Text(
                                      AppLocalizations.of(context)!.delete,
                                    ),
                                    onPressed: () =>
                                        _deleteCollection(context, collection),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: 
      FloatingActionButton(
        onPressed: () => _createNewCollection(context),
        child: Icon(Icons.add),
      )
    );
  }

  Future<List<Song>> _getSongsForCollection(Collection collection) async {
    if (collection.songIds.isEmpty) {
      return [];
    }

    final db = await SongDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      where: 'id IN (${collection.songIds.map((_) => '?').join(',')})',
      whereArgs: collection.songIds,
    );

    return maps.map((map) => Song.fromMap(map)).toList();
  }

  void _createNewCollection(BuildContext context) async {
    final Collection? newCollection = await showDialog<Collection>(
      context: context,
      builder: (context) => _CollectionFormDialog(collection: null),
    );

    if (newCollection != null) {
      await SongDatabase.instance.createCollection(newCollection);
      setState(() {
        _collectionsFuture = SongDatabase.instance.getAllCollections();
      });
    }
  }

  void _editCollection(BuildContext context, Collection collection) async {
    final Collection? updatedCollection = await showDialog<Collection>(
      context: context,
      builder: (context) => _CollectionFormDialog(collection: collection),
    );

    if (updatedCollection != null) {
      await SongDatabase.instance.updateCollection(updatedCollection);
      setState(() {
        _collectionsFuture = SongDatabase.instance.getAllCollections();
      });
    }
  }

  void _deleteCollection(BuildContext context, Collection collection) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirm_delete),
        content: Text(
          AppLocalizations.of(context)!.are_you_sure_delete(collection.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await SongDatabase.instance.deleteCollection(collection.id);
              setState(() {
                _collectionsFuture = SongDatabase.instance.getAllCollections();
              });
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }
}

class _CollectionFormDialog extends StatefulWidget {
  final Collection? collection;

  const _CollectionFormDialog({this.collection});

  @override
  State<_CollectionFormDialog> createState() => _CollectionFormDialogState();
}

class _CollectionFormDialogState extends State<_CollectionFormDialog> {
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
                FutureBuilder<List<Song>>(
                  future: SongDatabase.instance.getAllSongs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return Text(
                        AppLocalizations.of(
                          context,
                        )!.error_occurred(snapshot.error.toString()),
                      );
                    }

                    final songs = snapshot.data ?? [];

                    return Column(
                      children: songs
                          .map(
                            (song) => CheckboxListTile(
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
                    );
                  },
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
