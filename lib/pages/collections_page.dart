import 'package:flutter/material.dart';
import '../db/song_database.dart';
import '../models/collection.dart';
import '../models/song.dart';
import 'song_detail_page.dart';

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
        title: const Text('Collections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createNewCollection(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Collection>>(
        future: _collectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final collections = snapshot.data ?? [];

          if (collections.isEmpty) {
            return const Center(
              child: Text(
                'No collections yet. Tap the + button to create one.',
              ),
            );
          }

          return ListView.builder(
            itemCount: collections.length,
            itemBuilder: (context, index) {
              final collection = collections[index];
              return Card(
                child: ExpansionTile(
                  title: Text(collection.name),
                  subtitle: Text('${collection.songIds.length} songs'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                return Text('Error: ${songsSnapshot.error}');
                              }

                              final songs = songsSnapshot.data ?? [];

                              if (songs.isEmpty) {
                                return const Text(
                                  'No songs in this collection',
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
                                  label: const Text('Edit'),
                                  onPressed: () =>
                                      _editCollection(context, collection),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Delete'),
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
          );
        },
      ),
      floatingActionButton: IconButton(
        onPressed: () => _createNewCollection(context),
        icon: Icon(Icons.add),
      ),
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
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${collection.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await SongDatabase.instance.deleteCollection(collection.id);
              setState(() {
                _collectionsFuture = SongDatabase.instance.getAllCollections();
              });
            },
            child: const Text('Delete'),
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
        widget.collection != null ? 'Edit Collection' : 'Create Collection',
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
                  decoration: const InputDecoration(labelText: 'Name *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Songs:',
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
                      return Text('Error: ${snapshot.error}');
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
          child: const Text('Cancel'),
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
          child: Text(widget.collection != null ? 'Update' : 'Create'),
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
