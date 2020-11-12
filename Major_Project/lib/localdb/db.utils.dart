import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DBUtils {
  static Future<Database> init() async {
    var database = openDatabase(
      path.join(await getDatabasesPath(), 'settings.db'),
      onCreate: (db, version) {
        db.execute("CREATE TABLE settings(Type TEXT PRIMARY KEY, Color TEXT)");
      },
      version: 1,
    );
    return database;
  }
}
