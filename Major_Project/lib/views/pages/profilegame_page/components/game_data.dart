import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

class GameData extends ChangeNotifier {
  Map<String, double> stats;
  Map<String, double> enemystats;
  Map<String, int> upgrades;
  Map<String, int> resources;
  Map<String, int> buildings;

  // GameData._privateConstructor();
//  static final GameData _instance = GameData._privateConstructor();

  // static GameData get instance => _instance;

  GameData({
    this.stats,
    this.enemystats,
    this.resources,
    this.upgrades,
  });

  //so the idea is, the game keeps the maps updated already so its cheap to stream it   //i guess around here is where i'm supposed to regret not rolling bloc
  factory GameData.pack(
      {Map<String, double> stats,
      Map<String, double> enemystats,
      Map<String, int> resources,
      Map<String, int> upgrades}) {
    //this is mostly for reference
    Map<String, double> Stats = {
      "hp": 0,
      "maxhp": 0,
      "atk": 0,
      "dmg": 0,
      "dex": 0,
      "luck": 0,
    };
    Map<String, int> Resources = {
      "gold": 0,
      "souls": 0,
      "potions": 0,
      "carrots": 0,
      "eggs": 0,
      "faith": 0,
    };
    Map<String, int> Upgrades = {
      "debug": 0,
    };
    Map<String, double> Enemystats = {
      "hp": 1000,
      "maxhp": 1000,
      "atk": 20,
      "armor": 0,
      "spd": 40,
      "dex": 10,
      "luck": 0, //doesn't do anything as usual
    };
    return GameData(
      stats: stats ?? Stats,
      resources: resources ?? Resources,
      upgrades: upgrades ?? Upgrades,
      enemystats: enemystats ??Enemystats,
    );
  }

  void saveData() {
    //  stats.forEach((key, value) { })
  }
}

class GameController {
  GameController._privateConstructor();

  GameData data;
  StreamController<GameData> streamController;
  static final GameController _instance = GameController._privateConstructor();

  static GameController get instance => _instance;
  Stream<GameData> gameStream;

  void updateStream(GameData gameData) {
    streamController.add(gameData);
  }

  void init() {
    streamController = StreamController<GameData>();
    updateStream(GameData.pack());
  }
}
