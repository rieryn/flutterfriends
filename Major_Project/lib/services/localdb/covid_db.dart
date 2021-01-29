import 'dart:io';
import 'dart:typed_data';
import 'package:geocoding/geocoding.dart';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class CovidDB {
  Database db;
  List<List<Location>> tableCoordinates=[];
  List<String> caseList=[];
  CovidDB._privateConstructor();
  static final CovidDB _instance = CovidDB._privateConstructor();
  static CovidDB get instance => _instance;

  void init() async {
    db =  await openDbWithCopy();
    geocodeLocations();
    getCumulativeCases();
  }
//https://github.com/tekartik/sqflite/blob/master/sqflite/doc/opening_asset_db.md

  Future<Database> openDbWithCopy() async {
    var db;
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "data/29_nov_covid.db");
// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
// Should happen only the first time you launch your application
      print("Creating new copy from asset");

// Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {print(_);}

// Copy from asset
      ByteData data = await rootBundle.load(join("assets/data", "29_nov_covid.sqlite"));
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

// Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
// open the database
    db = await openDatabase(path, readOnly: true);
    return db;
  }
  getCumulativeCases() async{
    List<Map> result = await db.rawQuery('SELECT cumulative_cases FROM "results-20201130-164302"');
    result.forEach((row) {caseList.add(row['cumulative_cases']);});
  }
  geocodeLocations() async {
    //query addresses
    List<Map> result = await db.rawQuery('SELECT province, health_region FROM "results-20201130-164302"');
    List<String> v=[];
    //concatenate addresses
    result.forEach((row) =>
        v.add(
            row.values.reduce(
                (a, b) => a +" "+ b)
        )
    );
    for (String address in v){
      try{
      locationFromAddress(address).then(
          (val){tableCoordinates.add(val);
          });
      } on NoResultFoundException{print('yeah i know');}
      on PlatformException{}
          catch(e){print(e);}
    }
  }
}