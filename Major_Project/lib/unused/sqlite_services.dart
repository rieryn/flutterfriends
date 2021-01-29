/*

import 'package:flutter/foundation.dart';
import 'package:major_project/models/settings_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class SQLiteService
    //with ChangeNotifier
  {
  //use  ChangeNotifierProvider(create: (context) => SQLiteService())
  static final tableName = 'settings';
  Database db;

  SQLiteService() {
    init();
  }

  void init() async {
    final dbPath = await getDatabasesPath();
    db = await openDatabase(
      path.join(dbPath, 'settings.db'),
      onCreate: (db, version) {
        final table = '''CREATE TABLE IF NOT EXISTS $tableName (
            id TEXT PRIMARY KEY,
            theme TEXT,
            image TEXT
        )''';
        return db.execute(table);
      },
      version: 1,
    );
    //notify provider when init finishes
    //notifyListeners();
  }
  //settings helpers
  Future<void> updateSettings(Settings setting) async {
    if (db !=null) {
      // only one setting it will always be over written
      await db.insert('settings', setting.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
     // notifyListeners();
    }
    //else?
  }
  Future<Settings> readSettings() async {
    if (db !=null) {
      final List<Map<String, dynamic>> maps = await db.query('settings');
      List<Settings> results = [];
      if (maps.length > 0) {
        for (int i = 0; i < maps.length; i++) {
          results.add(Settings.fromMap(maps[i]));
        }
      }
      return results[0];
    }
  }

}*/