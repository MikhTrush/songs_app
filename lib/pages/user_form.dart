import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key});

  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  Database? _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'users.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> _saveUser() async {
    if (_nameController.text.isNotEmpty && _database != null) {
      await _database!.insert('users', {
        'name': _nameController.text,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      _nameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Введите имя')),
      body: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Имя'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveUser();

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Сохранено!')));
            },
            child: Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }
}
