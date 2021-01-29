import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class DBUtils {
  // database initialization
  static Future<Database> init() async {
    var database = openDatabase(
      join(await getDatabasesPath(), 'settings.db'),
      onCreate: (db, version) {
        db.execute("CREATE TABLE settings(Type TEXT PRIMARY KEY, Color TEXT)");
      },
      version: 1,
    );
    return database;
  }
}

void openDbWithCopy() async{
  var db;
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, "29_nov_covid.db");

// Check if the database exists
  var exists = await databaseExists(path);

  if (!exists) {
// Should happen only the first time you launch your application
    print("Creating new copy from asset");

// Make sure the parent directory exists
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

// Copy from asset
    ByteData data = await rootBundle.load(join("assets", "29_nov_covid.db"));
    List<int> bytes =
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

// Write and flush the bytes written
    await File(path).writeAsBytes(bytes, flush: true);

  } else {
    print("Opening existing database");
  }
// open the database
  db = await openDatabase(path, readOnly: true);
}