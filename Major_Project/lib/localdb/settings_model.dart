import 'package:sqflite/sqflite.dart';
import 'db.utils.dart';
import 'settings.dart';

class SettingsModel {
  static Future<void> updateSettings(Settings setting) async {
    final db = await DBUtils.init();
    await db.insert('settings', setting.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Settings> readSettings() async {
    final db = await DBUtils.init();
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
